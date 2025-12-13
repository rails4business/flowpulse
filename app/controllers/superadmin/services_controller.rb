module Superadmin
class ServicesController < ApplicationController
  before_action :set_service, only: %i[ show edit update destroy rails4b generaimpresa ]
  before_action :load_branches, only: %i[ show rails4b generaimpresa ]
  before_action :load_production_stats, only: %i[ show rails4b generaimpresa ]
  before_action :load_public_revenue_stats, only: %i[ show generaimpresa ]

  # GET /services or /services.json
  def index
    @services = Service.all
  end

  # GET /services/1 or /services/1.json
  def show
  end

  def rails4b
    @taxbranch = @service.taxbranch
    @journeys = @service.journeys.order(updated_at: :desc).limit(12)
    @upcoming_eventdates = @service.eventdates.order(:date_start).limit(20)
  end

  def generaimpresa
    @journeys_scope = @service.journeys
    @journeys_count = @journeys_scope.count
    @eventdates_count = @service.eventdates.count
    @enrollments_count = @service.enrollments.count
    @bookings_count = @service.bookings.count
    @certificates_count = @service.certificates.count
    @roles_breakdown = @service.enrollments.group(:role_name).count
  end

  # GET /services/new
  def new
    @service = Service.new
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services or /services.json
  def create
    @service = Service.new(service_params)

    respond_to do |format|
      if @service.save
        format.html { redirect_to @service, notice: "Service was successfully created." }
        format.json { render :show, status: :created, location: @service }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /services/1 or /services/1.json
  def update
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to @service, notice: "Service was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1 or /services/1.json
  def destroy
    @service.destroy!

    respond_to do |format|
      format.html { redirect_to services_path, notice: "Service was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def service_params
      params.expect(service: [
        :name, :slug, :description, :n_eventdates_planned, :price_enrollment_euro,
        :price_ticket_dash, :min_tickets, :max_tickets, :open_by_journey,
        :taxbranch_id, :lead_id, :meta, :allowed_roles, :output_roles,
        :auto_certificate, :require_booking_verification,
        :require_enrollment_verification, :verifier_roles
      ])
    end

    def load_branches
      @rails4b_branches = Taxbranch.where(branch_kind: Taxbranch.branch_kinds[:rails4b], rails4b_target_service_id: @service.id)
      @generaimpresa_branches = Taxbranch.where(branch_kind: Taxbranch.branch_kinds[:generaimpresa], generaimpresa_target_service_id: @service.id)
      @frontline_branch = Taxbranch.find_by(branch_kind: Taxbranch.branch_kinds[:frontline], id: @service.taxbranch_id)
    end

    def load_production_stats
      commitments_scope = Commitment.joins(eventdate: :journey).where(journeys: { service_id: @service.id })
      @production_cost_euro = commitments_scope.sum("COALESCE(commitments.compensation_euro, 0)")
      @production_minutes = commitments_scope.sum("COALESCE(commitments.duration_minutes, 0)")
    end

    def load_public_revenue_stats
      @enrollment_revenue_euro = @service.enrollments.sum("COALESCE(price_euro, 0)")
      @booking_revenue_euro = @service.bookings.sum("COALESCE(price_euro, 0)")
      @public_revenue_euro = @enrollment_revenue_euro + @booking_revenue_euro
    end
end
end
