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
        backgroundColor: Colors.white,
        showDragCutoff: false,
        lastPage: const Center(child: Text('Last Page!')),
        children: <Widget>[
          for (var i = 0; i < 5; i++) AlicePage(page: i),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () {
          _controller.currentState?.goToPage(2);
        },
      ),
    );
  }
}
