import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:screenmeet_sdk_flutter/confidential_widget.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_parameters_manager.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_plugin.dart';
import 'package:screenmeet_flutter_plugin_example/local_video_widget.dart';

import 'package:screenmeet_sdk_flutter/remote_control_events.dart';

import 'call_controls_widget.dart';
import 'remote_participants_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: "HelveticaNeue", visualDensity: VisualDensity.adaptivePlatformDensity,),
      home: _ScreenMeetConnectPage(),
    );
  }
}

/// Initial screen of the app
///
/// Contains a "room code" text field and connect button
/// The textfield input should be either 6 digit room-code or a full 12 characters room id
class _ScreenMeetConnectPage extends StatefulWidget {
  _ScreenMeetConnectPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConnectState();
  }

}

class _ConnectState extends State<_ScreenMeetConnectPage> {

  bool isConnecting = false;

  /// room textfield controller
  final TextEditingController roomEditingController = TextEditingController(text: "");

  _ConnectState();

  @override
  void initState() {
    super.initState();

    //Subscribe for connection changes
    ScreenMeetPlugin().setConnectionStateListener(listener: (String connectionState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connection state: "  + connectionState)));

      //Go to main screen if connected (entered the room successfully)
      if (connectionState == ScreenMeetConnectionState.connected)  {
        Navigator.push(context, PageRouteBuilder(pageBuilder: (c, a1, a2) => _ScreenMeetDemoPage(), transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child), transitionDuration: Duration(milliseconds: 800)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(height: 100),
          Image.asset("assets/flutter.png", height: 160.0, width: 160.0,),
          SizedBox(height: 60),
          Padding(padding: const EdgeInsets.fromLTRB(100.0, 0, 100.0, 0.0), child: Center(
              child: TextField(
                  onSubmitted: (newValue){},
                  textAlign: TextAlign.center,
                  autofocus: true,
                  controller: roomEditingController)),
          ),
          SizedBox(height: 10),

          Padding(padding: const EdgeInsets.fromLTRB(100.0, 0, 100.0, 0.0), child: SizedBox(width: double.infinity, child:  ElevatedButton(
            onPressed: () async {
              setState(() { isConnecting = true;});

              //Connect to the room
              var response = await ScreenMeetPlugin().connect(roomEditingController.text, "Flutter guy");

              response.fold(
                      (error) =>  {
                        //kErrorKnowEntryPermissionRequired means that host has to let us in the room
                        if (error.code == ScreenMeetErrorCode.kErrorKnowEntryPermissionRequired) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.text), backgroundColor: Colors.orange))
                        }
                        else {
                          setState(() { isConnecting = false;}),
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.text)))
                        }
                      },
                      (success) => {
                        setState(() { isConnecting = false;}),
                        Navigator.push(context, PageRouteBuilder(pageBuilder: (c, a1, a2) => _ScreenMeetDemoPage(), transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child), transitionDuration: Duration(milliseconds: 800)))
                      }
              );
            },
            child: Text('Connect',style: TextStyle(fontFamily: 'HelveticeNeue-Light', fontWeight: FontWeight.w300, fontSize: 16)),
          ))),
          SizedBox(height: 12),
          isConnecting ? Container(margin: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 12.0), child: CircularProgressIndicator(strokeWidth: 1.0)) : Container(),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text( "Powered by Screenmeet ©", style: TextStyle(fontSize: 12.0)), SizedBox(width: 4), Image(width: 22, height: 22, image: AssetImage('assets/screenmeet.png'))])
        ]));
  }
}

/// Main screen of the app
///
/// This screen contains call control buttons (audio, video, screen sharing), remote participants video views and local video view
class _ScreenMeetDemoPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ScreenMeetDemoPageState();
  }
}

class _ScreenMeetDemoPageState extends State<_ScreenMeetDemoPage> {

  void tap(Offset pos){
    final result = HitTestResult();
    WidgetsBinding.instance!.hitTest(result, pos);
    result.path.forEach((element) {
      element.target.handleEvent(
        PointerDownEvent(
            position: pos,
            kind: PointerDeviceKind.touch),
        element,
      );
      element.target.handleEvent(
        PointerUpEvent(
            position: pos,
            kind: PointerDeviceKind.touch),
        element,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    //Subscribe for remote control events
    ScreenMeetPlugin().setRemoteControlListener(listener: (RemoteControlEvent event) {
      if (event is RemoteControlMouseEvent && event.actionType == RemoteControlMouseActionType.leftdown) {
        tap(Offset(event.x, event.y));
      }
    });


    //Subscribe for connection changes
    ScreenMeetPlugin().setConnectionStateListener(listener: (String connectionState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connection state: "  + connectionState)));

      //Go to initial connect screen if disconnected
      if (connectionState == ScreenMeetConnectionState.disconnected)  {
        Navigator.pop(context);
      }

    });

    /*
    Future.delayed(const Duration(milliseconds: 3000), () {
      tap(Offset(200, 750));
      tap(Offset(100, 750));
      ScreenMeetPlugin().emitBounds();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 120),
            RemoteParticipantsWidget(),
            SizedBox(height: 32.0),
            CallControlsWidget(),
            SizedBox(height: 30),
            ConfidentialWidget(
              Key("text"),
              Text('[confidential widget]', style: TextStyle(fontSize: 12.0)),
            ),
            SizedBox(height: 5),
            Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: 50.0,
                child: ListView(
                  // This next line does the trick.
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Container(
                      width: 160.0,
                      color: Colors.black12,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.black38,
                    ),
                    ConfidentialWidget(
                        Key("confidential"),
                        Container(
                          width: 160.0,
                          color: Colors.orangeAccent,
                        )
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.black12,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.black38,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.orangeAccent,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.black12,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.black38,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.orangeAccent,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.black12,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.black38,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.orangeAccent,
                    ),
                    Container(
                      width: 160.0,
                      color: Colors.black12,
                    )
                  ],
                )
            ),

          ],
        ),
        Positioned(top: 40, left: 10, child: LocalVideoWidget()),
        Positioned(child: new Align(alignment: FractionalOffset.bottomCenter, child: Padding(padding: const EdgeInsets.fromLTRB(0.0, 0, 0.0, 24.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text( "Powered by Screenmeet ©", style: TextStyle(fontSize: 12.0)), SizedBox(width: 4), Image(width: 22, height: 22, image: AssetImage('assets/screenmeet.png'))])))),
      ]),
    );
  }
}
