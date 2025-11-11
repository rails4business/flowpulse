# app/policies/lead_policy.rb
class LeadPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.superadmin?
      return scope.where(center_id: user.center_id) if user&.tutor?
      scope.none
    end
  end

  def index?   = user&.superadmin? # || user&.tutor?
  def show?    = index? && in_scope? #
  def approve? = user&.superadmin? #  || (user&.tutor? && in_scope?)
  def reject?  = approve?


  private

  def in_scope?
    return true if user&.superadmin?
       scope.all
  end
end
