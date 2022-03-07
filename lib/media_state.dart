
/// Keeps the information about the state of media features (audio, video, screen sharing)
///
/// This media state can be a remote participant's media state or your local media state
/// This class is used for both
class MediaState {

  bool _isSharingVideo = false;
  bool _isSharingAudio = false;
  bool _isSharingScreen = false;

  ///Default constructor sets all media features
  MediaState(this._isSharingVideo, this._isSharingAudio, this._isSharingScreen);

  /// Factory constructor that just makes new empty instance with all media features (audio, video, screen sharing) marked as stopped
  factory MediaState.stopped() {
    return MediaState(false, false, false);
  }

  ///Whether video from camera is being shared
  bool get isSharingVideo => _isSharingVideo;

  ///Whether audio is being shared
  bool get isSharingAudio => _isSharingAudio;

  ///Whether screen sharing is on
  bool get isSharingScreen => _isSharingScreen;
}