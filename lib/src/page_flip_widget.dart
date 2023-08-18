import 'dart:async';

import 'package:flutter/material.dart';

import '../page_flip.dart';

class PageFlipWidget extends StatefulWidget {
  const PageFlipWidget({
    Key? key,
    this.index,
    this.duration = const Duration(milliseconds: 450),
    this.cutoffForward = 0.8,
    this.cutoffPrevious = 0.1,
    this.backgroundColor = const Color(0xFFFFFFCC),
    required this.children,
    this.initialIndex = 0,
    this.lastPage,
    this.clipBehavior = Clip.none,
    this.maxScale = 4.0,
    this.transformationController,
    this.onTapPage,
    this.onDoubleTapPage,
  }) : super(key: key);

  final int? index;
  final Color backgroundColor;
  final List<Widget> children;
  final Duration duration;
  final int initialIndex;
  final Widget? lastPage;
  final double cutoffForward;
  final double cutoffPrevious;
  final Clip clipBehavior;
  final TransformationController? transformationController;
  final double maxScale;
  final VoidCallback? onTapPage;
  final VoidCallback? onDoubleTapPage;

  @override
  PageFlipWidgetState createState() => PageFlipWidgetState();
}

class PageFlipWidgetState extends State<PageFlipWidget>
    with SingleTickerProviderStateMixin {
  int pageNumber = 0;
  List<Widget> pages = [];
  final List<AnimationController> _controllers = [];
  bool? _isForward;

  @override
  void didUpdateWidget(PageFlipWidget oldWidget) {
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
    imageData = {};
    currentAmount = {};
    isCHeckedItem = {};
    currentPage = ValueNotifier(-1);
    currentWidget = ValueNotifier(Container());
    currentPageIndex = ValueNotifier(0);
    _setUp();
  }

  void _setUp({bool isRefresh = false}) {
    _controllers.clear();
    pages.clear();
    if (widget.lastPage != null) {
      widget.children.add(widget.lastPage!);
    }
    for (var i = 0; i < widget.children.length; i++) {
      final controller = AnimationController(
        value: 1,
        duration: widget.duration,
        vsync: this,
      );
      _controllers.add(controller);
      final child = PageFlipBuilder(
        amount: controller,
        pageIndex: i,
        key: Key('item$i'),
        child: widget.children[i],
      );
      pages.add(child);
    }
    pages = pages.reversed.toList();
    if (isRefresh) {
      goToPage(pageNumber);
    } else {
      pageNumber = widget.initialIndex;
      lastPageLoad = pages.length < 3 ? 0 : 3;
    }
    Future.delayed(
      const Duration(seconds: 1),
      () {
        isFlipForward.value = true;
      },
    );
  }

  bool get _isLastPage => (pages.length - 1) == pageNumber;

  int lastPageLoad = 0;

  bool get _isFirstPage => pageNumber == 0;

  void _turnPage(DragUpdateDetails details, BoxConstraints dimens) {
    // if ((_isLastPage) || !isFlipForward.value) return;
    currentPage.value = pageNumber;
    currentWidget.value = Container();
    final ratio = details.delta.dx / dimens.maxWidth;
    if (_isForward == null) {
      if (details.delta.dx > 0.0) {
        _isForward = false;
      } else if (details.delta.dx < -0.2) {
        _isForward = true;
      } else {
        _isForward = null;
      }
    }
    if (_isForward == true || pageNumber == 0) {
      int pageSize = widget.lastPage != null ? pages.length : pages.length - 1;
      if (pageNumber != pageSize) {
        if (!_isLastPage) {
          _controllers[pageNumber].value += ratio;
        }
      }
    }
  }

  Future _onDragFinish() async {
    if (_isForward != null) {
      if (_isForward == true) {
        if (!_isLastPage &&
            _controllers[pageNumber].value <= (widget.cutoffForward + 0.15)) {
          await nextPage();
        } else {
          if (!_isLastPage) {
            await _controllers[pageNumber].forward();
          }
        }
      } else {
        if (!_isFirstPage &&
            _controllers[pageNumber - 1].value >= widget.cutoffPrevious) {
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
    currentPage.value = -1;
  }

  Future nextPage() async {
    await _controllers[pageNumber].reverse();
    if (mounted) {
      setState(() {
        pageNumber++;
      });
    }

    if (pageNumber < pages.length) {
      currentPageIndex.value = pageNumber;
      currentWidget.value = pages[pageNumber];
    }

    if (_isLastPage) {
      currentPageIndex.value = pageNumber;
      currentWidget.value = pages[pageNumber];
      isFlipForward.value = false;
      return;
    }
  }

  Future previousPage() async {
    await _controllers[pageNumber - 1].forward();
    if (mounted) {
      setState(() {
        pageNumber--;
      });
    }
    currentPageIndex.value = pageNumber;
    currentWidget.value = pages[pageNumber];
    imageData[pageNumber] = null;
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
    currentPageIndex.value = pageNumber;
    currentWidget.value = pages[pageNumber];
    Future.delayed(
      const Duration(seconds: 2),
      () {
        isFlipForward.value = true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimens) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTapPage,
        onDoubleTap: widget.onDoubleTapPage,
        onTapDown: (details) {},
        onTapUp: (details) {},
        onPanDown: (details) {},
        onPanEnd: (details) {},
        onTapCancel: () {},
        onHorizontalDragCancel: () => _isForward = null,
        onHorizontalDragUpdate: (details) => _turnPage(details, dimens),
        onHorizontalDragEnd: (details) => _onDragFinish(),
        child: InteractiveViewer(
          maxScale: widget.maxScale,
          clipBehavior: widget.clipBehavior,
          transformationController: widget.transformationController,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (widget.lastPage != null) ...[
                widget.lastPage!,
              ],
              if (pages.isNotEmpty) ...pages else ...[const SizedBox.shrink()],
            ],
          ),
        ),
      ),
    );
  }
}
