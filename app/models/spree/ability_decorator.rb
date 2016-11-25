# Implementation class for Cancan gem.  Instead of overriding this class, consider adding new permissions
# using the special +register_ability+ method which allows extensions to add their own abilities.
#
# See http://github.com/ryanb/cancan for more details on cancan.
require 'cancan'
module Spree
  class AbilityDecorator
    include CanCan::Ability

    Spree::Ability.register_ability(Spree::AbilityDecorator)

    def initialize(user)
      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('support_agent')
        can :manage, Spree::SupportTicket # TODO: Remove this line
        can [:read, :update, :start, :destroy], Spree::SupportTicket do |ticket|
          ticket.support_agent.blank? || ticket.support_agent == user
        end
      end
      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('admin')
        can :manage, Spree::SupportTicket
      end
    end
  end
end
