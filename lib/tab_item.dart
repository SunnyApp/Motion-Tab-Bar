import 'package:flutter/material.dart';

import 'motion_tab_bar.dart';

const double ICON_OFF = -3;
const double ICON_ON = 0;
const double TEXT_OFF = 3;
const double TEXT_ON = 1;
const double ALPHA_OFF = 0;
const double ALPHA_ON = 1;
const int ANIM_DURATION = 300;

typedef TabCallback = void Function([bool fromController]);

class TabItem extends StatefulWidget {
  final String title;
  final bool selected;
  final IconData iconData;
  final TextStyle textStyle;
  final TabCallback callbackFunction;
  final Color tabIconColor, tabSelectedColor;

  const TabItem({
    @required this.title,
    @required this.selected,
    @required this.iconData,
    @required this.textStyle,
    @required this.tabIconColor,
    @required this.tabSelectedColor,
    @required this.callbackFunction,
  });

  @override
  _TabItemState createState() => _TabItemState();
}

class _TabItemState extends State<TabItem> {
  double iconYAlign = ICON_ON;
  double textYAlign = TEXT_OFF;
  double iconAlpha = ALPHA_ON;

  @override
  void initState() {
    super.initState();
    _setIconTextAlpha();
  }

  @override
  void didUpdateWidget(TabItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setIconTextAlpha();
  }

  void _setIconTextAlpha() {
    setState(() {
      iconYAlign = (widget.selected) ? ICON_OFF : ICON_ON;
      textYAlign = (widget.selected) ? TEXT_ON : TEXT_OFF;
      iconAlpha = (widget.selected) ? ALPHA_OFF : ALPHA_ON;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              alignment: Alignment(0, textYAlign),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.title,
                  style: widget.textStyle,
                ),
              ),
            ),
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: ANIM_DURATION),
              curve: Curves.easeIn,
              alignment: Alignment(0, iconYAlign),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: ANIM_DURATION),
                opacity: iconAlpha,
                child: IconButton(
                  enableFeedback: false,
                  visualDensity: VisualDensity.compact,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  padding: const EdgeInsets.all(0),
                  alignment: const Alignment(0, 0),
                  icon: Icon(widget.iconData, color: widget.tabIconColor),
                  onPressed: () {
                    widget.callbackFunction();
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
