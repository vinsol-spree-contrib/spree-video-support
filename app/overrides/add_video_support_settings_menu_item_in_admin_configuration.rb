Deface::Override.new(virtual_path: 'spree/admin/shared/sub_menu/_configuration',
  name: 'add_video_support_settings_menu_item_in_admin_configuration',
  insert_bottom: "#sidebar-configuration",
  text: "
    <%= configurations_sidebar_menu_item(Spree.t(:video_support_settings), spree.edit_admin_video_support_settings_path) if can? :manage, Spree::Config %>
  ")
