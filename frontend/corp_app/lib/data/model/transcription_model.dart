import 'dart:developer';

class TranscriptionModel {
  final String id;
  final String name;
  final String creatorId;
  final String link;
  final String createAt;
  final String description;

  new({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.link,
    required this.createAt,
    required this.description,
  });

  @override
  String toString() {
    return 'TranscriptionModel{id=$id, name=$name, creatorId=$creatorId, link=$link, createAt=$createAt, description=$description}';
  }

  static TranscriptionModel get empty {
    return TranscriptionModel(
      id: "NoN",
      name: "NoN",
      creatorId: "NoN",
      link: "/NoN",
      createAt: "NoN",
      description: "NoN",
    );
  }

  void print() {
    log(toString());
  }
}
