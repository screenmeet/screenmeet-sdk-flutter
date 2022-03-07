import 'package:screenmeet_sdk_flutter/screenmeet_connect_error.dart';

import 'feature_request.dart';
import 'local_video.dart';
import 'media_state.dart';
import 'participant.dart';
import 'remote_control_events.dart';
import 'screenmeet_error.dart';
import 'screenmeet_plugin.dart';

///Contains all the string constants to convert from native SDK objects into flutter objects
///
/// Normally this class is only used by [ScreenMeetPlugin] internally, however some parts
/// of it may be helpful for some general tasks

class ScreenMeetParametersManager {
  final String _kSetConfigCommand = "setConfig";
  final String _kConnectCommand = "connect";
  final String _kDisconnectCommand = "disconnect";
  final String _kConnectUserName = "connectUserName";
  final String _kConnectRoomId = "connectRoomId";

  final String _kShareScreenCommand = "shareScreen";
  final String _kStopSharingVideoCommand = "stopSharingVideo";
  final String _kStopSharingAudioCommand = "stopSharingAudio";
  final String _kChangeVideoSourceCommand = "changeVideoSource";
  final String _kShareVideoCommand = "shareVideo";
  final String _kShareAudioCommand = "shareAudio";
  final String _kGetMediaStateCommand = "getMediaState";
  final String _kGetParticipantsCommand = "getParticipants";
  final String _kGetLocalVideoCommand = "getLocalVideo";

  final String _kShareVideoCameraType = "shareVideoCameraType";

  final String  _kFeatureGrantAccessCommand = "featureGrantAccess";
  final String  _kFeatureRejectAccessCommand = "featureRejectAccess";

  final String _kAudioEnabled = "audioEnabled";
  final String _kVideoEnabled = "videoEnabled";
  final String _kScreenEnabled = "screenEnabled";

  final String _kLocalParticipant = "localParticipant";
  final String _kParticipants = "participants";
  final String _kParticipantId = "participantId";
  final String _kParticipantName = "participantName";
  final String _kTextureId = "textureId";
  final String _kOn = "isOn";

  final String _kOrganizationKey = "organizationKey";
  final String _kCollectMetrics = "collectMetrics";
  final String _kEndpoint = "endpoint";
  final String _kLogLevel = "logLevel";

  final String _kId = "id";
  final String _kX = "x";
  final String _kY = "y";
  final String _kWidth = "width";
  final String _kHeight = "height";

  final String _kResultStatus = "resultStatus";
  final String _kErrorText = "errorText";
  final String _kErrorCode = "errorCode";
  final String _kChallengeError = "challenge";
  final String _kChallengeSolution = "challengeSolution";
  final String _kSolveChallenge = "solveChallenge";

  final String _kSetConfidential = "setConfidential";
  final String _kUnSetConfidential = "unsetConfidential";

  final String _kRemoteControlEventType = "remoteControlEventType";
  final String _kRemoteControlEventTypeMouse = "mouse";
  final String _kRemoteControlEventTypeKeyboard = "keyboard";

  final String _kRemoteControlEventFrom = "remoteControlEventFrom";
  final String _kRemoteControlEventTo = "remoteControlEventTo";
  final String _kRemoteControlEventTs = "remoteControlEventTs";

  final String _kRemoteControlEventMouseActionType = "mouseActionType";
  final String _kRemoteControlEventKeyboardActionType = "keyboardActionType";

  final String _kRemoteControlEventTypeMouseX = "remoteControlEventTypeMouseX";
  final String _kRemoteControlEventTypeMouseY = "remoteControlEventTypeMouseY";
  final String _kRemoteControlEventKeyboardKey = "remoteControlEventKeyboardKey";

  final String _kFeatureType = "featureType";
  final String _kFeatureRequestorId = "featureRequestorId";
  final String _kFeatureRequestorName = "featureRequestorName";

  String get kSetConfigCommand  => _kSetConfigCommand;
  String get kConnectCommand  => _kConnectCommand;
  String get kDisconnectCommand => _kDisconnectCommand;
  String get kConnectUserName => _kConnectUserName;
  String get kConnectRoomId => _kConnectRoomId;

  String get kShareScreenCommand => _kShareScreenCommand;
  String get kStopSharingVideoCommand => _kStopSharingVideoCommand;
  String get kStopSharingAudioCommand => _kStopSharingAudioCommand;
  String get kChangeVideoSourceCommand => _kChangeVideoSourceCommand;
  String get kShareVideoCommand => _kShareVideoCommand;
  String get kShareAudioCommand => _kShareAudioCommand;
  String get kGetMediaStateCommand => _kGetMediaStateCommand;
  String get kGetParticipantsCommand => _kGetParticipantsCommand;
  String get kGetLocalVideoCommand => _kGetLocalVideoCommand;

  String get kShareVideoCameraType => _kShareVideoCameraType;

  String get kFeatureGrantAccessCommand => _kFeatureGrantAccessCommand;
  String get kFeatureRejectAccessCommand => _kFeatureRejectAccessCommand;

  String get kAudioEnabled => _kAudioEnabled;
  String get kVideoEnabled => _kVideoEnabled;
  String get kScreenEnabled => _kScreenEnabled;

  String get kLocalParticipant => _kLocalParticipant;
  String get kParticipants => _kParticipants;
  String get kParticipantId => _kParticipantId;
  String get kParticipantName => _kParticipantName;
  String get kTextureId => _kTextureId;
  String get kOn => _kOn;

  String get kId => _kId;
  String get kX => _kX;
  String get kY => _kY;
  String get kWidth => _kWidth;
  String get kHeight => _kHeight;

  String get kOrganizationKey => _kOrganizationKey;
  String get kCollectMetrics => _kCollectMetrics;
  String get kEndpoint => _kEndpoint;
  String get kLogLevel => _kLogLevel;

  String get kResultStatus => _kResultStatus;
  String get kErrorText => _kErrorText;
  String get kErrorCode => _kErrorCode;
  String get kChallengeError => _kChallengeError;
  String get kChallengeSolution => _kChallengeSolution;
  String get kSolveChallenge => _kSolveChallenge;

  String get kSetConfidential => _kSetConfidential;
  String get kUnSetConfidential => _kUnSetConfidential;

  String get kRemoteControlEventType => _kRemoteControlEventType;
  String get kRemoteControlEventTypeMouse => _kRemoteControlEventTypeMouse;
  String get kRemoteControlEventTypeKeyboard => _kRemoteControlEventTypeKeyboard;

  String get kRemoteControlEventFrom => _kRemoteControlEventFrom;
  String get kRemoteControlEventTo => _kRemoteControlEventTo;
  String get kRemoteControlEventTs => _kRemoteControlEventTs;

  String get kRemoteControlEventMouseActionType => _kRemoteControlEventMouseActionType;
  String get kRemoteControlEventKeyboardActionType => _kRemoteControlEventKeyboardActionType;

  String get kRemoteControlEventTypeMouseX => _kRemoteControlEventTypeMouseX;
  String get kRemoteControlEventTypeMouseY => _kRemoteControlEventTypeMouseY;

  String get kRemoteControlEventKeyboardKey => _kRemoteControlEventKeyboardKey;

  String get kFeatureType => _kFeatureType;
  String get kFeatureRequestorId => _kFeatureRequestorId;
  String get kFeatureRequestorName => _kFeatureRequestorName;

  bool isSuccess(Map map) {
    return map[_kResultStatus] == true;
  }

  ScreenMeetError error(Map map) {
    return ScreenMeetError(map[_kErrorText], map[_kErrorCode]);
  }

  ScreenMeetConnectError connectError(Map map) {
    return ScreenMeetConnectError(map[_kErrorText], map[_kErrorCode], map[_kChallengeError]);
  }

  MediaState mediaState(Map params) {
    MediaState newMediaState = MediaState(params[_kVideoEnabled], params[_kAudioEnabled], params[_kScreenEnabled]);
    return newMediaState;
  }

  LocalVideo localVideo(Map params)  {
    LocalVideo localVideo = LocalVideo(params[_kOn], params[_kTextureId]);
    return localVideo;
  }

  List<Participant> participants(List participantsArray) {
    List<Participant> participants = [];

    for (final participantDict in participantsArray) {

      MediaState mediaState = MediaState(participantDict[_kVideoEnabled], participantDict[_kAudioEnabled], participantDict[_kScreenEnabled]);
      Participant p = Participant(participantDict[_kParticipantId], participantDict[_kParticipantName], participantDict[_kTextureId], mediaState);
      participants.add(p);
    }

    return participants;
  }

  Participant participant(Map participantDict) {
    MediaState mediaState = MediaState(participantDict[_kVideoEnabled], participantDict[_kAudioEnabled], participantDict[_kScreenEnabled]);
    Participant participant = Participant(participantDict[_kParticipantId], participantDict[_kParticipantName], participantDict[_kTextureId], mediaState);
    return participant;
  }

  RemoteControlEvent remoteControlEvent(Map eventDict) {
    // fromId and toId are not yet passed from screenmeet SDK. Needs to be fixes.
    if (eventDict[_kRemoteControlEventType] == _kRemoteControlEventTypeKeyboard) {
      return RemoteControlKeyboardEvent("fromId", "toId", 0, eventDict[_kRemoteControlEventKeyboardKey]);
    }

    return RemoteControlMouseEvent("fromId", "toId", 0, eventDict[_kRemoteControlEventTypeMouseX], eventDict[_kRemoteControlEventTypeMouseY], eventDict[_kRemoteControlEventMouseActionType]);
  }

  FeatureRequest featureRequest(Map featureDict) {
    FeatureRequest featureRequest =  FeatureRequest(featureDict[_kFeatureRequestorId], featureDict[_kFeatureRequestorName], featureDict[_kFeatureType]);
    return featureRequest;
  }
}

///All connection states for screenmeet SDK
class ScreenMeetConnectionState {
  static const String connecting = "connecting";
  static const String connected = "connected";
  static const String reconnecting = "reconnecting";
  static const String disconnected = "disconnected";
  static const String waitingEntrancePermission = "waitingEntrancePermission";
}

///All error codes sent back to flutter from native SDK
class ScreenMeetErrorCode {
  //Some parameter name is wrong when using [MethodChannel].invokeMethod
  static const int kErrorCodeWrongMethodParameters = 1001;

  // Could not connect to the room. Either room code is wrong or some other conditions did not allow SDK to connect
  static const int kErrorCodeConnectFailed = 1002;

  //Could not find the requested participant
  static const int kErrorCodeNoParticipantFound = 1003;

  //Permission from the host is needed to enter the room
  static const int kErrorKnowEntryPermissionRequired = 1004;

  //User required to complete captcha
  static const int kErrorCaptchaRequired = 1005;
}