class EventdatesController < ApplicationController
  before_action :set_eventdate, only: %i[ show edit update destroy ]

 # GET /eventdates or /eventdates.json
 def index
  return redirect_to root_path, alert: "No lead found" unless Current.user&.lead

  @date = begin
    Date.parse(params[:on]) if params[:on].present?
  rescue ArgumentError
    nil
  end

  # Base: SOLO gli eventi del lead corrente
  base_scope = Eventdate.where(lead: Current.user.lead).order(date_start: :asc)

  # Agenda per giorno selezionato (solo quelli con date_start in quel giorno)
  if @date
    @agenda_eventdates = base_scope.where(
      date_start: @date.beginning_of_day..@date.end_of_day
    )
  else
    @agenda_eventdates = []
  end

  # Gruppi per le tabs
  @complete_eventdates    = base_scope.where.not(date_start: nil).where.not(date_end: nil)
  @start_only_eventdates  = base_scope.where.not(date_start: nil).where(date_end: nil)
  @todo_eventdates        = base_scope.where(date_start: nil)

  @tab = params[:tab].presence_in(%w[complete start_only todo]) || "complete"
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
      params.expect(eventdate: [ :date_start, :date_end, :taxbranch_id, :lead_id, :cycle, :status, :description, :meta, :journey_id ])
    end
end
