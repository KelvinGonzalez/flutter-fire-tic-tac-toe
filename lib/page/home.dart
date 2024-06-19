import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tic_tac_toe/model/room.dart';
import 'package:tic_tac_toe/model/room_manager.dart';
import 'package:tic_tac_toe/page/game.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final roomManager = RoomManager.getInstance();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Room"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          TextField(
            decoration: const InputDecoration(labelText: "Player Name"),
            onChanged: (value) {
              roomManager.setPlayerName(value);
            },
          ),
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: StreamBuilder(
                    stream: roomManager.getRooms(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      }
                      return Column(
                          children: snapshot.data!.docs
                              .sorted((a, b) => b
                                  .data()["timestamp"]
                                  .compareTo(a.data()["timestamp"]))
                              .mapIndexed(
                                  (i, doc) => _roomListItem(context, i, doc))
                              .toList());
                    },
                  ))),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: ElevatedButton(
                onPressed: () async {
                  await roomManager.createRoom();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Game()));
                },
                child: const Text("Create Room"),
              ))
            ],
          ),
        ]),
      ),
    );
  }
}

Widget _roomListItem(
    BuildContext context, int i, DocumentSnapshot<Map<String, dynamic>> doc) {
  if (doc.data() == null) return Container();
  final room = Room.fromJson(doc.data()!);
  final roomManager = RoomManager.getInstance();
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: ElevatedButton(
          onPressed: () async {
            if (await roomManager.joinRoom(doc)) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Game()));
            }
          },
          child:
              Text("Id: ${doc.id}, Host: ${room.getHost()?.name ?? "Guest"}"),
        ))
      ],
    ),
  );
}
