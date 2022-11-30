import 'dart:ui' as ui;
import 'package:page_flip/page_flip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class PageFlipBuilder extends StatefulWidget {
  const PageFlipBuilder({
    Key? key,
    required this.amount,
    this.backgroundColor = const Color(0xFFFFFFCC),
    this.child,
  }) : super(key: key);

  final Animation<double> amount;
  final Color backgroundColor;
  final Widget? child;

  @override
  State<PageFlipBuilder> createState() => _PageFlipBuilderState();
}

class _PageFlipBuilderState extends State<PageFlipBuilder> {
  final _boundaryKey = GlobalKey();
  ui.Image? _image;

  @override
  void didUpdateWidget(PageFlipBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _image = null;
    }
  }

  void _captureImage(Duration timeStamp) async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary =
        _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 20));
      return _captureImage(timeStamp);
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return CustomPaint(
        painter: PageFlipEffect(
          amount: widget.amount,
          image: _image!,
          backgroundColor: widget.backgroundColor,
        ),
        size: Size.infinite,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback(_captureImage);
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final size = constraints.biggest;
          return Stack(
            clipBehavior: Clip.hardEdge, children: <Widget>[
              Positioned(
                left: 1 + size.width,
                top: 1 + size.height,
                width: size.width,
                height: size.height,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: widget.child,
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
