//
//  LocalVideoStreamHandler.swift
//  sdk_live_flutter_plugin
//
//  Created by Ross on 05.11.2021.
//

import Foundation
import Flutter
import ScreenMeetSDK

class LocalVideoStreamHandler: NSObject, FlutterStreamHandler {
    private let pm = SwiftChannelParamsManager()

    var sink: FlutterEventSink?
       
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
       
    func sendLocalVideo(_ localMediaState: SMParticipantMediaState, _ renderer: FlutterRTCVideoRenderer?) {
        guard let sink = sink else { return }
        sink(pm.localVideo(localMediaState, renderer))
    }
       
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}

