import 'dart:developer';

class ContractModel {
  final String id;
  final String name;
  final String creatorId;
  final String link;
  final String createAt;
  final String description;

  const ContractModel({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.link,
    required this.createAt,
    required this.description,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
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

  @override
  String toString() {
    return 'ContractModel{id=$id, name=$name, creatorId=$creatorId, '
        'link=$link, createAt=$createAt, description=$description}';
  }

  static const empty = ContractModel(
    id: 'NoN',
    name: 'NoN',
    creatorId: 'NoN',
    link: '/NoN',
    createAt: 'NoN',
    description: 'NoN',
  );

  void print() {
    log(toString());
  }
}
