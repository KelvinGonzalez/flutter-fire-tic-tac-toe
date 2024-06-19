import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/model/room_manager.dart';

import '../model/player.dart';
import '../model/room.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    final roomManager = RoomManager.getInstance();
    if (roomManager.room == null) return const Placeholder();
    return PopScope(
      canPop: false,
      onPopInvoked: (popped) async {
        if (popped) return;
        await roomManager.leaveRoom();
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("In-game"),
        ),
        body: StreamBuilder(
            stream: roomManager.getRoomStream()!,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              Player? winner = roomManager.checkWin();
              bool draw = roomManager.checkDraw();
              if (winner != null || draw) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await roomManager.deleteRoom();
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) => AlertDialog(
                            title: Text(winner != null
                                ? "${winner.name} won!"
                                : "It's a draw!"),
                          ));
                });
              }

              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!roomManager.hasRequiredPlayers())
                      const Text("Waiting for more players..."),
                    if (roomManager.hasRequiredPlayers())
                      Column(
                        children: [
                          Text(
                              "It is ${roomManager.getCurrentPlayer()!.name}'s turn"),
                          _tableWidget(context),
                        ],
                      ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}

Widget _tableWidget(BuildContext context) {
  RoomManager roomManager = RoomManager.getInstance();
  Room room = roomManager.getRoom()!;
  List<IconData> icons = [Icons.close, Icons.circle_outlined];
  List<Row> rows = [];
  for (int i = 0; i < 9; i += 3) {
    rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: room.gameState.board
            .sublist(i, i + 3)
            .mapIndexed((j, e) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: ElevatedButton(
                        onPressed: () async {
                          await roomManager.performMove(i + j);
                        },
                        child: e == -1
                            ? const Text("")
                            : Icon(icons[e], size: 48)),
                  ),
                ))
            .toList()));
  }
  return Column(children: rows);
}
