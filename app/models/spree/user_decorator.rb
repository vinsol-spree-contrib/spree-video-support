Spree.user_class.class_eval do
  # TODO: Need better names. Maybe active_support_response / active_support_request
  has_many :inactive_support_responses, -> { where(active: false) }, foreign_key: 'support_agent_id', class_name: Spree::SupportTicket
  has_one  :active_support_response, -> { where(active: true) }, foreign_key: 'support_agent_id', class_name: Spree::SupportTicket
  has_many  :support_responses, foreign_key: 'support_agent_id', class_name: Spree::SupportTicket

  has_many :inactive_support_requests, -> { where(active: false) }, foreign_key: 'user_id', class_name: Spree::SupportTicket
  has_one  :active_support_request, -> { where(active: true) }, foreign_key: 'user_id', class_name: Spree::SupportTicket
  has_many :support_requests, foreign_key: 'user_id', class_name: Spree::SupportTicket
end
