Deface::Override.new(virtual_path: 'spree/shared/_nav_bar',
  name: 'add_video_support_link_in_header',
  insert_after: "#search-bar",
  text: "
    <li><a href='#' class='js-video-support-btn btn btn-info'>Video Support</a></li>
    <%= render partial: 'spree/shared/video_support_modal' %>
  ")
