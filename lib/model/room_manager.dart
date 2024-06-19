import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tic_tac_toe/model/player.dart';
import 'package:tic_tac_toe/model/room.dart';

class RoomManager {
  static final RoomManager _roomManager = RoomManager();
  static const String _collectionName = "Room";

  Player? player;
  DocumentSnapshot<Map<String, dynamic>>? room;

  static RoomManager getInstance() {
    return _roomManager;
  }

  Future<void> init() async {
    // String? id = await FirebaseMessaging.instance.getToken();
    // if (id == null) return;
    const id = "0";
    player = Player(id: id);
  }

  void setPlayerName(String name) {
    player?.name = name;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRooms() {
    return FirebaseFirestore.instance.collection(_collectionName).snapshots();
  }

  Room? getRoom() {
    if (room == null || room!.data() == null) return null;
    return Room.fromJson(room!.data()!);
  }

  Future<void> createRoom() async {
    if (player == null) return;
    final room = Room.createRoom(player!);
    DocumentReference<Map<String, dynamic>> reference = await FirebaseFirestore
        .instance
        .collection(_collectionName)
        .add(room.toJson());
    this.room = await reference.get();
  }

  Future<bool> joinRoom(DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    if (player == null) return false;
    if (snapshot.data() == null) return false;
    final room = Room.fromJson(snapshot.data()!);
    bool joined = room.joinRoom(player!);
    if (!joined) return false;
    await snapshot.reference.set(room.toJson());
    this.room = snapshot;
    return true;
  }

  Future<bool> leaveRoom() async {
    if (this.room == null || this.room!.data() == null || player == null) {
      return false;
    }
    final room = Room.fromJson(this.room!.data()!);
    bool leftRoom = room.leaveRoom(player!);
    if (!leftRoom) return false;
    if (room.players.isEmpty) return await deleteRoom();
    await this.room!.reference.set(room.toJson());
    this.room = null;
    return true;
  }

  Future<bool> deleteRoom() async {
    if (room == null || room!.data() == null || player == null) {
      return false;
    }
    await room!.reference.delete();
    room = null;
    return true;
  }

  Future<bool> performMove(int position) async {
    if (this.room == null || this.room!.data() == null || player == null) {
      return false;
    }
    final room = Room.fromJson(this.room!.data()!);
    bool moved = room.gameState.performMove(player!, position);
    if (!moved) return false;
    await this.room!.reference.set(room.toJson());
    return true;
  }

  Player? checkWin() {
    if (this.room == null || this.room!.data() == null || player == null) {
      return null;
    }
    final room = Room.fromJson(this.room!.data()!);
    return room.gameState.checkWin();
  }

  bool checkDraw() {
    if (this.room == null || this.room!.data() == null || player == null) {
      return false;
    }
    final room = Room.fromJson(this.room!.data()!);
    return room.gameState.checkDraw();
  }

  Player? getCurrentPlayer() {
    if (room == null || room!.data() == null) {
      return null;
    }
    return getRoom()?.gameState.getCurrentPlayer();
  }

  bool hasRequiredPlayers() {
    if (this.room == null || this.room!.data() == null || player == null) {
      return false;
    }
    final room = Room.fromJson(this.room!.data()!);
    return room.gameState.hasRequiredPlayers();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? getRoomStream() {
    if (room == null) return null;
    return room!.reference.snapshots()..listen((doc) => updateSnapshot(doc));
  }

  void updateSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    room = snapshot;
  }
}
