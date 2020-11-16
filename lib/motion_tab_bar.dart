library motion_tab_bar;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

import 'tab_item.dart';

export 'motion_tab_bar.dart';
export 'motion_tab_bar_view.dart';
export 'motion_tab_controller.dart';
export 'tab_item.dart';

typedef MotionTabBuilder = Widget Function();

typedef OnTabSelected = void Function(int index);

class TabInfo {
  final int index;
  final String label;
  final IconData icon;

  TabInfo({@required this.label, @required this.icon, this.index});

  TabInfo withIndex(int index) {
    return TabInfo(index: index, label: label, icon: icon);
  }
}

class MotionTabBar extends StatefulWidget {
  final Color tabIconColor, tabSelectedColor, tabIconSelectedColor;
  final TextStyle textStyle;
  final OnTabSelected onTabItemSelected;
  final String initialSelectedTab;
  final List<TabInfo> items;

  factory MotionTabBar.of({
    @required TextStyle textStyle,
    @required Color tabIconColor,
    @required Color tabSelectedColor,
    Color tabIconSelectedColor = CupertinoColors.white,
    OnTabSelected onTabItemSelected,
    @required String initialSelectedTab,
    @required List<String> labels,
    @required List<IconData> icons,
  }) {
    var i = 0;
    final items = labels.map((label) {
      var icon = icons[i];

      i++;
      return TabInfo(
        label: label,
        icon: icon,
      );
    });

    return MotionTabBar(
        textStyle: textStyle,
        tabIconColor: tabIconColor,
        tabSelectedColor: tabSelectedColor,
        onTabItemSelected: onTabItemSelected,
        initialSelectedTab: initialSelectedTab,
        tabIconSelectedColor: tabIconSelectedColor,
        items: items);
  }

  const MotionTabBar({
    this.textStyle,
    this.tabIconSelectedColor = CupertinoColors.white,
    this.tabIconColor,
    this.tabSelectedColor,
    this.onTabItemSelected,
    this.initialSelectedTab,
    this.items,
  })  : assert(initialSelectedTab != null),
        assert(tabSelectedColor != null),
        assert(tabIconSelectedColor != null),
        assert(tabIconColor != null),
        assert(textStyle != null);

  @override
  _MotionTabBarState createState() => _MotionTabBarState();
}

class _MotionTabBarState extends State<MotionTabBar>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Tween<double> _positionTween;
  Animation<double> _positionAnimation;

  AnimationController _fadeOutController;
  Animation<double> _fadeFabOutAnimation;
  Animation<double> _fadeFabInAnimation;

  // List<String> labels;
  // Map<String, IconData> icons;

  int get tabAmount => widget.items.length;
  int get index => selectedTabItem?.index ?? 0;

  get position {
    double pace = 2 / (tabAmount - 1);
    return (pace * index) - 1;
  }

  double fabIconAlpha = 1;
  IconData activeIcon;
  String selectedTab;

  Map<String, TabInfo> tabItems;

  TabInfo get selectedTabItem => tabItems[selectedTab];

  @override
  void initState() {
    super.initState();

    int i = 0;
    tabItems = widget.items.asMap().map((_, value) {
      return MapEntry(value.label, value.withIndex(i++));
    });

    selectedTab = widget.initialSelectedTab;
    activeIcon = selectedTabItem?.icon;

    _animationController = AnimationController(
      duration: Duration(milliseconds: ANIM_DURATION),
      vsync: this,
    );

    _fadeOutController = AnimationController(
      duration: Duration(milliseconds: (ANIM_DURATION ~/ 5)),
      vsync: this,
    );

    _positionTween = Tween<double>(begin: position, end: 1);

    _positionAnimation = _positionTween.animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });

    _fadeFabOutAnimation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabOutAnimation.value;
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            activeIcon = selectedTabItem?.icon;
          });
        }
      });

    _fadeFabInAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.8, 1, curve: Curves.easeOut)))
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabInAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    /// Add safe area, instead of hard-coding a height
    final bottomPadding = mq.viewInsets.bottom;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 65 + 13.0,
          padding: EdgeInsets.only(bottom: 10),
          decoration:
              const BoxDecoration(color: CupertinoColors.white, boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -1),
              blurRadius: 5,
            ),
          ]),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: generateTabItems(),
          ),
        ),
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(color: Colors.transparent),
            child: Align(
              heightFactor: 0,
              alignment: Alignment(_positionAnimation.value, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / tabAmount,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: ClipRect(
                        clipper: HalfClipper(),
                        child: Container(
                          child: Center(
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 70,
                      width: 90,
                      child: CustomPaint(painter: HalfPainter()),
                    ),
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.tabSelectedColor,
                          border: Border.all(
                            color: CupertinoColors.white,
                            width: 5,
                            style: BorderStyle.none,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Opacity(
                            opacity: fabIconAlpha,
                            child: Icon(
                              activeIcon,
                              color: widget.tabIconSelectedColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> generateTabItems() {
    return widget.items.map((item) {
      return TabItem(
        selected: selectedTab == item.label,
        iconData: item.icon,
        title: item.label,
        textStyle: widget.textStyle,
        tabSelectedColor: widget.tabSelectedColor,
        tabIconColor: widget.tabIconColor,
        callbackFunction: () {
          setState(() {
            activeIcon = item.icon;
            selectedTab = item.label;
            widget.onTabItemSelected(index);
          });
          _initAnimationAndStart(_positionAnimation.value, position);
        },
      );
    }).toList();
  }

  _initAnimationAndStart(double from, double to) {
    _positionTween.begin = from;
    _positionTween.end = to;

    _animationController.reset();
    _fadeOutController.reset();
    _animationController.forward();
    _fadeOutController.forward();
  }
}

class HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width, size.height / 2);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

class HalfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect beforeRect = Rect.fromLTWH(0, (size.height / 2) - 10, 10, 10);
    final Rect largeRect = Rect.fromLTWH(10, 0, size.width - 20, 70);
    final Rect afterRect =
        Rect.fromLTWH(size.width - 10, (size.height / 2) - 10, 10, 10);

    final path = Path();
    path.arcTo(beforeRect, vector.radians(0), vector.radians(90), false);
    path.lineTo(20, size.height / 2);
    path.arcTo(largeRect, vector.radians(0), -vector.radians(180), false);
    path.moveTo(size.width - 10, size.height / 2);
    path.lineTo(size.width - 10, (size.height / 2) - 10);
    path.arcTo(afterRect, vector.radians(180), vector.radians(-90), false);
    path.close();

    canvas.drawPath(path, Paint()..color = CupertinoColors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  const HalfPainter();
}
