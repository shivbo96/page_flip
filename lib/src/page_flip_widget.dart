import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

class PageFlipWidget extends StatefulWidget {
  const PageFlipWidget({
    Key? key,
    this.duration = const Duration(milliseconds: 450),
    this.cutoff = 0.6,
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
    for (var i = 0; i < widget.children.length; i++) {
      final controller = AnimationController(
        value: 1,
        duration: widget.duration,
        vsync: this,
      );
      _controllers.add(controller);
      final child = PageFlipBuilder(
        backgroundColor: widget.backgroundColor,
        amount: controller,
        child: widget.children[i],
      );
      pages?.add(child);
    }
    pages = pages?.reversed.toList();
    pageNumber = widget.initialIndex;
  }

  bool get _isLastPage =>
      pages != null && (pages?.length ?? 0 - 1) == pageNumber;


  bool get _isFirstPage =>  pageNumber == 0;

  void _flipPage(DragUpdateDetails details, BoxConstraints dimens) {
    final ratio = details.delta.dx / dimens.maxWidth;
    if (_isForward == null) {
      if (details.delta.dx > 0) {
        _isForward = false;
      } else {
        _isForward = true;
      }
    }
    if (_isForward! || pageNumber == 0) {
     _isLastPage?null: _controllers[pageNumber].value += ratio;
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
          _isLastPage?null:await _controllers[pageNumber].forward();
        }
      } else {
        if (!_isFirstPage &&
            _controllers[pageNumber - 1].value >= widget.cutoff) {
          await previousPage();
        } else {
          if (_isFirstPage) {
            await _controllers[pageNumber].forward();
          } else {
            _isFirstPage?null:await _controllers[pageNumber - 1].reverse();
          }
        }
      }
    }
    _isForward = null;
  }

  Future nextPage() async {
    await _controllers[pageNumber].reverse();
    if (mounted) {
      setState(() {
        pageNumber++;
      });
    }
  }

  Future previousPage() async {
    await _controllers[pageNumber - 1].forward();
    if (mounted) {
      setState(() {
        pageNumber--;
      });
    }
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
        // _controllers[i].value = 0;
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
          onHorizontalDragUpdate: (details) => _flipPage(details, dimens),
          onHorizontalDragEnd: (details) => _onDragFinish(),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[

              if (widget.lastPage != null) ...[
                widget.lastPage!,
              ],
              if (pages != null)
                ...pages!
              else ...[
                const CircularProgressIndicator(),
              ],
              // if (widget.firstPage != null) ...[
              //   widget.firstPage!,
              // ],
              Positioned.fill(
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Flexible(
                      flex: (widget.cutoff * 10).round(),
                      child: Container(
                        color: widget.showDragCutoff
                            ? Colors.blue.withAlpha(100)
                            : null,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _isFirstPage ? null : previousPage,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 10 - (widget.cutoff * 10).round(),
                      child: Container(
                        color: widget.showDragCutoff
                            ? Colors.red.withAlpha(100)
                            : null,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _isLastPage ? null : nextPage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
