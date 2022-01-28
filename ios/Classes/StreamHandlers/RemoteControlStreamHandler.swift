//
//  RemoteControlStreamHandler.swift
//  sdk_live_flutter_plugin
//
//  Created by Ross on 25.01.2022.
//

import Foundation
import Flutter
import ScreenMeetSDK

class RemoteControlStreamHandler: NSObject, FlutterStreamHandler {
    private let pm = SwiftChannelParamsManager()

    var sink: FlutterEventSink?
       
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
       
    func sendRemoteEvent(_ event: SMRemoteControlEvent) {
        guard let sink = sink else { return }
        sink(pm.remoteControlEventToDict(event))
    }
       
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}
