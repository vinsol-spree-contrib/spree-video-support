Deface::Override.new(virtual_path: 'spree/shared/_nav_bar',
  name: 'add_video_support_link_in_header',
  insert_before: "#search-bar",
  text: "
    <button class='btn btn-primary js-video-support-btn'>Video Support</button>
    <%= render partial: 'spree/shared/video_support_modal' %>
  ")
