import 'dart:developer';

class AudioModel {
  final String id;
  final String name;
  final String creatorId;
  final String link;
  final String createAt;
  final String description;

  const AudioModel({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.link,
    required this.createAt,
    required this.description,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      creatorId: (json['creatorId'] ?? json['creator_id'] ?? '').toString(),
      link: (json['link'] ?? '').toString(),
      createAt: (json['createAt'] ?? json['create_at'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'link': link,
      'createAt': createAt,
      'description': description,
    };
  }

  AudioModel copyWith({
    String? id,
    String? name,
    String? creatorId,
    String? link,
    String? createAt,
    String? description,
  }) {
    return AudioModel(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      link: link ?? this.link,
      createAt: createAt ?? this.createAt,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'AudioModel{id: $id, name: $name, creatorId: $creatorId, '
        'link: $link, createAt: $createAt, description: $description}';
  }

  void print() => log(toString());

  static const empty = AudioModel(
    id: 'NoN',
    name: 'NoN',
    creatorId: 'NoN',
    link: '',
    createAt: '1969-07-20T20:18:04.000Z',
    description: 'NoN',
  );
}
