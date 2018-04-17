class AddSupportAgentRole < SpreeExtension::Migration[4.2]
  def up
    Spree::Role.find_or_create_by!(name: 'support_agent')
  end
end
