import 'package:flutter/material.dart';
import 'package:screenmeet_sdk_flutter/media_state.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_plugin.dart';

/// A widget that allows to interact with a call
///
/// It contains mute, video, screen share buttons. User can turn on/off his audio, video, screen capture when
/// being on a call
class CallControlsWidget extends StatefulWidget {
  CallControlsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CallControlsState();
  }
}

class _CallControlsState extends State<CallControlsWidget> {

  /// The state of your own media during the call (audio, video, screen sharing)
  MediaState mediaState = MediaState.stopped();

  _CallControlsState();

  void updateCallControlsState(MediaState newMediaState) async {
    setState(() {
      this.mediaState = newMediaState;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      this.mediaState = new MediaState.stopped();
    });

    updateCurrentMediaState();

    ScreenMeetPlugin().setLocalMediaStateListener(listener: (MediaState mediaState) {
      updateCallControlsState(mediaState);
    });
  }

  void updateCurrentMediaState() async {
    var response = await ScreenMeetPlugin().getLocalMediaState();

    response.fold(
            (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.text))),
            (mediaState) =>setState(() { this.mediaState = mediaState;})
    );

  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children:
          [TextButton(
            onPressed: () async {
              if (mediaState.isSharingAudio) {
                await ScreenMeetPlugin().stopAudioSharing();
              }
              else {
                await ScreenMeetPlugin().shareAudio();
              }
            },
            child: Icon(mediaState.isSharingAudio ? Icons.mic : Icons.mic_off, color: Colors.white, size: 20),
            style: ElevatedButton.styleFrom(
                minimumSize: Size(10, 10),
                shape: CircleBorder(),
                padding: EdgeInsets.all(14),
                primary: mediaState.isSharingAudio ? Colors.orange : Colors.black54,
                onPrimary: Colors.white30,
              ),
            ),
            SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                if (mediaState.isSharingVideo) {
                  await ScreenMeetPlugin().stopVideoSharing();
                }
                else {
                  await ScreenMeetPlugin().shareVideo(CameraType.front);
                }
              },
              child: Icon(mediaState.isSharingVideo ? Icons.videocam : Icons.videocam_off, color: Colors.white, size: 20),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(10, 10),
                shape: CircleBorder(),
                padding: EdgeInsets.all(14),
                primary: mediaState.isSharingVideo ? Colors.orange : Colors.black54,
                onPrimary: Colors.white30,
              ),
            ),
            SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                if (mediaState.isSharingScreen) {
                  await ScreenMeetPlugin().stopVideoSharing();
                }
                else {
                  await ScreenMeetPlugin().shareScreen();
                }
              },
              child: Icon(mediaState.isSharingScreen ? Icons.mobile_screen_share : Icons.mobile_off, color: Colors.white, size: 20),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(10, 10),
                shape: CircleBorder(),
                padding: EdgeInsets.all(14),
                primary: mediaState.isSharingScreen ? Colors.orange : Colors.black54,
                onPrimary: Colors.white30,
              ),
            ),
            SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                await ScreenMeetPlugin().disconnect();
              },
              child: Icon(Icons.phone, color: Colors.white, size: 20),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(10, 10),
                shape: CircleBorder(),
                padding: EdgeInsets.all(14),
                primary: Colors.red,
                onPrimary: Colors.white30,
              ),
            )]);
  }
}
