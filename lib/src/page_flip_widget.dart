import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

class PageFlipWidget extends StatefulWidget {
  const PageFlipWidget({
    Key? key,
    this.duration = const Duration(milliseconds: 450),
    this.cutoff = 0.5,
    this.backgroundColor = const Color(0xFFFFFFCC),
    required this.children,
    this.initialIndex = 0,
    this.lastPage,
    this.showDragCutoff = false,
  }) : super(key: key);

  final Color backgroundColor;
  final List<Widget> children;
  final Duration duration;
  final int initialIndex;
  final Widget? lastPage;
  final bool showDragCutoff;
  final double cutoff;

  @override
  PageFlipWidgetState createState() => PageFlipWidgetState();
}

class PageFlipWidgetState extends State<PageFlipWidget>
    with TickerProviderStateMixin {
  int pageNumber = 0;
  List<Widget>? pages = [];

  final List<AnimationController> _controllers = [];
  bool? _isForward;
  GlobalKey<PageFlipBuilderState>? globalKey;

  @override
  void didUpdateWidget(PageFlipWidget oldWidget) {
    if (oldWidget.children != widget.children) {
      _setUp();
    }
    if (oldWidget.duration != widget.duration) {
      _setUp();
    }
    if (oldWidget.backgroundColor != widget.backgroundColor) {
      _setUp();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  void _setUp() {
    _controllers.clear();
    pages?.clear();
    if (widget.children.isNotEmpty) {
      currentChild.value = Center(child: widget.children[0]);
    }
    if (widget.lastPage != null) {
      widget.children.add(widget.lastPage!);
    }
    for (var i = 0; i < widget.children.length; i++) {
      globalKey = GlobalKey<PageFlipBuilderState>();
      final controller = AnimationController(
        value: 1,
        duration: widget.duration,
        vsync: this,
      );
      _controllers.add(controller);
      final child = PageFlipBuilder(
        key: globalKey,
        backgroundColor: widget.backgroundColor,
        amount: controller,
        child: widget.children[i],
      );

      ///for image
      // final child = PageFlipImage(
      //         backgroundColor: widget.backgroundColor,
      //         amount: controller,
      //         image: const NetworkImage('https://images.pexels.com/photos/1459505/pexels-photo-1459505.jpeg?auto=compress&cs=tinysrgb&w=1600'),
      //       );
      pages?.add(child);
    }
    pages = pages?.reversed.toList();
    pageNumber = widget.initialIndex;
  }

  bool get _isLastPage => pages != null && (pages!.length - 1) == pageNumber;

  bool get _isFirstPage => pageNumber == 0;

  void _flipPage(DragUpdateDetails details, BoxConstraints dimens) {
    // if (!flip.value) {
      flip.value = true;
    // }
    final ratio = details.delta.dx / dimens.maxWidth;
    if (_isForward == null) {
      if (details.delta.dx > 0) {
        _isForward = false;
      } else {
        _isForward = true;
      }
    }

    if (_isForward! || pageNumber == 0) {
      int pageSize =
          widget.lastPage != null ? pages!.length : pages!.length - 1;
      if (pageNumber != pageSize) {
        if (!_isLastPage) {
          _controllers[pageNumber].value += ratio;
        }
      }
    } else {
      _controllers[pageNumber - 1].value += ratio;
    }
  }

  Future _onDragFinish() async {
    if (_isForward != null) {
      if (_isForward!) {
        if (!_isLastPage &&
            _controllers[pageNumber].value <= (widget.cutoff + 0.15)) {
          await nextPage();
        } else {
          if (!_isLastPage) {
            await _controllers[pageNumber].forward();
          }
        }
      } else {
        if (!_isFirstPage &&
            _controllers[pageNumber - 1].value >= widget.cutoff) {
          await previousPage();
        } else {
          if (_isFirstPage) {
            await _controllers[pageNumber].forward();
          } else {
            await _controllers[pageNumber - 1].reverse();
            if (!_isFirstPage) {
              await previousPage();
            }
          }
        }
      }
    }
    _isForward = null;
    flip.value = false;
    reCaptureScreenAgain.value = false;
    currentChild.value = Center(child: widget.children[pageNumber]);
  }

  Future nextPage() async {
    await _controllers[pageNumber].reverse();
    if (mounted) {
      setState(() {
        pageNumber++;
        // reCaptureScreenAgain.value = false;
      });
    }
  }

  Future previousPage() async {
    await _controllers[pageNumber - 1].forward();
    if (mounted) {
      setState(() {
        pageNumber--;
        // reCaptureScreenAgain.value = false;
      });
    }
  }

  void reCaptureFlipScreenAgain() {
    reCaptureScreenAgain.value = true;
    // print('changeImageV newnwnw ${reCaptureScreenAgain.value}');
    // globalKey?.currentState?.captureImage();
  }

  Future goToPage(int index) async {
    if (mounted) {
      setState(() {
        pageNumber = index;
      });
    }
    for (var i = 0; i < _controllers.length; i++) {
      if (i == index) {
        _controllers[i].forward();
      } else if (i < index) {
        _controllers[i].reverse();
      } else {
        if (_controllers[i].status == AnimationStatus.reverse) {
          _controllers[i].value = 1;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, dimens) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragCancel: () => _isForward = null,
          // onHorizontalDragStart: (d)=>,
          onHorizontalDragUpdate: (details) => _flipPage(details, dimens),

          onHorizontalDragEnd: (details) => _onDragFinish(),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // if (widget.lastPage != null) ...[
              //   widget.lastPage!,
              // ],
              if (pages != null)
                ...pages!
              else ...[
                const CircularProgressIndicator(),
              ],
              // if (widget.firstPage != null) ...[
              //   widget.firstPage!,
              // ],
              // Positioned.fill(
              //   child: Flex(
              //     direction: Axis.horizontal,
              //     children: <Widget>[
              //       Flexible(
              //         flex: (widget.cutoff * 10).round(),
              //         child: Container(
              //             color: widget.showDragCutoff
              //                 ? Colors.blue.withAlpha(100)
              //                 : null,
              //             /*child: GestureDetector(
              //               behavior: HitTestBehavior.opaque,
              //               onTap: _isFirstPage ? null : previousPage,
              //             )*/
              //         ),
              //       ),
              //       Flexible(
              //         flex: 10 - (widget.cutoff * 10).round(),
              //         child: Container(
              //           color: widget.showDragCutoff
              //               ? Colors.red.withAlpha(100)
              //               : null,
              //           /*child: GestureDetector(
              //             behavior: HitTestBehavior.opaque,
              //             onTap: _isLastPage ? null : nextPage,
              //           ),*/
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
