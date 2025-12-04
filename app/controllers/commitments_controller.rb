class CommitmentsController < ApplicationController
  before_action :set_commitment, only: %i[ show edit update destroy ]
  before_action :set_journey

  # GET /commitments or /commitments.json
  def index
    @commitments = Commitment.all
  end

  # GET /commitments/1 or /commitments/1.json
  def show
  end

  # GET /commitments/new
  def new
    @commitment = Commitment.new
  end

  # GET /commitments/1/edit
  def edit
  end

  # POST /commitments or /commitments.json
  def create
    @commitment = @event.commitments.build(commitment_params)

    if @commitment.position.present?
      # salvi e poi lo sposti alla posizione scelta
      @commitment.save
      @commitment.insert_at(@commitment.position)
    else
      # acts_as_list: lo mette in fondo da solo
      @commitment.save
    end

    redirect_to @journey, notice: "Commitment creato correttamente."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end


  # PATCH/PUT /commitments/1 or /commitments/1.json
  def update
    respond_to do |format|
      if @commitment.update(commitment_params)
        format.html { redirect_to @commitment, notice: "Commitment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @commitment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @commitment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commitments/1 or /commitments/1.json
  def destroy
    @commitment.destroy!

    respond_to do |format|
      format.html { redirect_to commitments_path, notice: "Commitment was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_journey
      #  @journey = Journey.find(params[:journey_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_commitment
      @commitment = Commitment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def commitment_params
      params.expect(commitment: [ :journey_id, :taxbranch_id, :eventdate_id, :role_name, :area, :role_count, :compensation_euro, :compensation_dash, :duration_minutes, :importance, :urgency, :energy, :position, :commitment_kind, :notes, :meta ])
    end
end
