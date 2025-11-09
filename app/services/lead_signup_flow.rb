# app/services/lead_signup_flow.rb
class LeadSignupFlow
  include ActiveModel::Model
  attr_reader :lead, :user

  def call!(lead_params:, password:, referral_lead_id: nil, auto_approve: true)
    ActiveRecord::Base.transaction do
      token = SecureRandom.hex(10)

      # normalizza email
      lead_email = lead_params[:email].to_s.strip.downcase

      @lead = Lead.create!(
        name:     lead_params[:name],
        surname:  lead_params[:surname],
        username: lead_params[:username],
        email:    lead_email,
        phone:    lead_params[:phone],
        referral_lead_id: referral_lead_id,
        token:    token
      )

      # Scegli l'attributo email corretto su users: :email o :email_address
      email_attr = if User.column_names.include?("email")
                     :email
      elsif User.column_names.include?("email_address")
                     :email_address
      else
                     raise "Users table must have either email or email_address"
      end

      # blocca doppioni sull'attributo corretto
      if User.exists?(email_attr => lead_email)
        # alza errore sul LEAD per farlo cadere nel rescue già gestito
        @lead.errors.add(:email, "già registrata")
        raise ActiveRecord::RecordInvalid, @lead
      end

      # crea l'utente usando l'attributo corretto
      @user = User.create!(
        email_attr => lead_email,
        password:    password
      )

      @lead.update!(user_id: @user.id)

      # opzionale: auto-approve se il modello Lead lo supporta
      if @lead.respond_to?(:status) && @lead.respond_to?(:approved_at) && auto_approve
        @lead.update!(status: :approved, approved_at: Time.current)
      end
    end

    self
  end
end
