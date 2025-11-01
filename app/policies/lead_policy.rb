# app/policies/lead_policy.rb
class LeadPolicy < ApplicationPolicy
  def approve?
    return false unless user.present?
    return true  if user.superadmin?

    approver_lead_id = user.lead&.id
    return false unless approver_lead_id

    record.referral_lead_id == approver_lead_id || record.parent_id == approver_lead_id
  end

  class Scope < Scope
    def resolve
      if user&.superadmin?
        scope.all
      else
        scope.where(referral_lead_id: user.lead&.id)
             .or(scope.where(parent_id: user.lead&.id))
      end
    end
  end
end
