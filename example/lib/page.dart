import 'package:flutter/material.dart';

class DemoPage extends StatelessWidget {
  final int page;

  const DemoPage({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return page < 2
        ? Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Page ${page + 1}",
                    style: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          )
        : Scaffold(
            body: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "Part ${page + 1}",
                      style: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "My Father's Dragon",
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 24.0,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                            child: Text(
                          '''Elmer Elevator, when he was a kid. He and his mother Dela owned a candy shop in a small town, but were soon forced to close down and move away when the people of the town moved away. They move to a faraway city where they plan to open a new shop, but they eventually lose all the money they save up while getting by''',
                          style:
                              TextStyle(fontSize: 14, fontFamily: 'Droid Sans'),
                        )),
                        Container(
                          margin: const EdgeInsets.only(left: 12.0),
                          color: Colors.black26,
                          width: 160.0,
                          height: 240.0,
                          child: const Placeholder(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                        '''Elmer soon befriends a cat and eventually gets the idea to panhandle the money needed for the store, only for his mother to tell him that it is a lost cause. Angered, Elmer runs to the docks to be alone. The Cat comes to him and begins speaking to him, much to his shock. She tells him that on an island, Wild Island, beyond the city lies a dragon that can probably help him. Elmer takes the task and is transported to the island thanks to a bubbly whale named Soda. Once they make it to Wild Island, Soda explains that a gorilla named Saiwa is using the dragon to keep the island from sinking, but it remains ineffective.

Elmer frees the dragon, a goofball named Boris, and they go on an adventure to find a tortoise named Aratuah in order to find out how Boris can keep the island from sinking for the next century since his kind has been doing that forever and he will be an "After Dragon", but he can't fly due to his wing being broken after Elmer saves him''',
                        style:
                            TextStyle(fontFamily: 'Droid Sans', fontSize: 14)),
                  ],
                ),
              ),
            ),
          );
  }
}
