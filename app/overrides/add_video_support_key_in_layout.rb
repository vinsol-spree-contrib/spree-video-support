Deface::Override.new(virtual_path: 'spree/layouts/spree_application',
  name: 'add_video_support_key_in_layout',
  insert_after: "body",
  text: "
    <script>window.videoSupportMainApiKey = '<%= Spree::Config['video_support_main_api_key'] %>'</script>
  ")
