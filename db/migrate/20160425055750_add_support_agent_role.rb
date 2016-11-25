class AddSupportAgentRole < ActiveRecord::Migration
  def up
    Spree::Role.find_or_create_by!(name: 'support_agent')
  end
end
