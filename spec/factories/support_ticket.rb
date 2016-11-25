FactoryGirl.define do
  factory :spree_support_ticket, class: Spree::SupportTicket do
    purpose { generate(:random_string) }
    customer_email { generate(:random_email) }
    customer_first_name { generate(:random_string) }
    customer_last_name { generate(:random_string) }
    support_started_at nil
    support_ended_at nil
    active true

    trait :inactive do
      active false
    end

    trait :unassigned do
      active true
      support_agent nil
    end

    trait :assigned do
      active true
      support_agent
    end

    trait :unresolved do
      active false
      support_ended_at nil
    end

    trait :picked do
      support_agent
      active true
    end

    trait :started do
      active true
      support_agent
      support_started_at { DateTime.now }
    end

    trait :ended do
      active true
      support_agent
      support_started_at { DateTime.current }
      support_ended_at   { support_started_at + (10.0 / (24 * 60 * 60)) }
    end

    trait :logged_in_customer do
      user
      customer_email nil
      customer_first_name nil
      customer_last_name nil
    end

    factory :spree_logged_in_customer_support_ticket, traits: [:logged_in_customer]
    factory :spree_active_support_ticket
    factory :spree_inactive_support_ticket, traits: [:inactive]
    factory :spree_unassigned_support_ticket, traits: [:unassigned]
    factory :spree_assigned_support_ticket, traits: [:assigned]
    factory :spree_unresolved_support_ticket, traits: [:unresolved]
    factory :spree_resolved_support_ticket, traits: [:assigned, :ended, :inactive]
    factory :spree_picked_support_ticket, traits: [:picked]
    factory :spree_started_support_ticket, traits: [:started]
    factory :spree_ended_support_ticket, traits: [:ended]
  end
end
