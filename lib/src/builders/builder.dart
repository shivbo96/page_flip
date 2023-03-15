import 'dart:ui' as ui;
import 'package:page_flip/page_flip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

ValueNotifier<bool> flip = ValueNotifier(false);
ValueNotifier<bool> reCaptureScreenAgain = ValueNotifier(false);
ValueNotifier<Widget> currentChild =
    ValueNotifier(Container(color: Colors.white));

class PageFlipBuilder extends StatefulWidget {
  const PageFlipBuilder({
    Key? key,
    required this.amount,
    this.backgroundColor = Colors.black12,
    this.child,
  }) : super(key: key);

  final Animation<double> amount;
  final Color backgroundColor;
  final Widget? child;

  @override
  State<PageFlipBuilder> createState() => PageFlipBuilderState();
}

class PageFlipBuilderState extends State<PageFlipBuilder> {
  ui.Image? _image;
  final _boundaryKey = GlobalKey();

  @override
  void didUpdateWidget(PageFlipBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _image = null;
    }
  }

  void captureImage() async {
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      RenderObject? boundary = _boundaryKey.currentContext?.findRenderObject();
      if (boundary is RenderRepaintBoundary) {
        final image = await boundary.toImage();
        setState(() {
          _image = image;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return ValueListenableBuilder<Widget>(
        valueListenable: currentChild,
        builder: ((context, currentChild, child) {
          return ValueListenableBuilder<bool>(
            valueListenable: reCaptureScreenAgain,
            builder: (context, changeImage, child) {
              return ValueListenableBuilder<bool>(
                  valueListenable: flip,
                  builder: (context, value, child) {
                    // if( changeImage){
                    //   captureImage();
                    // }
                    return !value
                        ? currentChild
                        : CustomPaint(
                            painter: PageFlipEffect(
                              amount: widget.amount,
                              image: _image!,
                              backgroundColor: widget.backgroundColor,
                            ),
                            size: Size.infinite,
                          );
                  });
            },
          );
        }),
      );
    } else {
      captureImage();
      return screen(widget.child);
    }
  }

  screen(Widget? child) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: child,
    );
  }
}
