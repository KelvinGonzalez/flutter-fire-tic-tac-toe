import 'package:tic_tac_toe/model/player.dart';
import 'package:tic_tac_toe/model/game_state.dart';

class Room {
  final List<Player> players;
  final int requiredPlayers;
  final int maxPlayers;
  final DateTime timestamp;
  GameState gameState;

  Room(
      {required this.players,
      required this.requiredPlayers,
      required this.maxPlayers,
      required this.timestamp,
      required this.gameState});

  void setGameStateMethods() {
    gameState.getPlayers = () => players;
    gameState.hasRequiredPlayers = () => players.length >= requiredPlayers;
  }

  static Room createRoom(Player player) {
    final board = List.filled(9, -1);
    final room = Room(
        players: [player],
        requiredPlayers: 2,
        maxPlayers: 2,
        timestamp: DateTime.now(),
        gameState: GameState(board: board, currentPlayer: 0));
    room.setGameStateMethods();
    return room;
  }

  bool joinRoom(Player player) {
    if (players.length >= maxPlayers) return false;
    if (players.contains(player)) return false;
    players.add(player);
    return true;
  }

  bool leaveRoom(Player player) {
    if (!players.contains(player)) return false;
    players.remove(player);
    if (gameState.currentPlayer >= players.length) gameState.currentPlayer = 0;
    if (players.length < requiredPlayers) restartGameState();
    return true;
  }

  Player? getHost() {
    return players.firstOrNull;
  }

  void restartGameState() {
    final board = List.filled(9, -1);
    gameState = GameState(board: board, currentPlayer: 0);
    setGameStateMethods();
  }

  Map<String, dynamic> toJson() {
    return {
      "players": players.map((e) => e.toJson()).toList(),
      "requiredPlayers": requiredPlayers,
      "maxPlayers": maxPlayers,
      "timestamp": timestamp.millisecondsSinceEpoch,
      "gameState": gameState.toJson(),
    };
  }

  static Room fromJson(Map<String, dynamic> json) {
    Room room = Room(
        players: json["players"]
            .map((e) => Player.fromJson(e))
            .toList()
            .cast<Player>(),
        requiredPlayers: json["requiredPlayers"],
        maxPlayers: json["maxPlayers"],
        timestamp: DateTime.fromMillisecondsSinceEpoch(json["timestamp"]),
        gameState: GameState.fromJson(json["gameState"]));
    room.setGameStateMethods();
    return room;
  }
}
