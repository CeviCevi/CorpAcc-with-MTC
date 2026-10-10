import 'dart:developer';

class AudioModel {
  final String id;
  final String name;
  final String creatorId;
  final String link;
  final String createAt;
  final String description;

  const new({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.link,
    required this.createAt,
    required this.description,
  });

  @override
  String toString() {
    return 'AudioModel{id=$id, name=$name, creatorId=$creatorId, link=$link, createAt=$createAt, description=$description}';
  }

  static const empty = AudioModel(
    id: "NoN",
    name: "NoN",
    creatorId: "NoN",
    link: "/NoN",
    createAt: "1969-07-20T20:18:04.000Z",
    description: "NoN",
  );

  void print() {
    log(toString());
  }
}
