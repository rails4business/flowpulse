class DashboardController < ApplicationController
  def home
    @lead = Current.user&.lead
    return redirect_to root_path, alert: "No lead found" unless @lead

    if params[:month].present? && params[:year].present? && params[:date].blank?
      day = params[:day].to_i
      day = 1 if day < 1
      base = Date.new(params[:year].to_i, params[:month].to_i, 1)
      date = Date.new(base.year, base.month, [day, base.end_of_month.day].min)
      redirect_to dashboard_home_path(date: date.strftime("%Y-%m-%d")) and return
    end

    @selected_date = begin
      if params[:month].present? && params[:year].present?
        Date.new(params[:year].to_i, params[:month].to_i, 1)
      elsif params[:date].present?
        date_param = params[:date]
        if date_param.is_a?(ActionController::Parameters) || date_param.is_a?(Hash)
          Date.new(date_param[:year].to_i, date_param[:month].to_i, date_param[:day].to_i)
        else
          Date.parse(date_param.to_s)
        end
      elsif params[:on].present?
        Date.parse(params[:on])
      end
    rescue ArgumentError
      nil
    end
    @selected_date ||= Time.zone.today

    base_scope = Eventdate.where(lead: @lead).order(date_start: :asc)
    @day_events = base_scope.where(date_start: @selected_date.beginning_of_day..@selected_date.end_of_day)
    @today = Time.zone.today
    @today_week_events_count = base_scope.where(
      date_start: @today.beginning_of_week..@today.end_of_week
    ).count

    month_start = @selected_date.beginning_of_month.beginning_of_week(:monday)
    month_end = @selected_date.end_of_month.end_of_week(:monday)
    @event_counts_by_day = base_scope
      .reorder(nil)
      .where(date_start: month_start.beginning_of_day..month_end.end_of_day)
      .group("DATE(date_start)")
      .count

    @tab = params[:tab].presence_in(%w[academy diario_salute corsi bookings enrollments]) || "academy"
    @current_domain = Current.domain
    @lead_domains = @lead.active_domains
    @domain_membership =
      if @current_domain.present?
        @lead.domain_memberships.find_by(domain_id: @current_domain.id)
      end
    @domain_role_options = available_domain_role_options(@domain_membership)
    mycontact_ids = @lead.mycontacts.select(:id)
    @bookings = Booking.includes(:eventdate, :service, :commitment, :enrollment)
                       .where(mycontact_id: mycontact_ids)
                       .order(created_at: :desc)
                       .limit(20)
    @enrollments = @lead.enrollments.includes(:service, :journey)
                          .order(updated_at: :desc)
                          .limit(20)
    questionnaire_scope = Activity.questionnaires.where(lead: @lead)
    questionnaire_scope = questionnaire_scope.where(domain_id: @current_domain.id) if @current_domain.present?
    @latest_questionnaire_activity = questionnaire_scope.recent_first.first
    build_academy_todo_from_taxbranch!
    load_dashboard_activity_modal!
  end

  def superadmin
  end

  def liste
  end

  def create_domain_membership
    lead = Current.user&.lead
    domain = Current.domain

    if lead.blank? || domain.blank?
      redirect_to dashboard_home_path, alert: "Impossibile creare la membership: lead o dominio non disponibili."
      return
    end

    membership = lead.domain_memberships.find_or_initialize_by(domain: domain)

    if membership.new_record?
      membership.status = :active
      membership.domain_active_role = membership.domain_active_role.presence || "member"
      has_primary = lead.domain_memberships.where(primary: true).where.not(id: membership.id).exists?
      membership.primary = !has_primary if membership.primary.nil?
      membership.save!
      notice = "Domain membership creata."
    else
      notice = "Domain membership già presente."
    end

    redirect_to dashboard_home_path, notice: notice
  rescue ActiveRecord::RecordInvalid => e
    redirect_to dashboard_home_path, alert: e.message
  end

  def update_domain_active_role
    lead = Current.user&.lead
    domain = Current.domain
    membership = if lead.present? && domain.present?
      lead.domain_memberships.find_by(domain_id: domain.id)
    end

    if membership.blank?
      redirect_to dashboard_home_path, alert: "Membership dominio non trovata."
      return
    end

    requested_role = params[:domain_active_role].to_s.strip
    allowed_roles = available_domain_role_options(membership)
    unless allowed_roles.include?(requested_role)
      redirect_to dashboard_home_path, alert: "Ruolo non valido per questo dominio."
      return
    end

    membership.update!(domain_active_role: requested_role)
    redirect_to dashboard_home_path(tab: params[:tab].presence || "academy"), notice: "Ruolo attivo aggiornato."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to dashboard_home_path, alert: e.message
  end

  private

  def available_domain_role_options(membership)
    return [ "member" ] if membership.blank?

    cert_scope = membership.certificates
    roles = cert_scope.pluck(:role_name).filter_map { |r| r.to_s.strip.presence }
    ([ "member" ] + roles).uniq
  end

  def build_academy_todo_from_taxbranch!
    @academy_todo_enabled = false
    @academy_requires_membership = true
    @academy_root_taxbranch = Taxbranch.find_by(slug: "academy/posturacorretta")
    return if @academy_root_taxbranch.blank?
    active_role = @domain_membership&.domain_active_role.presence || "member"
    @academy_requires_membership = @domain_membership.blank? || active_role != "member"

    mycontact_ids = @lead.mycontacts.select(:id)
    bookings = Booking.includes(:service, :eventdate, :enrollment, :commitment)
                      .where(mycontact_id: mycontact_ids).to_a
    enrollments = @lead.enrollments.includes(:service, :journey).to_a
    certificates = @lead.certificates.includes(:service, :journey, :taxbranch).to_a
    journeys = @lead.journeys.includes(:taxbranch, :service).to_a
    eventdates = Eventdate.includes(:journey, :taxbranch).where(lead: @lead).to_a

    step_scope = @academy_root_taxbranch.children.includes(:post).ordered
    step_scope = step_scope.reorder(position: :desc) if @academy_root_taxbranch.order_des?
    trackable_step_ids = step_scope.flat_map { |step| [ step.id ] + step.descendants.pluck(:id) }.uniq
    activity_scope = Activity.where(lead: @lead, kind: "step_completed")
    activity_scope = activity_scope.where(domain_id: @current_domain.id) if @current_domain.present?
    completed_step_ids = if trackable_step_ids.any?
      activity_scope.where(taxbranch_id: trackable_step_ids, status: "archived").distinct.pluck(:taxbranch_id)
    else
      []
    end
    step_activities = if trackable_step_ids.any?
      scoped = Activity.includes(:certificate)
                       .where(lead: @lead, taxbranch_id: trackable_step_ids)
                       .order(occurred_at: :desc, id: :desc)
      @current_domain.present? ? scoped.where(domain_id: @current_domain.id).to_a : scoped.to_a
    else
      []
    end

    @academy_steps = step_scope.map do |step|
      build_academy_step_node(
        step: step,
        bookings: bookings,
        enrollments: enrollments,
        certificates: certificates,
        journeys: journeys,
        eventdates: eventdates,
        activities: step_activities,
        completed_step_ids: completed_step_ids
      )
    end

    @academy_completed_steps_count = @academy_steps.count { |item| item[:status_key] == :completed }
    @academy_total_steps_count = @academy_steps.size
    @academy_progress_percent =
      if @academy_total_steps_count.positive?
        ((@academy_completed_steps_count.to_f / @academy_total_steps_count) * 100).round
      else
        0
      end
    @academy_next_step = @academy_steps.find { |item| item[:status_key] == :todo } || @academy_steps.find { |item| item[:status_key] == :scheduled }
    @academy_todo_enabled = @academy_steps.any?
  end

  def related_records_for_step(step:, bookings:, enrollments:, certificates:, journeys:, eventdates:, activities:)
    step_taxbranch_id = step.id
    matcher = lambda do |tb_id, text|
      tb_id.to_i == step_taxbranch_id || text.to_s.include?(step.slug_label.to_s.parameterize)
    end

    related_bookings = bookings.select do |booking|
      matcher.call(booking.service&.taxbranch_id, booking.service&.slug) ||
        matcher.call(booking.eventdate&.taxbranch_id, booking.eventdate&.description) ||
        matcher.call(booking.commitment&.taxbranch_id, booking.commitment&.role_name) ||
        matcher.call(booking.enrollment&.taxbranch&.id, booking.enrollment&.service&.slug)
    end

    related_enrollments = enrollments.select do |enrollment|
      matcher.call(enrollment.service&.taxbranch_id, enrollment.service&.slug) ||
        matcher.call(enrollment.journey&.taxbranch_id, enrollment.journey&.slug)
    end

    related_certificates = certificates.select do |certificate|
      matcher.call(certificate.taxbranch_id, certificate.role_name) ||
        matcher.call(certificate.service&.taxbranch_id, certificate.service&.slug) ||
        matcher.call(certificate.journey&.taxbranch_id, certificate.journey&.slug)
    end

    related_journeys = journeys.select do |journey|
      matcher.call(journey.taxbranch_id, journey.slug) ||
        matcher.call(journey.service&.taxbranch_id, journey.service&.slug)
    end

    related_eventdates = eventdates.select do |eventdate|
      matcher.call(eventdate.taxbranch_id, eventdate.description) ||
        matcher.call(eventdate.journey&.taxbranch_id, eventdate.journey&.slug)
    end
    related_activities = activities.select { |activity| activity.taxbranch_id.to_i == step_taxbranch_id }

    {
      bookings: related_bookings,
      enrollments: related_enrollments,
      certificates: related_certificates,
      journeys: related_journeys,
      eventdates: related_eventdates,
      activities: related_activities
    }
  end

  def build_academy_step_node(step:, bookings:, enrollments:, certificates:, journeys:, eventdates:, activities:, completed_step_ids:)
    related = related_records_for_step(
      step: step,
      bookings: bookings,
      enrollments: enrollments,
      certificates: certificates,
      journeys: journeys,
      eventdates: eventdates,
      activities: activities
    )

    latest_activity = related[:activities].first
    status_key = if completed_step_ids.include?(step.id)
      :completed
    else
      resolve_step_status_key(related, allow_completed: false)
    end
    status_key = :todo if @academy_requires_membership

    child_scope = step.children.includes(:post).ordered
    child_scope = child_scope.reorder(position: :desc) if step.order_des?
    children = child_scope.map do |child|
      build_academy_step_node(
        step: child,
        bookings: bookings,
        enrollments: enrollments,
        certificates: certificates,
        journeys: journeys,
        eventdates: eventdates,
        activities: activities,
        completed_step_ids: completed_step_ids
      )
    end

    children_total = children.size
    children_completed = children.count { |child| child[:status_key] == :completed }
    children_progress_percent =
      if children_total.positive?
        ((children_completed.to_f / children_total) * 100).round
      else
        0
      end

    step_progress_total = children_total.positive? ? children_total : 1
    step_progress_completed = children_total.positive? ? children_completed : (status_key == :completed ? 1 : 0)
    step_progress_percent =
      if step_progress_total.positive?
        ((step_progress_completed.to_f / step_progress_total) * 100).round
      else
        0
      end

    delivery = resolve_delivery_details(related)

    raw_description = step.post&.description.to_s
    {
      taxbranch: step,
      title: step.post&.title.presence || step.slug_label,
      subtitle: raw_description.truncate(120).presence || step.slug,
      status_key: status_key,
      status_label: status_label_for(status_key),
      activity_status: latest_activity&.status,
      activity_status_label: activity_status_label_for(latest_activity),
      activity_occurred_at: latest_activity&.occurred_at,
      mode_label: @academy_requires_membership ? "accedi all'accademia" : resolve_mode_label(related),
      delivery_available: delivery[:available],
      delivery_mode: delivery[:mode],
      delivery_has_professional: delivery[:has_professional],
      delivery_person_label: delivery[:person_label],
      delivery_instructor_name: delivery[:instructor_name],
      delivery_instructor_role: delivery[:instructor_role],
      delivery_channel: delivery[:channel],
      delivery_format: delivery[:format],
      delivery_location: delivery[:location],
      link_post: step.post,
      next_at: extract_step_datetime(related),
      children: children,
      is_module_academy: %w[academy_module module_academy module_accademy].include?(step.slug_category.to_s),
      module_total_steps: children_total,
      module_completed_steps: children_completed,
      module_progress_percent: children_progress_percent,
      step_progress_total: step_progress_total,
      step_progress_completed: step_progress_completed,
      step_progress_percent: step_progress_percent,
      children_progress_total: children_total,
      children_progress_completed: children_completed,
      children_progress_percent: children_progress_percent
    }
  end

  def extract_step_datetime(related)
    timestamps = []
    timestamps.concat(Array(related[:eventdates]).map(&:date_start))
    timestamps.concat(Array(related[:bookings]).map { |b| b.eventdate&.date_start })
    timestamps.compact.min
  end

  def resolve_step_status_key(related, allow_completed: true)
    latest_activity = related[:activities].first
    if latest_activity.present?
      return :completed if latest_activity.status.to_s == "archived"
      return :in_progress if %w[recorded reviewed].include?(latest_activity.status.to_s)
    end

    completed_booking = related[:bookings].any? { |b| b.completed? || b.checked_in? }
    completed_enrollment = related[:enrollments].any?(&:completed?)
    completed_eventdate = related[:eventdates].any?(&:completed?)
    if allow_completed
      return :completed if related[:certificates].any? || completed_booking || completed_enrollment || completed_eventdate
    end

    scheduled_booking = related[:bookings].any? { |b| b.confirmed? || b.pending_confirmation? || b.requested? }
    scheduled_eventdate = related[:eventdates].any? { |e| e.date_start.present? && e.date_start > Time.current }
    return :scheduled if scheduled_booking || scheduled_eventdate

    in_progress_enrollment = related[:enrollments].any? { |e| e.confirmed? || e.pending_confirmation? || e.requested? || e.draft? }
    in_progress_journey = related[:journeys].any? { |j| !j.journeys_status_chiuso? }
    return :in_progress if in_progress_enrollment || in_progress_journey

    :todo
  end

  def activity_status_label_for(activity)
    return nil if activity.blank?

    case activity.status.to_s
    when "recorded" then "Registrata"
    when "reviewed" then "In revisione"
    when "archived" then "Completata"
    else activity.status.to_s.humanize
    end
  end

  def resolve_mode_label(related)
    latest_activity = related[:activities].first
    if latest_activity.present?
      mode = latest_activity.attributes["mode"].to_s
      return "in autonomia" if mode == "autonomia"
      return "con professionista" if mode == "professionista"
    end

    booking = related[:bookings].first
    if booking.present?
      name = booking.service&.name.to_s.downcase
      return "con tutor" if name.include?("tutor")
      return "con professionista" if booking.participant_role_professionista? || name.include?("profession")
      return "in autonomia" if booking.mode_autonomia?
    end

    enrollment = related[:enrollments].first
    if enrollment.present?
      name = enrollment.service&.name.to_s.downcase
      return "in autonomia" if enrollment.mode_autonomia?
      return "con tutor" if name.include?("tutor")
      return "con professionista"
    end

    return "con professionista" if related[:certificates].any?

    "da definire"
  end

  def resolve_delivery_details(related)
    activity = related[:activities].first
    return default_delivery_details if activity.blank?

    has_professional = activity.certificate_id.present?
    mode = activity.attributes["mode"].to_s.presence
    mode = has_professional ? "professionista" : "autonomia" if mode.blank?
    mode = "autonomia" unless has_professional
    channel = activity.attributes["channel"].to_s.presence
    format = activity.attributes["format"].to_s.presence
    location_type = activity.attributes["location_type"].to_s.presence
    location_name = activity.attributes["location_name"].to_s.presence
    location_address = activity.attributes["location_address"].to_s.presence

    location_label = if channel == "online"
      "Online"
    elsif location_name.present?
      location_name
    elsif location_type == "domicilio"
      "A domicilio"
    elsif location_type == "centro"
      "In Centro"
    elsif location_address.present?
      location_address
    else
      "In Centro"
    end

    instructor_name = if !has_professional || mode == "autonomia"
      "In autonomia"
    else
      "Da definire"
    end

    instructor_role = if !has_professional || mode == "autonomia"
      "Percorso personale"
    else
      activity.certificate&.role_name.to_s.presence || "Professionista"
    end

    format_label = case format
    when "gruppo"
      size = activity.attributes["group_size"].to_i
      size.positive? ? "Gruppo #{size}" : "Gruppo"
    when "singolo"
      "Singolo"
    else
      "Gruppo 8-12"
    end
    format_label = "Singolo" if mode == "autonomia"

    {
      available: true,
      mode: mode,
      has_professional: has_professional,
      person_label: has_professional ? "Insegnante" : "Modalita",
      instructor_name: instructor_name,
      instructor_role: instructor_role,
      channel: channel.presence || "offline",
      format: format_label,
      location: location_label
    }
  end

  def default_delivery_details
    {
      available: false,
      mode: nil,
      has_professional: false,
      person_label: nil,
      instructor_name: nil,
      instructor_role: nil,
      channel: nil,
      format: nil,
      location: nil
    }
  end

  def status_label_for(status_key)
    case status_key
    when :completed then "Completato"
    when :scheduled then "Pianificato"
    when :in_progress then "In corso"
    else "Da fare"
    end
  end

  def load_dashboard_activity_modal!
    @open_activity_modal = false
    return unless params[:open_activity_modal].to_s == "1"

    @modal_activity = @lead.activities.find_by(id: params[:activity_id])
    return if @modal_activity.blank?

    @modal_post = begin
      Post.includes(:taxbranch).friendly.find(params[:post_id])
    rescue StandardError
      nil
    end
    return if @modal_post.blank?
    return if @modal_activity.taxbranch_id != @modal_post.taxbranch_id

    tb = @modal_post.taxbranch
    @modal_is_questionnaire = tb&.questionnaire_source_path.present? || tb&.questionnaire_root?
    @open_activity_modal = true
  end
end
