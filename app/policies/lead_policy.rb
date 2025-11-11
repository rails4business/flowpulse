# app/policies/lead_policy.rb
class LeadPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.superadmin?
      return scope.where(center_id: user.center_id) if user&.tutor?
      scope.none
    end
  end

  def index?   = owner_or_admin? # || user&.tutor?
  def show?    = owner_or_admin? #
  def approve? = owner_or_admin? #  || (user&.tutor? && in_scope?)
  def reject?  = owner_or_admin?
  def update?  = owner_or_admin?

  private

  def owner_or_admin?
    user&.superadmin? || (user.present? && record.id == user.id)
  end
end
