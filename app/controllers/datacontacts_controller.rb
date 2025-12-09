class DatacontactsController < ApplicationController
  before_action :set_datacontact, only: %i[ show edit update destroy ]
  before_action :set_reference_data, only: %i[ new edit create update ]

  # GET /contacts or /contacts.json
  def index
    @datacontacts = Datacontact.order(:last_name, :first_name)
  end

  # GET /contacts/1 or /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @datacontact = Datacontact.new(
      lead: Current.user&.lead,
      referent_lead: Current.user&.lead
    )
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts or /contacts.json
  def create
    @datacontact = Datacontact.new(datacontact_params)
    @datacontact.lead ||= Current.user&.lead
    @datacontact.referent_lead ||= Current.user&.lead

    respond_to do |format|
      if @datacontact.save
        format.html { redirect_to @datacontact, notice: "I dati contatto sono stati creati correttamente." }
        format.json { render :show, status: :created, location: @datacontact }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @datacontact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1 or /contacts/1.json
  def update
    respond_to do |format|
      if @datacontact.update(datacontact_params)
        format.html { redirect_to @datacontact, notice: "I dati contatto sono stati aggiornati.", status: :see_other }
        format.json { render :show, status: :ok, location: @datacontact }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @datacontact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1 or /contacts/1.json
  def destroy
    @datacontact.destroy!

    respond_to do |format|
      format.html { redirect_to datacontacts_path, notice: "I dati contatto sono stati eliminati.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_datacontact
      @datacontact = Datacontact.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def datacontact_params
      params.require(:datacontact)
            .permit(
              :first_name,
              :last_name,
              :lead_id,
              :email,
              :phone,
              :date_of_birth,
              :place_of_birth,
              :fiscal_code,
              :vat_number,
              :billing_name,
              :billing_address,
              :billing_zip,
              :billing_city,
              :billing_country,
              :meta,
              :referent_lead_id,
              :socials
            )
    end

    def set_reference_data
      @referent_leads = Lead.order(:surname, :name)
    end
end
