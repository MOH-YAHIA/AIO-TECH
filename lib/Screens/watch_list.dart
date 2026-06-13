import 'package:flutter/material.dart';

import '../Widgets/empty_watch_list.dart';

class WatchList extends StatefulWidget {
  const WatchList({super.key});

  @override
  State<WatchList> createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Text(
              "Your Tech Watchlist",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
          ),
          Align(
            alignment: AlignmentGeometry.center,
            child: EmptyWatchList(),
          ),
        ],
      ),
    );
  }
}
