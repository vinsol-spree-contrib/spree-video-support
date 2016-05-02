//= require spree/support/skylink_video_support.js

/*  -------------------------------------------------------------------------------------------------------------------
  *=> Dependencies and Assumptions:
    - Depends on Skylink Javascript SDK for WebRTC support.
  *=> Process:
    - TODO
  *=> Arguments:
    - $joinChatButton - Call Support button which triggers video support.
    - $selfVideoElement - Video element for self stream view.
    - $container   - Video support view container.
    - options      - Default options overrides.
  ------------------------------------------------------------------------------------------------------------------ */
var AgentVideoSupport  = function($joinChatButton, $selfVideoElement, $container, options) {
  this.serviceResource = new SkylinkVideoSupport($selfVideoElement, $container.find('#spree-video-support-peervideo'), {
                          $statusElement: $container.find('#spree-video-support-status')
                        }); // Currently Skylink

  this.$joinChatButton = $joinChatButton;
  this.$container  = $container;
  this.initialized = false;

  this.options     = options || {};
  this.options     =  $.extend({}, this.defaults, this.options);

  // Initialize
  this.initialize();
}

// --------------------------------------------------------------------------------------------------------------------
// Section For Initialization
// --------------------------------------------------------------------------------------------------------------------
AgentVideoSupport.prototype.initialize = function() {
  var _this = this;

  $(document).on('video_support:service_events_binded', function() {
    _this.bindEvents();
  });
};

AgentVideoSupport.prototype.initializeService = function() {
  this.serviceResource.initializeService();
};

// --------------------------------------------------------------------------------------------------------------------
// Section For Default Options
// --------------------------------------------------------------------------------------------------------------------
AgentVideoSupport.prototype.defaults = {
  videoSupportScreenModalIdentifier : '#spree-video-support-modal'
};

// --------------------------------------------------------------------------------------------------------------------
// Section For Instance Methods
// --------------------------------------------------------------------------------------------------------------------
AgentVideoSupport.prototype.updateVideoStatus = function(message) {
  this.serviceResource.updateVideoStatus(message);
};

AgentVideoSupport.prototype.joinRoom = function(roomId) {
  this.serviceResource.joinRoom(roomId);
};

AgentVideoSupport.prototype.leaveRoom = function() {
  this.serviceResource.leaveRoom();
};

// --------------------------------------------------------------------------------------------------------------------
// Section For Events Binding
// --------------------------------------------------------------------------------------------------------------------
AgentVideoSupport.prototype.bindEvents = function() {
  this.bindAgentStreamLostEvent();
  this.bindJoinVideoSupportClickEvent();
};

AgentVideoSupport.prototype.bindAgentStreamLostEvent = function() {
  var _this = this;

  $(document).on('video_support:stream_ended', function(event, serviceResource, peerId, peerInfo, isSelf, isScreensharing) {
    if (!isSelf) {
      _this.updateVideoStatus('Waiting for customer to join back.');
      $('#' + peerId).remove();
    }
  });
};

// 1. If success.
  // 1a. Start the chat
  // 1b. Show message
  // 1c. Pause option? TODO
// 2. If error
  // 2a. Display error message
AgentVideoSupport.prototype.bindJoinVideoSupportClickEvent = function() {
  var _this = this;

  this.$joinChatButton.on('ajax:success', function(e, data, status, xhr) {
    _this.$container.removeClass('hidden');
    _this.initializeService();
    _this.updateVideoStatus('Joining video session with the customer.');
    _this.joinRoom(data.ticket_unique_id);
  })
  .on('ajax:error', function(e, xhr, status, error) {
    _this.$container.addClass('hidden');
    _this.updateVideoStatus('Error starting session: ' + xhr.responseJSON.errors);
  });
};

// --------------------------------------------------------------------------------------------------------------------
// Section to initialize the class on load
// --------------------------------------------------------------------------------------------------------------------

$(function() {
  new AgentVideoSupport($('#join_video_ticket_link'),
                          $('#spree-video-support-myvideo'),
                          $('.js-video-support-container')
                        );
});
