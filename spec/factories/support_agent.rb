FactoryGirl.define do
  factory :support_agent, parent: :user do
    spree_roles { [Spree::Role.find_by(name: 'support_agent') || create(:role, name: 'support_agent')] }
  end
end
