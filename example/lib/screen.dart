import 'package:example/page.dart';
import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = GlobalKey<PageFlipWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageFlipWidget(
        key: _controller,
        backgroundColor: Colors.yellow,
        initialIndex: 0,
        // isRightSwipe: true,
        lastPage: Container(
            color: Colors.white,
            child: const Center(child: Text('Last Page!'))),
        children: <Widget>[
          for (var i = 0; i < 10; i++) DemoPage(page: i),
        ],
        onPageFlipped: (pageNumber) {
          debugPrint('onPageFlipped: (pageNumber) $pageNumber');
        },
        onFlipStart: () {
          debugPrint('onFlipStart');
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.looks_5_outlined),
        onPressed: () {
          _controller.currentState?.goToPage(5);
        },
      ),
    );
  }
}
