class EventdatesController < ApplicationController
  before_action :set_eventdate, only: %i[ show edit update destroy ]

 # GET /eventdates or /eventdates.json
 def index
  @lead = Current.user&.lead
  return redirect_to root_path, alert: "No lead found" unless @lead

  @taxbranches = @lead.taxbranches.order(:slug_label)
  @selected_taxbranch =
    if params[:taxbranch_id].present?
      @taxbranches.find_by(id: params[:taxbranch_id])
    end

  @date = begin
    Date.parse(params[:on]) if params[:on].present?
  rescue ArgumentError
    nil
  end

  # Base: SOLO gli eventi del lead corrente
  base_scope = Eventdate
    .where(lead: @lead)
    .includes(:taxbranch)
    .order(date_start: :asc)

  base_scope = base_scope.where(taxbranch_id: @selected_taxbranch.id) if @selected_taxbranch

  # Agenda per giorno selezionato (solo quelli con date_start in quel giorno)
  if @date
    @agenda_eventdates = base_scope.where(
      date_start: @date.beginning_of_day..@date.end_of_day
    )
  else
    @agenda_eventdates = []
  end

  # Collezioni per tabs
  @all_eventdates        = base_scope
  @complete_eventdates    = base_scope.where.not(date_start: nil).where.not(date_end: nil)
  @start_only_eventdates  = base_scope.where.not(date_start: nil).where(date_end: nil)
  @todo_eventdates        = base_scope.where(date_start: nil)

  @event_type_filter = params[:event_type].presence_in(Eventdate.event_types.keys) || "all"

  @current_collection = @all_eventdates
  if @event_type_filter != "all"
    @current_collection = @current_collection.where(event_type: Eventdate.event_types[@event_type_filter])
  end
end



  # GET /eventdates/1 or /eventdates/1.json
  def show
  end

  # GET /eventdates/new
  def new
    @eventdate = Eventdate.new
  end

  # GET /eventdates/1/edit
  def edit
  end

  # POST /eventdates or /eventdates.json
  def create
    @eventdate = Eventdate.new(eventdate_params)

    respond_to do |format|
      if @eventdate.save
        format.html { redirect_to @eventdate, notice: "Eventdate was successfully created." }
        format.json { render :show, status: :created, location: @eventdate }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @eventdate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /eventdates/1 or /eventdates/1.json
  def update
    respond_to do |format|
      if @eventdate.update(eventdate_params)
        format.html { redirect_to @eventdate, notice: "Eventdate was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @eventdate }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @eventdate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /eventdates/1 or /eventdates/1.json
  def destroy
    @eventdate.destroy!

    respond_to do |format|
      format.html { redirect_to eventdates_path, notice: "Eventdate was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_eventdate
      @eventdate = Eventdate.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def eventdate_params
      params.expect(eventdate: [
        :date_start,
        :date_end,
        :taxbranch_id,
        :lead_id,
        :cycle,
        :status,
        :description,
        :meta,
        :journey_id,
        :allows_invite,
        :allows_request,
        :event_type,
        :kind_event,
        :parent_eventdate_id
      ])
    end

end
