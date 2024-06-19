import 'package:pair/pair.dart';
import 'package:tic_tac_toe/model/player.dart';

class GameState {
  final List<int> board;
  int currentPlayer;

  late List<Player> Function() getPlayers;
  late bool Function() hasRequiredPlayers;

  GameState({required this.board, required this.currentPlayer});

  List<Player> get players => getPlayers();

  int getPlayerIndex(Player player) {
    return players.indexOf(player);
  }

  bool isCurrentPlayer(Player player) {
    return getPlayerIndex(player) == currentPlayer;
  }

  Pair<int, int> getMatrixPosition(int position) {
    if (position < 0) return const Pair(-1, -1);
    return Pair(position ~/ 3, position % 3);
  }

  bool performMove(Player player, int position) {
    if (!hasRequiredPlayers()) return false;
    if (!isCurrentPlayer(player)) return false;
    if (position < 0 || position >= 9) return false;
    if (board[position] != -1) return false;
    board[position] = getPlayerIndex(player);
    currentPlayer = (currentPlayer + 1) % players.length;
    return true;
  }

  bool positionOutOfBounds(int posRow, int posCol) {
    return posRow < 0 || posRow >= 3 || posCol < 0 || posCol >= 3;
  }

  int countDirection(int posRow, int posCol, int dirRow, int dirCol, int icon) {
    if (positionOutOfBounds(posRow, posCol)) return 0;
    if (icon != board[posRow * 3 + posCol]) return 0;
    return 1 +
        countDirection(posRow + dirRow, posCol + dirCol, dirRow, dirCol, icon);
  }

  Player? checkWin() {
    for (var position = 0; position < 9; position++) {
      final matrixPosition = getMatrixPosition(position);
      final directions = [
        const Pair(1, 0),
        const Pair(1, 1),
        const Pair(0, 1),
        const Pair(-1, 1)
      ];
      final icon = board[position];
      if (icon == -1) continue;
      for (var direction in directions) {
        var count = countDirection(matrixPosition.key, matrixPosition.value,
                direction.key, direction.value, icon) +
            countDirection(matrixPosition.key, matrixPosition.value,
                -direction.key, -direction.value, icon) -
            1;
        if (count >= 3) return players[board[position]];
      }
    }
    return null;
  }

  bool checkDraw() {
    return !board.any((e) => e == -1);
  }

  Player getCurrentPlayer() {
    return players[currentPlayer];
  }

  Map<String, dynamic> toJson() => {
        "board": board,
        "currentPlayer": currentPlayer,
      };

  static GameState fromJson(Map<String, dynamic> json) => GameState(
      board: json["board"].toList().cast<int>(),
      currentPlayer: json["currentPlayer"]);
}
