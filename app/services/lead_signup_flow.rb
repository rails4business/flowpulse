# app/services/lead_signup_flow.rb
class LeadSignupFlow
  include ActiveModel::Model
  attr_reader :lead, :user

  def call!(lead_params:, password:, referral_lead_id: nil, auto_approve: false)
    ActiveRecord::Base.transaction do
      token = SecureRandom.hex(10)
      lead_email = lead_params[:email].to_s.strip.downcase

      # 1) Crea il LEAD (senza user_id)
      @lead = Lead.create!(
        name:     lead_params[:name],
        surname:  lead_params[:surname],
        username: lead_params[:username],
        email:    lead_email,
        phone:    lead_params[:phone],
        referral_lead_id: referral_lead_id,
        token:    token
      )

      # 2) Scegli il campo email corretto su User (:email o :email_address)
      email_attr =
        if User.column_names.include?("email")
          :email
        elsif User.column_names.include?("email_address")
          :email_address
        else
          raise "Users table must have either email or email_address"
        end

      # 3) Stop se esiste già un utente con questa email
      if User.exists?(email_attr => lead_email)
        @lead.errors.add(:email, "già registrata")
        raise ActiveRecord::RecordInvalid, @lead
      end

      # 4) Crea USER collegandolo al LEAD (users.lead_id)
      @user = User.create!(
        email_attr => lead_email,
        password:    password,
        lead:        @lead,
        # opzionale: imposta lo stato iniziale, ma tu hai scelto gestione manuale
        # state_registration: :pending
      )

      # 5) (OPZIONALE) auto-approve: se vuoi toccare *Lead* o *User* qui
      # Hai detto "no automatismi", quindi lascio off per default.
      if auto_approve && @user.respond_to?(:state_registration)
        @user.update!(state_registration: :approved)
      end
    end

    self
  end
end
