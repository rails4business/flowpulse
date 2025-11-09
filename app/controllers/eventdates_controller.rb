class EventdatesController < ApplicationController
  before_action :set_eventdate, only: %i[ show edit update destroy ]

  # GET /eventdates or /eventdates.json
  def index
    @eventdates = Eventdate.all
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
      params.expect(eventdate: [ :date_start, :date_end, :taxbranch_id, :lead_id, :cycle, :status, :description, :meta ])
    end
end
