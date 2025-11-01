module Superadmin
  class DomainsController < ApplicationController
    include RequireSuperadmin

  before_action :set_domain, only: %i[ show edit update destroy ]

  # GET /domains or /domains.json
  def index
    @domains = Domain.all
  end

  # GET /domains/1 or /domains/1.json
  def show
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
      params.expect(domain: [ :host, :language, :title, :description, :favicon_url, :square_logo_url, :horizontal_logo_url, :provider, :taxbranch_id ])
    end
  end
end
