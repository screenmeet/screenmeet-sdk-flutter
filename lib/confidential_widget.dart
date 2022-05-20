import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';

import 'screenmeet_plugin.dart';

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

class ConfidentialWidgetState extends State<ConfidentialWidget> with WidgetsBindingObserver {

  late RectGetter rect;

  @override
  Widget build(BuildContext context) {
    rect = new RectGetter.defaultKey(
        child: widget.child
    );
    ScreenMeetPlugin().attachConfidentialWidget(widget.key.toString(), rect);
    return rect;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void activate() {
    super.activate();
    ScreenMeetPlugin().attachConfidentialWidget(widget.key.toString(), rect);
  }

  @override
  void deactivate() {
    super.deactivate();
    ScreenMeetPlugin().unsetConfidential(widget.key.toString());
  }
}