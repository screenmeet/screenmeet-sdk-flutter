//
//  SwiftChannelConstants.swift
//  sdk_live_flutter_plugin
//
//  Created by Ross on 27.10.2021.
//

import UIKit
import ScreenMeetSDK

enum CameraType: String {
    case front = "front"
    case back = "back"
}

class SwiftChannelParamsManager: NSObject {
    let kSetConfigCommand = "setConfig"
    let kConnectCommand = "connect"
    let kDisconnectCommand = "disconnect"
    let kConnectUserName = "connectUserName"
    let kConnectRoomId = "connectRoomId"
    
    let kShareScreenCommand = "shareScreen"
    let kShareVideoCommand = "shareVideo"
    let kStopSharingVideoCommand = "stopSharingVideo"
    let kShareAudioCommand = "shareAudio"
    let kStopSharingAudiCommand = "stopSharingAudio"
    let kGetMediaStateCommand = "getMediaState"
    let kGetParticipantsCommand = "getParticipants";
    let kShareVideoCameraType = "shareVideoCameraType"
    let kGetLocalVideoCommand = "getLocalVideo";
    let kChangeVideoSourceCommand = "changeVideoSource";
    
    let kSetConfidetianlRectCommand = "setConfidential"
    let kUnsetConfidetianlRectCommand = "unsetConfidential"
    
    let kFeatureGrantAccessCommand = "featureGrantAccess"
    let kFeatureRejectAccessCommand = "featureRejectAccess"

    let kAudioEnabled = "audioEnabled"
    let kVideoEnabled = "videoEnabled"
    let kScreenEnabled = "screenEnabled"
        
    let kParticipants = "participants"
    let kParticipantId = "participantId"
    let kParticipantName = "participantName"
    let kTextureId = "textureId"
    let kOn = "isOn"
    
    let kOrganizationKey = "organizationKey";
    let kCollectMetrics = "collectMetrics";
    let kEndpoint = "endpoint";
    let kLogLevel = "logLevel";
    
    let kId = "id"
    let kX = "x"
    let kY = "y"
    let kWidth = "width"
    let kHeight = "height"
    
    let kResultStatus = "resultStatus"
    let kErrorText = "errorText"
    let kErrorCode = "errorCode"
    
    let kRemoteControlEventType = "remoteControlEventType"
    let kRemoteControlEventTypeMouse = "mouse"
    let kRemoteControlEventTypeKeyboard = "keyboard"
    
    let kRemoteControlEventFrom = "remoteControlEventFrom"
    let kRemoteControlEventTo = "remoteControlEventTo"
    
    let kRemoteControlEventTs = "remoteControlEventTs"
    
    let kRemoteControlEventMouseActionType = "mouseActionType"
    let kRemoteControlEventKeyboardActionType = "keyboardActionType"
    
    let kRemoteControlEventTypeMouseX = "remoteControlEventTypeMouseX"
    let kRemoteControlEventTypeMouseY = "remoteControlEventTypeMouseY"
    
    let kRemoteControlEventKeyboardKey = "remoteControlEventKeyboardKey"
    
    let kFeatureType = "featureType"
    let kFeatureRequestorId = "featureRequestorId"
    let kFeatureRequestorName = "featureRequestorName"
    
    //Error codes
    
    let kErrorCodeWrongMethodParameters = 1001
    let kErrorCodeConnectFailed = 1002
    let kErrorCodeNoParticipantFound = 1003
    let kErrorKnowEntryPermissionRequired = 1004
    
    func error(_ text: String, _ code: Int) -> [String: Any] {
        return [kResultStatus: false, kErrorText: text, kErrorCode: code]
    }
    
    func success(_ params: [String: Any]? = nil) -> [String: Any] {
        if var params = params {
            params[kResultStatus] = true
            return params;
        }
        
        return [kResultStatus: true]
    }
    
    func mediaStateToDict(_ mediaState: SMParticipantMediaState, _ renderer: FlutterRTCVideoRenderer?) -> [String: Any] {
        let dict = [kVideoEnabled: mediaState.isVideoActive && mediaState.videoState == .CAMERA,
                    kAudioEnabled: mediaState.isAudioActive,
                    kScreenEnabled: mediaState.isVideoActive && mediaState.videoState == .SCREEN]
        return dict
    }
    
    func participantsToDict(_ participants: [SMParticipant], _ renderers: [String: FlutterRTCVideoRenderer]) -> [String: Any] {
        var dict = [String: Any]()
        
        var array = [[String: Any]]()
        for p in participants {
            array.append([kParticipantId: p.id,
                        kParticipantName: p.name,
                        kTextureId: renderers[p.id]?.textureId ?? -1,
                        kVideoEnabled: p.avState.isVideoActive && p.avState.videoState == .CAMERA,
                        kAudioEnabled: p.avState.isAudioActive,
                        kScreenEnabled: p.avState.isVideoActive && p.avState.videoState == .SCREEN])
        }
        
        dict[kParticipants] = array;
        return dict
    }
    
    func remoteControlEventToDict(_ event: SMRemoteControlEvent) -> [String: Any] {
        var dict = [String: Any]()
        
        if let event = event as? SMRemoteControlMouseEvent {
            dict[kRemoteControlEventType] = kRemoteControlEventTypeMouse
            dict[kRemoteControlEventTypeMouseX] = event.x
            dict[kRemoteControlEventTypeMouseY] = event.y
            dict[kRemoteControlEventMouseActionType] = event.type.rawValue
            
        }
        else  if let event = event as? SMRemoteControlKeyboardEvent {
            dict[kRemoteControlEventType] = kRemoteControlEventTypeKeyboard
            dict[kRemoteControlEventKeyboardKey] = event.key
            dict[kRemoteControlEventKeyboardActionType] = event.type.rawValue
        }
        
        return dict
    }
    
    
    func featureToDict(_ feature: SMFeature) -> [String: Any] {
        var dict = [String: Any]()
        dict[kFeatureType] = feature.type.rawValue
        dict[kFeatureRequestorId] = feature.requestorParticipant.id
        dict[kFeatureRequestorName] = feature.requestorParticipant.name
        return dict
    }
    
    func localVideo(_ mediaState: SMParticipantMediaState, _ renderer: FlutterRTCVideoRenderer?) -> [String: Any] {
        let dict = [kOn: mediaState.isVideoActive && mediaState.videoState  == .CAMERA,
                    kTextureId: renderer?.textureId ?? -1] as [String : Any]
        
        return dict
    }
    
}
