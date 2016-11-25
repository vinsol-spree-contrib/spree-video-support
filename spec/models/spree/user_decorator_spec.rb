require 'spec_helper'

describe Spree.user_class, type: :model do
  describe 'Associations' do
    it { is_expected.to have_many(:inactive_support_responses).
                        class_name('Spree::SupportTicket').
                        conditions(active: false).
                        with_foreign_key('support_agent_id')
        }

    it { is_expected.to have_one(:active_support_response).
                        class_name('Spree::SupportTicket').
                        conditions(active: true).
                        with_foreign_key('support_agent_id')
        }

    it { is_expected.to have_many(:support_responses).
                        class_name('Spree::SupportTicket').
                        with_foreign_key('support_agent_id')
        }

    it { is_expected.to have_many(:inactive_support_requests).
                        class_name('Spree::SupportTicket').
                        conditions(active: false).
                        with_foreign_key('user_id')
        }

    it { is_expected.to have_one(:active_support_request).
                        class_name('Spree::SupportTicket').
                        conditions(active: true).
                        with_foreign_key('user_id')
        }

    it { is_expected.to have_many(:support_requests).
                        class_name('Spree::SupportTicket').
                        with_foreign_key('user_id')
        }
  end

end
