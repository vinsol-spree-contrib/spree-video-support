require 'spec_helper'
require 'cancan/matchers'

RSpec.describe Spree::AbilityDecorator, type: :model do
  it 'registers itself in Spree::Ability' do
    expect(Spree::Ability.abilities).to include(Spree::AbilityDecorator)
  end

  context 'permissions' do
    let(:user) { FactoryGirl.create(:user) }
    let(:admin) { FactoryGirl.create(:admin_user) }
    let(:support_agent) { FactoryGirl.create(:support_agent) }

    context 'when user is blank' do
      let(:ability) { Spree::AbilityDecorator.new(nil) }

      it { expect(ability).to_not be_able_to(:manage, Spree::SupportTicket.new) }
    end

    context 'when user is normal user' do
      let(:ability) { Spree::AbilityDecorator.new(user) }

      it { expect(ability).to_not be_able_to(:manage, Spree::SupportTicket.new) }
    end

    context 'when user is admin user' do
      let(:ability) { Spree::AbilityDecorator.new(admin) }

      it { expect(ability).to be_able_to(:manage, Spree::SupportTicket.new) }
    end

    context 'when user is support_agent' do
      let(:ability) { Spree::AbilityDecorator.new(support_agent) }

      it { expect(ability).to be_able_to(:manage, Spree::SupportTicket.new) }
    end
  end
end
