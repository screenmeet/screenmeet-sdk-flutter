//
//  ParticipantsStreamHandler.swift
//  sdk_live_flutter_plugin
//
//  Created by Ross on 01.11.2021.
//

import Foundation
import Flutter
import ScreenMeetSDK

class ParticipantsStreamHandler: NSObject, FlutterStreamHandler {
    private let pm = SwiftChannelParamsManager()

    var sink: FlutterEventSink?
       
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
       
    func sendParticipants(_ participants: [SMParticipant], _ renderers: [String: FlutterRTCVideoRenderer]) {
        guard let sink = sink else { return }
        sink(pm.participantsToDict(participants, renderers))
    }
       
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}
