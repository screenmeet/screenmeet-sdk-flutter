//
//  PermissionRequestStreamHandler.swift
//  sdk_live_flutter_plugin
//
//  Created by Ross on 04.02.2022.
//

import Foundation
import Flutter
import ScreenMeetSDK

class FeatureRequestStreamHandler: NSObject, FlutterStreamHandler {
    private let pm = SwiftChannelParamsManager()

    var sink: FlutterEventSink?
       
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
       
    func sendPersmissionRequest(_ feature: SMFeature) {
        guard let sink = sink else { return }
        sink(pm.featureToDict(feature))
    }
       
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}
