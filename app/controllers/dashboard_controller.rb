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

    @tab = params[:tab].presence_in(%w[bookings enrollments]) || "bookings"
    @current_domain = Current.domain
    @lead_domains = @lead.active_domains
    @domain_membership =
      if @current_domain.present?
        @lead.domain_memberships.find_by(domain_id: @current_domain.id)
      end
    mycontact_ids = @lead.mycontacts.select(:id)
    @bookings = Booking.includes(:eventdate, :service, :commitment, :enrollment)
                       .where(mycontact_id: mycontact_ids)
                       .order(created_at: :desc)
                       .limit(20)
    @enrollments = @lead.enrollments.includes(:service, :journey)
                          .order(updated_at: :desc)
                          .limit(20)
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
end
