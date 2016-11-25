Deface::Override.new(virtual_path: 'spree/admin/shared/_head',
  name: 'add_video_support_key_in_support_layout_head',
  insert_after: "erb[loud]:contains('yield :head')",
  text: "
    <script>window.videoSupportMainApiKey = '<%= Spree::Config['video_support_main_api_key'] %>'</script>
  ")
