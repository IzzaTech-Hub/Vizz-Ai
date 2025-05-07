import 'dart:async';
import 'package:flutter/material.dart';
import 'package:napkin/app/data/size_config.dart';

class TouchToSplitBox extends StatefulWidget {
  @override
  _TouchToSplitBoxState createState() => _TouchToSplitBoxState();
}

class _TouchToSplitBoxState extends State<TouchToSplitBox> {
  bool _split = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Toggle the state every 1 second
    _timer = Timer.periodic(Duration(seconds: 2), (_) {
      setState(() {
        _split = !_split;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical * 20,
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // TEXT SECTION
            AnimatedContainer(
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              width: _split
                  ? SizeConfig.screenWidth * 0.35
                  : SizeConfig.screenWidth * 0.65,
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: _split
                    ? Column(
                        key: ValueKey('linesView'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _lineBar(30),
                          _lineBar(26),
                          _lineBar(22),
                          _lineBar(18),
                        ],
                      )
                    : Column(
                        key: ValueKey('touchView'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: SizeConfig.blockSizeHorizontal * 2),
                            child: Icon(Icons.touch_app,
                                size: 40, color: Colors.white),
                          ),
                          Text(
                            "Touch to stylize content...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
              ),
            ),

            // GRAPH SECTION
            Expanded(
              child: AnimatedOpacity(
                opacity: _split ? 1.0 : 0.0,
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 600),
                child: _split
                    ? Container(
                        // color: Colors.amber,
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.bar_chart,
                              size: 60, color: Colors.redAccent),
                        ),
                      )
                    : SizedBox.shrink(
                        key: ValueKey('emptybox'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lineBar(double widthPercent) {
    return Container(
      width: SizeConfig.blockSizeHorizontal * widthPercent,
      height: 8,
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
    );
  }
}
