//= require spree/shared/skylink_video_support.js

/*  -------------------------------------------------------------------------------------------------------------------
  *=> Dependencies and Assumptions:
    - Depends on Skylink Javascript SDK for WebRTC support.
  *=> Process:
    - TODO
  *=> Arguments:
    - $actionsContainer - Contains actions for interacting with ticket
    - $supportContainer - Contains self and peer video elements
    - options      - Default options overrides.
  ------------------------------------------------------------------------------------------------------------------ */
var AgentVideoSupport  = function($actionsContainer, $supportContainer, options) {
  this.$actionsContainer   = $actionsContainer;
  this.$supportContainer   = $supportContainer;
  this.$joinChatButton     = this.$actionsContainer.find('#join_video_ticket_link');
  this.$closeChatButton    = this.$actionsContainer.find('#close_video_ticket_link');
  this.$videoContainer     = this.$supportContainer.find('#spree-video-support-start');
  this.$selfVideoElement   = this.$supportContainer.find('#spree-video-support-myvideo');
  this.$peerVideoContainer = this.$supportContainer.find('#spree-video-support-peervideo');

  this.initialized = false;
  this.options     = options || {};
  this.options     =  $.extend({}, this.defaults, this.options);

  // Initialize
  this.initialize();
  this.serviceResource = new SkylinkVideoSupport(this.$selfVideoElement, this.$peerVideoContainer, {
                          $statusElement: this.$supportContainer.find('#spree-video-support-status')
                        }); // Currently Skylink

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

// --------------------------------------------------------------------------------------------------------------------
// Section For Default Options
// --------------------------------------------------------------------------------------------------------------------
AgentVideoSupport.prototype.defaults = {
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

AgentVideoSupport.prototype.showVideoSupportContainer = function() {
  this.$supportContainer.removeClass('hidden');
};

AgentVideoSupport.prototype.hideVideoSupportContainer = function() {
  this.$supportContainer.addClass('hidden');
};

// --------------------------------------------------------------------------------------------------------------------
// Section For Events Binding
// --------------------------------------------------------------------------------------------------------------------
AgentVideoSupport.prototype.bindEvents = function() {
  this.bindAgentStreamLostEvent();
  this.bindJoinVideoSupportClickEvent();
  this.bindCloseVideoSupportClickEvent();
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
    _this.$supportContainer.removeClass('hidden');
    _this.updateVideoStatus('Joining video session with the customer.');
    _this.joinRoom(data.ticket_unique_id);
  })
  .on('ajax:error', function(e, xhr, status, error) {
    _this.$supportContainer.addClass('hidden');
    _this.updateVideoStatus('Error starting session: ' + xhr.responseJSON.errors);
  });
};

// 1. If success.
  // 1a. Stop the chat and signal it to customer
  // 1b. Show message
  // 1c. Refresh the page
// 2. If error
  // 2a. Display error message
AgentVideoSupport.prototype.bindCloseVideoSupportClickEvent = function() {
  var _this = this;

  this.$closeChatButton.on('ajax:success', function(e, data, status, xhr) {
    _this.hideVideoSupportContainer();
    _this.serviceResource.setUserData({ leavingRoom: true });
    _this.leaveRoom();
    _this.serviceResource.stopStream();
    _this.serviceResource.setUserData({ leavingRoom: false });
    _this.updateVideoStatus('Ticket closed.');
    window.location.reload();
  })
  .on('ajax:error', function(e, xhr, status, error) {
    _this.updateVideoStatus('Error stopping session: ' + xhr.responseJSON.errors);
  });
};

// --------------------------------------------------------------------------------------------------------------------
// Section to initialize the class on load
// --------------------------------------------------------------------------------------------------------------------

$(function() {
  new AgentVideoSupport(  $('.js-ticket-actions'),
                          $('.js-video-support-container')
                        );
});
