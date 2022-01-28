import 'dart:async';
import 'dart:ffi';

import 'package:either_dart/either.dart';
import 'package:flutter/services.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:screenmeet_sdk_flutter/local_video.dart';
import 'package:screenmeet_sdk_flutter/media_state.dart';
import 'package:screenmeet_sdk_flutter/participant.dart';
import 'package:screenmeet_sdk_flutter/remote_control_events.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_error.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_parameters_manager.dart';

class ScreenMeetPlugin {

  static final ScreenMeetPlugin _singleton = ScreenMeetPlugin._internal();
  factory ScreenMeetPlugin() { return _singleton; }
  ScreenMeetPlugin._internal() {
    _init();
  }

  final ScreenMeetParametersManager _pm = ScreenMeetParametersManager();

  MethodChannel _channel = const MethodChannel('sdk_live_flutter_plugin');
  // The channel to receive events notifying about your local media state change (when muting/unmuting, turning on video, screen share)
  final EventChannel _localMediaStateEventChannel = EventChannel('platform_channel_events/screenmeet/localMediaState');

  //The channel to receive events when new participant joins/leaves
  final EventChannel _participantsEventChannel = EventChannel('platform_channel_events/screenmeet/remoteParticipants');

  // The channel to receive local video-related events from ScreenMeet SDK
  final EventChannel _localVideoEventChannel = EventChannel('platform_channel_events/screenmeet/localVideo');

  // The channel to receive events about change of connection state of ScreenMeet SDK
  final EventChannel _connectionStateEventChannel = EventChannel('platform_channel_events/screenmeet/connectionState');

  // The channel to receive remote control events from ScreenMeet SDK
  final EventChannel _remoteControlEventChannel = EventChannel('platform_channel_events/screenmeet/remoteControl');

  Map _confidentialWidgets = Map<String, RectGetter>();

  // Listener for local media state changes. Will be fired when audio, video, screen sharing is turned on/off
  void Function(MediaState)? _localMediaStateListener;

  // Listener for remote participants. Will be  fired when participant joins or leaves the room
  void Function(List<Participant>)? _participantsListener;

  //Listener for local video itself. Will be fired when video from the camera of your device is started/stopped
  void Function(LocalVideo)? _localVideoListener;

  //Listener for connection state of the SDK. Will be fired when room is connected, disconnected, reconnecting, waiting for host to let in, etc
  void Function(String)? _connectionStateListener;

  //Listener for remote control events send by SDK. Will be fired when remote control is granted by you and the participant is clicking mouse, hits kehboard, etc
  void Function(RemoteControlEvent)? _remoteControlListener;

  void _init(){
    _channel.setMethodCallHandler(handle);

    //setup event channels that should receive events from native SDK

    _localMediaStateEventChannel
        .receiveBroadcastStream()
        .listen(_onLocalMediaStateEvent, onError: _onLocalMediaStateError);

    _participantsEventChannel
        .receiveBroadcastStream()
        .listen(_onParticipantEvent, onError: _onParticipantError);

    _localVideoEventChannel
        .receiveBroadcastStream()
        .listen(_onLocalVideoEvent, onError: _onLocalVideoError);

    _connectionStateEventChannel
        .receiveBroadcastStream()
        .listen(_onConnectionStateEvent, onError: _onConnectionStateEvent);

    _remoteControlEventChannel
        .receiveBroadcastStream()
        .listen(_onRemoteControlEvent, onError: _onRemoteControlError);
  }

  // Set the listener for remote participants. Will be  fired when participant joins or leaves the room
  void setParticipantsListener({Function(List<Participant>)? listener}){
    _participantsListener = listener;
  }

  ///Participant event occured
  void _onParticipantEvent(var eventMap) {
    List<Participant> newParticipants = _pm.participants(eventMap[_pm.kParticipants]);

    if (_participantsListener != null) {
      _participantsListener!(newParticipants);
    }
  }

  void _onParticipantError(Object error) {
    _participantsListener!(List.empty());
  }

  // Set the listener for local media state changes. Will be fired when audio, video, screen sharing is turned on/off
  void setLocalMediaStateListener({Function(MediaState)? listener}){
    _localMediaStateListener = listener;
  }

  ///Local media state has changed (either audio, video, or screen was turned on/off)
  void _onLocalMediaStateEvent(var eventMap) async {
    MediaState mediaState = _pm.mediaState(eventMap);

    if (_localMediaStateListener != null) {
      _localMediaStateListener!(mediaState);
    }

  }

  void _onLocalMediaStateError(Object error) {
    _localMediaStateListener!(MediaState(false, false, false));
  }

  ///Set the listener for local video itself. Will be fired when video from the camera of your device is started/stopped
  void setLocalVideoListener({Function(LocalVideo)? listener}){
    _localVideoListener = listener;
  }

  //Local video has either started or stopped
  void _onLocalVideoEvent(var eventMap) {
    LocalVideo localVideo = _pm.localVideo(eventMap);

    if (_localVideoListener != null) {
      _localVideoListener!(localVideo);
    }

  }

  void _onLocalVideoError(Object error) {
    _localVideoListener!(LocalVideo(false, -1));
  }

  ///Set the listener for connection state of the SDK. Will be fired when room is connected, disconnected, reconnecting, waiting for host to let inm etc
  void setConnectionStateListener({Function(String)? listener}){
    _connectionStateListener = listener;
  }

  void _onConnectionStateEvent(var connectionState) {
    if (_connectionStateListener != null) {
      _connectionStateListener!(connectionState as String);
    }

  }

  void _onConnectionStateError(Object error) {

  }

  ///Set the listener for remote control events sent by SDK. Will be fired when remote control is granted and the participant clicks mouse or keyboard
  void setRemoteControlListener({Function(RemoteControlEvent)? listener}){
    _remoteControlListener = listener;
  }

  void _onRemoteControlEvent(var eventMap) {
    if (_remoteControlListener != null) {
      RemoteControlEvent event = _pm.remoteControlEvent(eventMap);
      _remoteControlListener!(event);
    }

  }

  void _onRemoteControlError(Object error) {

  }

  Future<void> handle(MethodCall call) async {
    switch(call.method) {
      case "getConfidentialBounds":
        emitBounds();
    }
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  void attachConfidentialWidget(String id, RectGetter getter){
    _confidentialWidgets[id] = getter;
  }

  void emitBounds(){
    _confidentialWidgets.forEach((k, v) {
      var rectPos = v.getRect();
      if(rectPos != null){
          //debugPrint('LOG: $k  ${rectPos.left} ${rectPos.width} ${rectPos.top} ${rectPos.height}');
          setConfidential(k, rectPos.left, rectPos.top, rectPos.width, rectPos.height);
      }
    });
  }

  /// Pass the confidential rect to native SDK. This rect will be cut/hidden when sharing video(stream of your screen) with remote participants
  void setConfidential(String id, double x, double y, double width, double height) {
    var map = <String, dynamic>{
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height
    };

    _channel.invokeMethod(_pm.kSetConfidential, map);
  }

  void unsetConfidential(String id) {
    _channel.invokeMethod(_pm.kUnSetConfidential, id);
  }

  ///Connect to the room. Room id is either 6 digits code or 12 letters full room id. userName is your user name that other participants will see
  Future<Either<ScreenMeetError, bool>> connect(String roomId, String userName) async {
    final Map result = await _channel.invokeMethod(_pm.kConnectCommand, {_pm.kConnectRoomId: roomId, _pm.kConnectUserName: userName});

    if (_pm.isSuccess(result)) { return Right(true);}
    return Left(_pm.error(result));
  }

  Future<Either<ScreenMeetError, bool>> disconnect() async {
    final Map result = await _channel.invokeMethod(_pm.kDisconnectCommand);

    if (_pm.isSuccess(result)) { return Right(true);}
    return Left(_pm.error(result));
  }

  ///Start sharing video from your camera
  ///
  /// For now cameraType can be either front or back. See [CameraType]
  Future<Either<ScreenMeetError, bool>> shareVideo(String cameraType) async {
    final Map result = await _channel.invokeMethod(_pm.kShareVideoCommand, {_pm.kShareVideoCameraType: cameraType});

    if (_pm.isSuccess(result)) { return Right(true);}
    return Left(_pm.error(result));
  }

  ///Stop sharing your video
  Future<Either<ScreenMeetError, bool>> stopVideoSharing() async {
    final Map result = await _channel.invokeMethod(_pm.kStopSharingVideoCommand);

    if (_pm.isSuccess(result)) { return Right(true);}
    return Left(_pm.error(result));
  }

  ///Start sharing audio from your mic
  Future<Either<ScreenMeetError, bool>> shareAudio() async {
    final Map result = await _channel.invokeMethod(_pm.kShareAudioCommand);

    if (_pm.isSuccess(result)) { return Right(true);}
    return Left(_pm.error(result));
  }

  ///Stop sharing your audio
  Future<Either<ScreenMeetError, bool>> stopAudioSharing() async {
    final Map result = await _channel.invokeMethod(_pm.kStopSharingAudioCommand);

    if (_pm.isSuccess(result)) { return Right(true);}
    return Left(_pm.error(result));
  }

  ///Responds with your local media state (states of your video, audio, screen sharing)
  Future<Either<ScreenMeetError, MediaState>> getLocalMediaState() async {
    final Map result = await _channel.invokeMethod(_pm.kGetMediaStateCommand);
    if (_pm.isSuccess(result)) { return Right(_pm.mediaState(result));}
    return Left(_pm.error(result));
  }

  ///Responds with the list of remote participants on a call
  Future<Either<ScreenMeetError, List<Participant>>> getParticipants() async {
    final Map result = await _channel.invokeMethod(_pm.kGetParticipantsCommand);
    if (_pm.isSuccess(result)) { return Right(_pm.participants(result[_pm.kParticipants]));}
    return Left(_pm.error(result));
  }

  ///Changes the source of the video that you are sharing. Either from camera to screen or vice versa
  Future<Map> changeVideoSource() async {
    final Map result = await _channel.invokeMethod(_pm.kChangeVideoSourceCommand);
    return result;
  }

  ///Responds with your local video. The return object will contain the flag indicating if video is on and textureId for its rendering or -1
  Future<Either<ScreenMeetError, LocalVideo>> getLocalVideo() async {
    final Map result = await _channel.invokeMethod(_pm.kGetLocalVideoCommand);
    if (_pm.isSuccess(result)) { return Right(_pm.localVideo(result));}
    return Left(_pm.error(result));
  }

  ///Share the screen of your device
  Future<Map> shareScreen() async {
    final Map result = await _channel.invokeMethod(_pm.kShareScreenCommand);
    return result;
  }

}

///Camera types to share in the call
class CameraType {
  static String front = "front";
  static String back = "back";
}