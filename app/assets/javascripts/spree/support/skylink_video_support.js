/*  -------------------------------------------------------------------------------------------------------------------
  *=> Dependencies and Assumptions:
    - Depends on Skylink Javascript SDK for WebRTC support.
  *=> Process:
    - TODO
  *=> Arguments:
    - $selfVideoElement           - Where owner's camera feed is displayed
    - $peerVideoElementContainer  - Where peer's camera feed is added
    - options                     - Default options overrides
  ------------------------------------------------------------------------------------------------------------------ */
var SkylinkVideoSupport  = function($selfVideoElement, $peerVideoElementContainer, options) {
  this.service      = undefined; // Currently Skylink
  this.initialized  = false;
  this.$selfVideoElement          = $selfVideoElement;
  this.$peerVideoElementContainer = $peerVideoElementContainer;

  this.options = options || {};
  this.options =  $.extend({}, this.defaults, this.options);

  // Initialize
  this.loadServiceSDKAndInitialize();
}

// --------------------------------------------------------------------------------------------------------------------
// Section For Initialization
// --------------------------------------------------------------------------------------------------------------------
SkylinkVideoSupport.prototype.loadServiceSDKAndInitialize = function() {
  var _this = this;

  $.getScript(SkylinkVideoSupport.config.serviceSDKUrl, function( data, textStatus, jqxhr ) {
    console.log('[SkylinkVideoSupport]' + textStatus ); // Success

    _this.service = new Skylink();

    console.log('[SkylinkVideoSupport] Skylink SDK loaded'); // Data returned
    _this.triggerEvent('service_loaded', [_this]);

    _this.setServiceLogLevel();
    _this.bindEvents();
  });
};

SkylinkVideoSupport.prototype.setServiceLogLevel = function() {
  this.service.setLogLevel(4);
};

SkylinkVideoSupport.prototype.initializeService = function() {
  var _this = this;

  if (!this.initialized) {
    this.service.init({
      apiKey: _this.getApiKey(),
      defaultRoom: _this.getRoomId()
    }, function (error, success) {
      if (error) {
        _this.triggerEvent('initialization_failed', [_this]);
        _this.updateVideoStatus(_this.options.messages.initializationFailed(error));
      } else {
        _this.initialized = true;
        _this.triggerEvent('initialized', [_this]);
        _this.updateVideoStatus(_this.options.messages.initialized());
      }
    });
  }
};

// --------------------------------------------------------------------------------------------------------------------
// Section For Default Options
// --------------------------------------------------------------------------------------------------------------------
SkylinkVideoSupport.prototype.defaults = {
  $statusElement: null,
  messages: {
    roomJoined: function() { return 'Joined support' },
    roomJoinError: function(error) { return ('Failed joining support.<br>' + 'Error: ' + (error.error.message || error.error)) },
    initializationFailed: function(error) { return ('Failed retrieval for room information.<br>Error: ' + (error.error.message || error.error)) },
    initialized: function() { return 'Ready for support' }
  }
};

SkylinkVideoSupport.config = {
  serviceSDKUrl : "https://cdn.temasys.com.sg/skylink/skylinkjs/0.6.x/skylink.complete.js"
};

// --------------------------------------------------------------------------------------------------------------------
// Section For Utility functions
// --------------------------------------------------------------------------------------------------------------------
SkylinkVideoSupport.prototype.getApiKey = function() {
  return window.videoSupportMainApiKey;
};

SkylinkVideoSupport.prototype.getRoomId = function() {
  return 'u_default_room';
};

SkylinkVideoSupport.prototype.triggerEvent = function(name, data) {
  // Triggering event on the body. Whichever element wants to listen for it, can.
  console.log('[SkylinkVideoSupport] Triggering ' + name + ' event');
  $(document).trigger('video_support:' + name, data);
};

SkylinkVideoSupport.prototype.updateVideoStatus = function(message) {
  if (!!this.options.$statusElement) {
    this.options.$statusElement.html(message);
  } else {
    console.log('[SkylinkVideoSupport] No update video status element defined');
  }
};

SkylinkVideoSupport.prototype.joinRoom = function(roomId) {
  var _this = this;

  console.log('[SkylinkVideoSupport] Room ID: ' + roomId);
  if (!roomId) { return; }

  this.service.joinRoom(roomId, {
    audio: true,
    video: true
  }, function (error, success) {
    if (error) {
      _this.updateVideoStatus(_this.options.messages.roomJoinError(error));
      _this.triggerEvent('room_joined_error', [_this, error]);
    } else {
      _this.updateVideoStatus(_this.options.messages.roomJoined());
      _this.triggerEvent('room_joined', [_this, success]);
    }
  });
};

SkylinkVideoSupport.prototype.leaveRoom = function() {
  var _this = this;

  this.service.leaveRoom(function(error, success) {
    if (error){
      console.log("[SkylinkVideoSupport] Error happened");
      _this.triggerEvent('room_left_error', [_this, error]);
    }
    else{
      console.log("[SkylinkVideoSupport] Successfully left room");
      _this.triggerEvent('room_left', [_this, success]);
    }
  });
};

SkylinkVideoSupport.prototype.stopStream = function() {
  this.service.stopStream();
};
// --------------------------------------------------------------------------------------------------------------------
// Section For Events Binding
// --------------------------------------------------------------------------------------------------------------------
SkylinkVideoSupport.prototype.bindEvents = function() {
  this.bindPeerJoinedEvent();
  this.bindIncomingStreamEvent();
  this.bindPeerLeftEvent();
  this.bindPeerUpdatedEvent();
  this.bindMediaAccessSuccessEvent();
  this.bindStreamEndedEvent();

  this.triggerEvent('service_events_binded', [this]);
};

SkylinkVideoSupport.prototype.bindPeerJoinedEvent = function() {
  var _this = this;

  this.service.on('peerJoined', function(peerId, peerInfo, isSelf) {
    if(isSelf) return; // We already have a video element for our video and don't need to create a new one.
    var vid = document.createElement('video');
    vid.autoplay = true;
    vid.muted = false; // Added to avoid feedback when testing locally
    vid.id = peerId;

    _this.$peerVideoElementContainer.append(vid);
  });
};

SkylinkVideoSupport.prototype.bindIncomingStreamEvent = function() {
  this.service.on('incomingStream', function(peerId, stream, isSelf) {
    if(isSelf) return;
    var vid = document.getElementById(peerId);
    attachMediaStream(vid, stream);
  });
};

SkylinkVideoSupport.prototype.bindPeerLeftEvent = function() {
  this.service.on('peerLeft', function(peerId, peerInfo, isSelf) {
    // Only if user is in no room, remove the peer video element
    if (!isSelf && !peerInfo.room) {
      $('#' + peerId).remove();
    }
  });
};

SkylinkVideoSupport.prototype.bindPeerUpdatedEvent = function() {
  var _this = this;

  this.service.on('peerUpdated', function(peerId, peerInfo, isSelf) {
    _this.triggerEvent('peer_updated', [_this, peerId, peerInfo, isSelf]);
  });
};

SkylinkVideoSupport.prototype.bindStreamEndedEvent = function() {
  var _this = this;
  this.service.on('streamEnded', function(peerId, peerInfo, isSelf, isScreensharing) {
    _this.triggerEvent('stream_ended', [_this, peerId, peerInfo, isSelf, isScreensharing]);
  });
};

SkylinkVideoSupport.prototype.bindMediaAccessSuccessEvent = function() {
  var _this = this;

  this.service.on('mediaAccessSuccess', function(stream) {
    attachMediaStream(_this.$selfVideoElement.get(0), stream);
  });
};
