require 'spec_helper'

describe Spree::SupportTicket, type: :model do

  describe 'Validations' do
    context 'when user is present' do
      subject { FactoryGirl.create(:spree_support_ticket) }

      it { is_expected.to validate_presence_of(:customer_first_name) }
      it { is_expected.to validate_presence_of(:customer_email) }
    end

    describe '#support_agent_role' do
      context 'when support_agent is present and has proper role' do
        subject { FactoryGirl.create(:spree_assigned_support_ticket) }

        describe '#support_agent_role' do
          it 'ensures support agent has valid role' do
            expect(subject.support_agent.spree_roles).to include(Spree::Role.find_or_create_by!(name: 'support_agent'))
          end
        end
      end

      context 'when support_agent is present and has improper role' do
        let(:admin) { FactoryGirl.create(:admin_user) }
        subject { FactoryGirl.build(:spree_assigned_support_ticket, support_agent: admin) }

        describe '#support_agent_role' do
          it 'ensures support agent has valid role' do
            expect(subject.valid?).to be_falsy
          end
        end
      end
    end

    it { is_expected.to validate_presence_of(:purpose) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:support_agent).class_name(Spree.user_class.name) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'Callbacks' do
    describe '#assign_user_attributes' do
      context 'when user is present' do
        let(:user) { FactoryGirl.create(:user) }
        subject { FactoryGirl.create(:spree_logged_in_customer_support_ticket, user: user) }

        it { is_expected.to callback(:assign_user_attributes).before(:validation) }

        it 'assigns user attributes' do
          expect(subject.customer_first_name).to eq(user.try(:first_name))
          expect(subject.customer_last_name).to eq(user.try(:last_name))
          expect(subject.customer_email).to eq(user.try(:email))
        end
      end
    end

    context 'when ticket_unique_id is blank' do
      subject { FactoryGirl.create(:spree_logged_in_customer_support_ticket) }

      it { is_expected.to callback(:assign_unique_id).before(:create) }
      it 'assigns unique ticket id' do
        expect(subject.unique_id.class).to eq(String)
        expect(subject.unique_id.present?).to eq(true)
      end
    end
  end

  describe 'Scopes' do
    describe '::active' do
      let!(:active_tickets) { FactoryGirl.create_list(:spree_active_support_ticket, 3) }
      let!(:inactive_tickets) { FactoryGirl.create_list(:spree_inactive_support_ticket, 3) }

      it 'returns active support tickets' do
        expect(described_class.active.pluck(:id).sort).to eq(active_tickets.map(&:id).sort)
      end
    end

    describe '::inactive' do
      let!(:active_tickets) { FactoryGirl.create_list(:spree_active_support_ticket, 3) }
      let!(:inactive_tickets) { FactoryGirl.create_list(:spree_inactive_support_ticket, 3) }

      it 'returns inactive support tickets' do
        expect(described_class.inactive.pluck(:id).sort).to eq(inactive_tickets.map(&:id).sort)
      end
    end
  end

  describe 'Instance Methods' do
    describe '#active_duration' do
      context 'when ticket not started' do
        let(:ticket) { FactoryGirl.create(:spree_support_ticket) }

        it 'returns 0' do
          expect(ticket.active_duration).to eq(0)
        end
      end

      context 'when ticket started and ended' do
        let(:ticket) { FactoryGirl.create(:spree_ended_support_ticket) }

        xit 'returns 10' do
          expect(ticket.active_duration).to eq(10)
        end
      end

      context 'when ticket started but not ended' do
        let(:ticket) { FactoryGirl.create(:spree_started_support_ticket) }
        before { allow(DateTime).to receive(:current) { ticket.support_started_at + (5.0 / (24 * 60 * 60)) } }

        xit 'returns 5' do
          expect(ticket.active_duration).to eq(5)
        end
      end
    end

    describe '#status' do
      context 'when ticket is active and unassigned' do
        let(:ticket) { FactoryGirl.create(:spree_unassigned_support_ticket) }
        it 'returns Unassigned' do
          expect(ticket.status).to eq('Unassigned')
        end
      end

      context 'when ticket is active and assigned' do
        let(:ticket) { FactoryGirl.create(:spree_assigned_support_ticket) }
        it 'returns Assigned' do
          expect(ticket.status).to eq('Assigned')
        end
      end

      context 'when ticket is inactive and unassigned' do
        let(:ticket) { FactoryGirl.create(:spree_unresolved_support_ticket) }
        it 'returns Unresolved' do
          expect(ticket.status).to eq('Unresolved')
        end
      end

      context 'when ticket is inactive, assigned and not started' do
        let(:ticket) { FactoryGirl.create(:spree_unresolved_support_ticket, support_agent: FactoryGirl.create(:support_agent)) }
        it 'returns Unresolved' do
          expect(ticket.status).to eq('Unresolved')
        end
      end

      context 'when ticket is active, assigned and started' do
        let(:ticket) { FactoryGirl.create(:spree_started_support_ticket) }
        it 'returns `In Progress`' do
          expect(ticket.status).to eq('In Progress')
        end
      end

      context 'when ticket is inactive, assigned and started' do
        let(:ticket) { FactoryGirl.create(:spree_unresolved_support_ticket, support_agent: FactoryGirl.create(:support_agent), support_started_at: DateTime.now) }
        it 'returns Unresolved' do
          expect(ticket.status).to eq('Unresolved')
        end
      end

      context 'when ticket is active, assigned and ended' do
        let(:ticket) { FactoryGirl.create(:spree_ended_support_ticket) }
        it 'returns Assigned' do
          expect(ticket.status).to eq('Assigned')
        end
      end

      context 'when ticket is inactive, assigned and ended' do
        let(:ticket) { FactoryGirl.create(:spree_resolved_support_ticket) }
        it 'returns Resolved' do
          expect(ticket.status).to eq('Resolved')
        end
      end
    end

    describe '#pickable?' do
      context 'when ticket active' do
        context 'when support_agent is blank' do
          let(:ticket) { FactoryGirl.create(:spree_unassigned_support_ticket) }
          it 'returns true' do
            expect(ticket.pickable?).to eq(true)
          end
        end

        context 'when support_agent is present' do
          let(:ticket) { FactoryGirl.create(:spree_assigned_support_ticket) }
          it 'returns false' do
            expect(ticket.pickable?).to eq(false)
          end
        end
      end

      context 'when ticket inactive' do
        let(:ticket) { FactoryGirl.create(:spree_inactive_support_ticket) }
        it 'returns false' do
          expect(ticket.pickable?).to eq(false)
        end
      end
    end

    describe '#owner?' do
      let(:agent) { FactoryGirl.create(:support_agent) }

      context 'when agent is owner of ticket' do
        context 'when support_agent is blank' do
          let(:ticket) { FactoryGirl.create(:spree_unassigned_support_ticket) }
          it 'returns false' do
            expect(ticket.owner?(agent)).to eq(false)
          end
        end

        context 'when passed agent is blank' do
          let(:ticket) { FactoryGirl.create(:spree_unassigned_support_ticket) }
          it 'returns false' do
            expect(ticket.owner?(nil)).to eq(false)
          end
        end

        context 'when support_agent and agent are present' do
          let(:ticket) { FactoryGirl.create(:spree_assigned_support_ticket, support_agent: agent) }
          it 'returns true' do
            expect(ticket.owner?(agent)).to eq(true)
          end
        end
      end

      context 'when agent is not the owner of ticket' do
        let(:ticket) { FactoryGirl.create(:spree_inactive_support_ticket) }
        context 'when support_agent is blank' do
          let(:ticket) { FactoryGirl.create(:spree_unassigned_support_ticket) }
          it 'returns false' do
            expect(ticket.owner?(agent)).to eq(false)
          end
        end

        context 'when passed agent is blank' do
          let(:ticket) { FactoryGirl.create(:spree_assigned_support_ticket) }
          it 'returns false' do
            expect(ticket.owner?(nil)).to eq(false)
          end
        end

        context 'when support_agent and agent are present' do
          let(:ticket) { FactoryGirl.create(:spree_assigned_support_ticket) }
          it 'returns false' do
            expect(ticket.owner?(agent)).to eq(false)
          end
        end
      end
    end

    describe '#open?' do
      context 'when ticket active' do
        context 'when support_agent is blank' do
          let(:ticket) { FactoryGirl.create(:spree_unassigned_support_ticket) }
          it 'returns false' do
            expect(ticket.open?).to eq(false)
          end
        end

        context 'when support_agent is present' do
          context 'when ticket not closed' do
            let(:started_ticket) { FactoryGirl.create(:spree_started_support_ticket) }
            let(:not_started_ticket) { FactoryGirl.create(:spree_assigned_support_ticket) }

            it 'returns true for started ticket' do
              expect(started_ticket.open?).to eq(true)
            end

            it 'returns true for not started ticket' do
              expect(not_started_ticket.open?).to eq(true)
            end
          end
          context 'when ticket closed' do
            let(:ticket) { FactoryGirl.create(:spree_ended_support_ticket) }
            it 'returns false' do
              expect(ticket.open?).to eq(false)
            end
          end
        end
      end

      context 'when ticket inactive' do
        let(:ticket) { FactoryGirl.create(:spree_inactive_support_ticket) }
        it 'returns false' do
          expect(ticket.open?).to eq(false)
        end
      end
    end

    describe '#closed?' do
      context 'when ticket inactive' do
        context 'when support_agent is blank' do
          let(:ticket) { FactoryGirl.create(:spree_unassigned_support_ticket) }
          it 'returns false' do
            expect(ticket.closed?).to eq(false)
          end
        end

        context 'when support_agent is present' do
          context 'when ticket not closed' do
            let(:ticket) { FactoryGirl.create(:spree_unresolved_support_ticket, support_agent: FactoryGirl.create(:support_agent)) }

            it 'returns false' do
              expect(ticket.closed?).to eq(false)
            end
          end
          context 'when ticket closed' do
            let(:ticket) { FactoryGirl.create(:spree_resolved_support_ticket) }
            it 'returns true' do
              expect(ticket.closed?).to eq(true)
            end
          end
        end
      end

      context 'when ticket active' do
        let(:ticket) { FactoryGirl.create(:spree_active_support_ticket) }
        it 'returns false' do
          expect(ticket.closed?).to eq(false)
        end
      end
    end

    describe '#in_progress?' do
      context 'when ticket open' do
        let(:ticket) { FactoryGirl.create(:spree_support_ticket) }
        before { allow(ticket).to receive(:open?) { true } }

        context 'when ticket started' do
          before { ticket.support_started_at = DateTime.current }
          it 'returns true' do
            expect(ticket.in_progress?).to eq(true)
          end
        end
        context 'when ticket not started' do
          before { ticket.support_started_at = nil }
          it 'returns false' do
            expect(ticket.in_progress?).to eq(false)
          end
        end
      end

      context 'when ticket not open' do
        let(:ticket) { FactoryGirl.create(:spree_support_ticket) }
        before { allow(ticket).to receive(:open?) { false } }
        it 'returns false' do
          expect(ticket.in_progress?).to eq(false)
        end
      end
    end

    describe '#start' do
      # TODO
    end

    describe '#end' do
      # TODO
    end

    describe '#customer_name' do
      # TODO
    end
  end

end
