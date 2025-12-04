class JourneysController < ApplicationController
  before_action :set_journey, only: %i[ show edit update destroy carousel start_tracking stop_tracking]
   def start_tracking
    # evita di aprire due tracking contemporanei sullo stesso journey
    open_event = @journey.eventdates.where(date_end: nil).order(:created_at).last
    if open_event
      redirect_to journey_path(@journey), alert: "C'è già un evento in corso iniziato alle #{I18n.l(open_event.date_start, format: :short)}."
      return
    end

     event = @journey.eventdates.create!(
    date_start:  Time.current,
    lead_id:     Current.user.lead&.id,
    event_type:  :session,   # enum
    mode:        :online,    # enum
    visibility:  :internal_date, # enum
    status: :tracking, # enum (nota: 'draft' NON esiste in Eventdate)
    description: "Tracking iniziato" # NECESSARIA per la validazione!
  )

    redirect_to @journey, notice: "Tracking iniziato, scrivi cosa stai facendo."
  end

  def stop_tracking
    open_event = @journey.eventdates.where(date_end: nil).order(:created_at).last

    unless open_event
      redirect_to journey_path(@journey), alert: "Nessun evento in corso da chiudere."
      return
    end

    open_event.update!(date_end: Time.current)

    redirect_to edit_eventdate_path(open_event), notice: "Tracking completato."
  end

  # GET /journeys or /journeys.json
  def index
    if params[:filter].nil?
      @journeys = Journey.all
    else
      @journeys = Journey.where(kind: params[:filter])
    end
  end

  # GET /journeys/1 or /journeys/1.json
  def show
    @eventdates = @journey.eventdates.includes(commitments: [ :taxbranch, :bookings ])

    @enrollments = @journey.enrollments.includes(:contact)
  end

  def carousel
  end

  # GET /journeys/new
  def new
    @journey = Current.user.lead.journeys.build
  end

  # GET /journeys/1/edit
  def edit
  end

  # POST /journeys or /journeys.json
  def create
    @journey = Journey.new(journey_params)

    respond_to do |format|
      if @journey.save
        format.html { redirect_to @journey, notice: "Journey was successfully created." }
        format.json { render :show, status: :created, location: @journey }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @journey.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /journeys/1 or /journeys/1.json
  def update
    respond_to do |format|
      if @journey.update(journey_params)
        format.html { redirect_to @journey, notice: "Journey was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @journey }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @journey.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /journeys/1 or /journeys/1.json
  def destroy
    @journey.destroy!

    respond_to do |format|
      format.html { redirect_to journeys_path, notice: "Journey was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_journey
      @journey = Journey.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def journey_params
      params.expect(journey: [ :title, :taxbranch_id, :service_id, :lead_id, :importance, :urgency, :energy, :progress, :notes, :price_estimate_euro, :price_estimate_dash, :meta, :template_journey_id, :start_ideate, :start_realized, :start_erogation, :complete ])
    end
end
