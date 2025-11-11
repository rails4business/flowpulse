# app/controllers/superadmin/leads_controller.rb
class Superadmin::LeadsController < ApplicationController
  before_action :require_authentication # o come lo chiami
  def index
  # lista di base
  base = policy_scope(Lead)
           .includes(:user)
           .left_outer_joins(:user)
           .order(created_at: :desc)

  # mapping enum (integer) -> valore; se hai enum string va comunque bene usando gli stessi simboli
  pending_val  = User.state_registrations[:pending]
  approved_val = User.state_registrations[:approved]
  rejected_val = User.state_registrations[:rejected]

  # filtro tab
  case params[:status].presence
  when "pending"
    # pending = user pending OPPURE lead senza user (non registrato)
    @leads = base.where(users: { state_registration: pending_val })
                 .or(base.where(users: { id: nil }))
                 .distinct
  when "approved"
    @leads = base.where(users: { state_registration: approved_val }).distinct
  when "rejected"
    @leads = base.where(users: { state_registration: rejected_val }).distinct
  else
    @leads = base # all
  end

  # counts per badge
  counts_base = policy_scope(Lead).left_outer_joins(:user)
  @counts = {
    "all"      => counts_base.distinct.count,
    "pending"  => counts_base.where(users: { state_registration: pending_val })
                             .or(counts_base.where(users: { id: nil }))
                             .distinct.count,
    "approved" => counts_base.where(users: { state_registration: approved_val }).distinct.count,
    "rejected" => counts_base.where(users: { state_registration: rejected_val }).distinct.count
  }
end

    def approve
    authorize @lead, :approve?

    user = @lead.user || User.find_by(email: @lead.email)

    if user
      # collega il lead se manca
      user.update!(lead: @lead) if user.lead_id != @lead.id
      user.state_registration_approved!
    else
      user = User.create!(
        email: @lead.email,
        name:  @lead.name,
        password: SecureRandom.hex(8),
        lead: @lead,
        state_registration: :approved
      )
    end

    redirect_to [ :superadmin, @lead ], notice: "Lead approvato. User ##{user.id} ⇒ #{user.state_registration}."
  end

  def reject
    lead = Lead.find(params[:id])
    authorize lead, :reject?
    lead.update!(status: "rejected")
    redirect_to superadmin_leads_path(status: "pending"), notice: "Lead rifiutato."
  end
end
