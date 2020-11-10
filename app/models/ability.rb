# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can [:show, :edit, :update], User, id: user.id
    can :read, :map

    if user.admin?
      can :manage, :all
    end
  end
end
