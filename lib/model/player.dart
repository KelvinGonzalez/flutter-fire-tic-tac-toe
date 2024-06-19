class Player {
  final String id;
  String? name;

  Player({required this.id, this.name});

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };

  static Player fromJson(Map<String, dynamic> json) =>
      Player(id: json["id"], name: json["name"]);

  @override
  bool operator ==(Object other) =>
      other.runtimeType == Player && name == (other as Player).name;

  @override
  int get hashCode => name.hashCode;
}
