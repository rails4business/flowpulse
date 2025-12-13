module Superadmin
  class DomainsController < ApplicationController
    include RequireSuperadmin

  before_action :set_domain, only: %i[ show edit update destroy rails4b generaimpresa ]

  # GET /domains or /domains.json
  def index
    @domains = Domain.all
  end

  # GET /domains/1 or /domains/1.json
  def show
  end

  def rails4b
    @rails4b_taxbranches = @domain.rails4b_taxbranches.includes(:journeys)
  end

  def generaimpresa
    @main_taxbranch = @domain.taxbranch
    subtree_ids = @main_taxbranch&.subtree_ids || []
    @services_scope = subtree_ids.any? ? Service.where(taxbranch_id: subtree_ids) : Service.none
    @journeys_scope = subtree_ids.any? ? Journey.where(taxbranch_id: subtree_ids) : Journey.none
    @rails4b_branches =
      if subtree_ids.any?
        Taxbranch.where(branch_kind: Taxbranch.branch_kinds[:rails4b], rails4b_target_domain_id: @domain.id)
      else
        Taxbranch.none
      end
    @generaimpresa_branches =
      if subtree_ids.any?
        Taxbranch.where(branch_kind: Taxbranch.branch_kinds[:generaimpresa], generaimpresa_target_domain_id: @domain.id)
      else
        Taxbranch.none
      end
    journey_ids = @journeys_scope.pluck(:id)
    service_ids = @services_scope.pluck(:id)
    commitments_scope =
      if journey_ids.any?
        Commitment.joins(eventdate: :journey).where(journeys: { id: journey_ids })
      else
        Commitment.none
      end
    @enrollments_count = if subtree_ids.any?
                           Enrollment.joins(journey: :taxbranch).where(taxbranches: { id: subtree_ids }).count
                         else
                           0
                         end
    @certificates_count = if subtree_ids.any?
                            Certificate.where(taxbranch_id: subtree_ids).count
                          else
                            0
                          end
    @production_cost_euro = commitments_scope.sum("COALESCE(commitments.compensation_euro, 0)")
    @production_minutes = commitments_scope.sum("COALESCE(commitments.duration_minutes, 0)")

    enrollment_scope = Enrollment.none
    enrollment_scope = enrollment_scope.or(Enrollment.where(service_id: service_ids)) if service_ids.any?
    enrollment_scope = enrollment_scope.or(Enrollment.where(journey_id: journey_ids)) if journey_ids.any?
    booking_scope = Booking.none
    booking_scope = booking_scope.or(Booking.where(service_id: service_ids)) if service_ids.any?
    booking_scope = booking_scope.or(
      journey_ids.any? ? Booking.joins(eventdate: :journey).where(journeys: { id: journey_ids }) : Booking.none
    )
    @enrollment_revenue_euro = enrollment_scope.sum("COALESCE(price_euro, 0)")
    @booking_revenue_euro = booking_scope.sum("COALESCE(price_euro, 0)")
    @public_revenue_euro = @enrollment_revenue_euro + @booking_revenue_euro
  end

  # GET /domains/new
  def new
   @domain = Domain.new
   @taxbranches = Current.user&.lead&.taxbranches&.ordered || Taxbranch.none
  end

  # GET /domains/1/edit
  def edit
       @taxbranches = Current.user&.lead&.taxbranches&.ordered || Taxbranch.none
  end

  # POST /domains or /domains.json
  def create
    @domain = Domain.new(domain_params)

  @taxbranches = Current.user&.lead&.taxbranches&.ordered || Taxbranch.none


    respond_to do |format|
      if @domain.save
        format.html { redirect_to [ :superadmin, @domain ], notice: "Domain was successfully created." }
        format.json { render :show, status: :created, location: [ :superadmin, @domain ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /domains/1 or /domains/1.json
  def update
       @taxbranches = Current.user&.lead&.taxbranches&.ordered || Taxbranch.none
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to [ :superadmin, @domain ], notice: "Domain was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: [ :superadmin, @domain ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domains/1 or /domains/1.json
  def destroy
    @domain.destroy!

    respond_to do |format|
      format.html { redirect_to superadmin_domains_path, notice: "Domain was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domain
      @domain = Domain.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def domain_params
      params.expect(domain: [ :host, :language, :title, :description, :favicon_url, :square_logo_url, :horizontal_logo_url, :provider, :taxbranch_id, :role_areas ])
    end
  end
end
