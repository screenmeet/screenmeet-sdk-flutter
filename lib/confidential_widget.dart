import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_plugin.dart';

///An example of how to use confidentiality feature
///
///ScreenMeetPlugin has interfaces to hide a number of rects and do not dispose confidential data when
///sharing the screen
class ConfidentialWidget extends StatefulWidget {

  ConfidentialWidget(this.key, this.child);

  final Key key;
  final Widget child;

  @override
  State<StatefulWidget> createState() => ConfidentialWidgetState();
}

class ConfidentialWidgetState extends State<ConfidentialWidget> {

  @override
  Widget build(BuildContext context) {
    var rect = new RectGetter.defaultKey(
        child: widget.child
    );

    //Pass the confidential area rect to the ScreenMeet SDK so it hides it when sharing screen
    ScreenMeetPlugin().attachConfidentialWidget(widget.key.toString(), rect);

    return rect;
  }
}