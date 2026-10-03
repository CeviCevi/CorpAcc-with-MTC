// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loginMeta = const VerificationMeta('login');
  @override
  late final GeneratedColumn<String> login = GeneratedColumn<String>(
    'login',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('moderation'),
  );
  static const VerificationMeta _createAtMeta = const VerificationMeta(
    'createAt',
  );
  @override
  late final GeneratedColumn<String> createAt = GeneratedColumn<String>(
    'create_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    login,
    email,
    password,
    image,
    role,
    createAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('login')) {
      context.handle(
        _loginMeta,
        login.isAcceptableOrUnknown(data['login']!, _loginMeta),
      );
    } else if (isInserting) {
      context.missing(_loginMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('create_at')) {
      context.handle(
        _createAtMeta,
        createAt.isAcceptableOrUnknown(data['create_at']!, _createAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      login: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      createAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}create_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UsersCompanion extends UpdateCompanion<UserModel> {
  final Value<String> id;
  final Value<String> login;
  final Value<String> email;
  final Value<String> password;
  final Value<String> image;
  final Value<String> role;
  final Value<String> createAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.login = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.image = const Value.absent(),
    this.role = const Value.absent(),
    this.createAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String login,
    required String email,
    required String password,
    required String image,
    this.role = const Value.absent(),
    required String createAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       login = Value(login),
       email = Value(email),
       password = Value(password),
       image = Value(image),
       createAt = Value(createAt);
  static Insertable<UserModel> custom({
    Expression<String>? id,
    Expression<String>? login,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? image,
    Expression<String>? role,
    Expression<String>? createAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (login != null) 'login': login,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (image != null) 'image': image,
      if (role != null) 'role': role,
      if (createAt != null) 'create_at': createAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? login,
    Value<String>? email,
    Value<String>? password,
    Value<String>? image,
    Value<String>? role,
    Value<String>? createAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      login: login ?? this.login,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
      role: role ?? this.role,
      createAt: createAt ?? this.createAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (login.present) {
      map['login'] = Variable<String>(login.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createAt.present) {
      map['create_at'] = Variable<String>(createAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('login: $login, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('image: $image, ')
          ..write('role: $role, ')
          ..write('createAt: $createAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$UserModelInsertable implements Insertable<UserModel> {
  UserModel _object;
  _$UserModelInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(_object.id),
      login: Value(_object.login),
      email: Value(_object.email),
      password: Value(_object.password),
      image: Value(_object.image),
      role: Value(_object.role),
      createAt: Value(_object.createAt),
    ).toColumns(false);
  }
}

extension UserModelToInsertable on UserModel {
  _$UserModelInsertable toInsertable() {
    return _$UserModelInsertable(this);
  }
}

class $AudiosTable extends Audios with TableInfo<$AudiosTable, AudioModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<String> creatorId = GeneratedColumn<String>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createAtMeta = const VerificationMeta(
    'createAt',
  );
  @override
  late final GeneratedColumn<String> createAt = GeneratedColumn<String>(
    'create_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    creatorId,
    link,
    createAt,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audios';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorIdMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    if (data.containsKey('create_at')) {
      context.handle(
        _createAtMeta,
        createAt.isAcceptableOrUnknown(data['create_at']!, _createAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_id'],
      )!,
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      )!,
      createAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}create_at'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $AudiosTable createAlias(String alias) {
    return $AudiosTable(attachedDatabase, alias);
  }
}

class AudiosCompanion extends UpdateCompanion<AudioModel> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> creatorId;
  final Value<String> link;
  final Value<String> createAt;
  final Value<String> description;
  final Value<int> rowid;
  const AudiosCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.link = const Value.absent(),
    this.createAt = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudiosCompanion.insert({
    required String id,
    required String name,
    required String creatorId,
    required String link,
    required String createAt,
    required String description,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       creatorId = Value(creatorId),
       link = Value(link),
       createAt = Value(createAt),
       description = Value(description);
  static Insertable<AudioModel> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? creatorId,
    Expression<String>? link,
    Expression<String>? createAt,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (creatorId != null) 'creator_id': creatorId,
      if (link != null) 'link': link,
      if (createAt != null) 'create_at': createAt,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudiosCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? creatorId,
    Value<String>? link,
    Value<String>? createAt,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return AudiosCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      link: link ?? this.link,
      createAt: createAt ?? this.createAt,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<String>(creatorId.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (createAt.present) {
      map['create_at'] = Variable<String>(createAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudiosCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorId: $creatorId, ')
          ..write('link: $link, ')
          ..write('createAt: $createAt, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$AudioModelInsertable implements Insertable<AudioModel> {
  AudioModel _object;
  _$AudioModelInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return AudiosCompanion(
      id: Value(_object.id),
      name: Value(_object.name),
      creatorId: Value(_object.creatorId),
      link: Value(_object.link),
      createAt: Value(_object.createAt),
      description: Value(_object.description),
    ).toColumns(false);
  }
}

extension AudioModelToInsertable on AudioModel {
  _$AudioModelInsertable toInsertable() {
    return _$AudioModelInsertable(this);
  }
}

class $ContractsTable extends Contracts
    with TableInfo<$ContractsTable, ContractModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<String> creatorId = GeneratedColumn<String>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createAtMeta = const VerificationMeta(
    'createAt',
  );
  @override
  late final GeneratedColumn<String> createAt = GeneratedColumn<String>(
    'create_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    creatorId,
    link,
    createAt,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contracts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContractModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorIdMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    if (data.containsKey('create_at')) {
      context.handle(
        _createAtMeta,
        createAt.isAcceptableOrUnknown(data['create_at']!, _createAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContractModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_id'],
      )!,
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      )!,
      createAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}create_at'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $ContractsTable createAlias(String alias) {
    return $ContractsTable(attachedDatabase, alias);
  }
}

class ContractsCompanion extends UpdateCompanion<ContractModel> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> creatorId;
  final Value<String> link;
  final Value<String> createAt;
  final Value<String> description;
  final Value<int> rowid;
  const ContractsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.link = const Value.absent(),
    this.createAt = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContractsCompanion.insert({
    required String id,
    required String name,
    required String creatorId,
    required String link,
    required String createAt,
    required String description,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       creatorId = Value(creatorId),
       link = Value(link),
       createAt = Value(createAt),
       description = Value(description);
  static Insertable<ContractModel> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? creatorId,
    Expression<String>? link,
    Expression<String>? createAt,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (creatorId != null) 'creator_id': creatorId,
      if (link != null) 'link': link,
      if (createAt != null) 'create_at': createAt,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContractsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? creatorId,
    Value<String>? link,
    Value<String>? createAt,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return ContractsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      link: link ?? this.link,
      createAt: createAt ?? this.createAt,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<String>(creatorId.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (createAt.present) {
      map['create_at'] = Variable<String>(createAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorId: $creatorId, ')
          ..write('link: $link, ')
          ..write('createAt: $createAt, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$ContractModelInsertable implements Insertable<ContractModel> {
  ContractModel _object;
  _$ContractModelInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return ContractsCompanion(
      id: Value(_object.id),
      name: Value(_object.name),
      creatorId: Value(_object.creatorId),
      link: Value(_object.link),
      createAt: Value(_object.createAt),
      description: Value(_object.description),
    ).toColumns(false);
  }
}

extension ContractModelToInsertable on ContractModel {
  _$ContractModelInsertable toInsertable() {
    return _$ContractModelInsertable(this);
  }
}

class $TranscriptionsTable extends Transcriptions
    with TableInfo<$TranscriptionsTable, TranscriptionModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<String> creatorId = GeneratedColumn<String>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createAtMeta = const VerificationMeta(
    'createAt',
  );
  @override
  late final GeneratedColumn<String> createAt = GeneratedColumn<String>(
    'create_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    creatorId,
    link,
    createAt,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranscriptionModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorIdMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    if (data.containsKey('create_at')) {
      context.handle(
        _createAtMeta,
        createAt.isAcceptableOrUnknown(data['create_at']!, _createAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranscriptionModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranscriptionModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_id'],
      )!,
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      )!,
      createAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}create_at'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $TranscriptionsTable createAlias(String alias) {
    return $TranscriptionsTable(attachedDatabase, alias);
  }
}

class TranscriptionsCompanion extends UpdateCompanion<TranscriptionModel> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> creatorId;
  final Value<String> link;
  final Value<String> createAt;
  final Value<String> description;
  final Value<int> rowid;
  const TranscriptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.link = const Value.absent(),
    this.createAt = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranscriptionsCompanion.insert({
    required String id,
    required String name,
    required String creatorId,
    required String link,
    required String createAt,
    required String description,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       creatorId = Value(creatorId),
       link = Value(link),
       createAt = Value(createAt),
       description = Value(description);
  static Insertable<TranscriptionModel> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? creatorId,
    Expression<String>? link,
    Expression<String>? createAt,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (creatorId != null) 'creator_id': creatorId,
      if (link != null) 'link': link,
      if (createAt != null) 'create_at': createAt,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranscriptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? creatorId,
    Value<String>? link,
    Value<String>? createAt,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return TranscriptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      link: link ?? this.link,
      createAt: createAt ?? this.createAt,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<String>(creatorId.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (createAt.present) {
      map['create_at'] = Variable<String>(createAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorId: $creatorId, ')
          ..write('link: $link, ')
          ..write('createAt: $createAt, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$TranscriptionModelInsertable implements Insertable<TranscriptionModel> {
  TranscriptionModel _object;
  _$TranscriptionModelInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return TranscriptionsCompanion(
      id: Value(_object.id),
      name: Value(_object.name),
      creatorId: Value(_object.creatorId),
      link: Value(_object.link),
      createAt: Value(_object.createAt),
      description: Value(_object.description),
    ).toColumns(false);
  }
}

extension TranscriptionModelToInsertable on TranscriptionModel {
  _$TranscriptionModelInsertable toInsertable() {
    return _$TranscriptionModelInsertable(this);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $AudiosTable audios = $AudiosTable(this);
  late final $ContractsTable contracts = $ContractsTable(this);
  late final $TranscriptionsTable transcriptions = $TranscriptionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    audios,
    contracts,
    transcriptions,
  ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String login,
  required String email,
  required String password,
  required String image,
  Value<String> role,
  required String createAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> login,
  Value<String> email,
  Value<String> password,
  Value<String> image,
  Value<String> role,
  Value<String> createAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$Database, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer extends Composer<_$Database, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer extends Composer<_$Database, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get login =>
      $composableBuilder(column: $table.login, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get createAt =>
      $composableBuilder(column: $table.createAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$Database,
          $UsersTable,
          UserModel,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserModel, BaseReferences<_$Database, $UsersTable, UserModel>),
          UserModel,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$Database db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> login = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> createAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                login: login,
                email: email,
                password: password,
                image: image,
                role: role,
                createAt: createAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String login,
                required String email,
                required String password,
                required String image,
                Value<String> role = const Value.absent(),
                required String createAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                login: login,
                email: email,
                password: password,
                image: image,
                role: role,
                createAt: createAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserModel>(table),
                  BaseReferences<_$Database, $UsersTable, UserModel>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $UsersTable,
      UserModel,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserModel, BaseReferences<_$Database, $UsersTable, UserModel>),
      UserModel,
      PrefetchHooks Function()
    >;
typedef $$AudiosTableCreateCompanionBuilder = AudiosCompanion Function({
  required String id,
  required String name,
  required String creatorId,
  required String link,
  required String createAt,
  required String description,
  Value<int> rowid,
});
typedef $$AudiosTableUpdateCompanionBuilder = AudiosCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> creatorId,
  Value<String> link,
  Value<String> createAt,
  Value<String> description,
  Value<int> rowid,
});

class $$AudiosTableFilterComposer extends Composer<_$Database, $AudiosTable> {
  $$AudiosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudiosTableOrderingComposer extends Composer<_$Database, $AudiosTable> {
  $$AudiosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudiosTableAnnotationComposer
    extends Composer<_$Database, $AudiosTable> {
  $$AudiosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get createAt =>
      $composableBuilder(column: $table.createAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$AudiosTableTableManager
    extends
        RootTableManager<
          _$Database,
          $AudiosTable,
          AudioModel,
          $$AudiosTableFilterComposer,
          $$AudiosTableOrderingComposer,
          $$AudiosTableAnnotationComposer,
          $$AudiosTableCreateCompanionBuilder,
          $$AudiosTableUpdateCompanionBuilder,
          (AudioModel, BaseReferences<_$Database, $AudiosTable, AudioModel>),
          AudioModel,
          PrefetchHooks Function()
        > {
  $$AudiosTableTableManager(_$Database db, $AudiosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> creatorId = const Value.absent(),
                Value<String> link = const Value.absent(),
                Value<String> createAt = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiosCompanion(
                id: id,
                name: name,
                creatorId: creatorId,
                link: link,
                createAt: createAt,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String creatorId,
                required String link,
                required String createAt,
                required String description,
                Value<int> rowid = const Value.absent(),
              }) => AudiosCompanion.insert(
                id: id,
                name: name,
                creatorId: creatorId,
                link: link,
                createAt: createAt,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudiosTable, AudioModel>(table),
                  BaseReferences<_$Database, $AudiosTable, AudioModel>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudiosTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $AudiosTable,
      AudioModel,
      $$AudiosTableFilterComposer,
      $$AudiosTableOrderingComposer,
      $$AudiosTableAnnotationComposer,
      $$AudiosTableCreateCompanionBuilder,
      $$AudiosTableUpdateCompanionBuilder,
      (AudioModel, BaseReferences<_$Database, $AudiosTable, AudioModel>),
      AudioModel,
      PrefetchHooks Function()
    >;
typedef $$ContractsTableCreateCompanionBuilder = ContractsCompanion Function({
  required String id,
  required String name,
  required String creatorId,
  required String link,
  required String createAt,
  required String description,
  Value<int> rowid,
});
typedef $$ContractsTableUpdateCompanionBuilder = ContractsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> creatorId,
  Value<String> link,
  Value<String> createAt,
  Value<String> description,
  Value<int> rowid,
});

class $$ContractsTableFilterComposer
    extends Composer<_$Database, $ContractsTable> {
  $$ContractsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContractsTableOrderingComposer
    extends Composer<_$Database, $ContractsTable> {
  $$ContractsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContractsTableAnnotationComposer
    extends Composer<_$Database, $ContractsTable> {
  $$ContractsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get createAt =>
      $composableBuilder(column: $table.createAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$ContractsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ContractsTable,
          ContractModel,
          $$ContractsTableFilterComposer,
          $$ContractsTableOrderingComposer,
          $$ContractsTableAnnotationComposer,
          $$ContractsTableCreateCompanionBuilder,
          $$ContractsTableUpdateCompanionBuilder,
          (
            ContractModel,
            BaseReferences<_$Database, $ContractsTable, ContractModel>,
          ),
          ContractModel,
          PrefetchHooks Function()
        > {
  $$ContractsTableTableManager(_$Database db, $ContractsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> creatorId = const Value.absent(),
                Value<String> link = const Value.absent(),
                Value<String> createAt = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContractsCompanion(
                id: id,
                name: name,
                creatorId: creatorId,
                link: link,
                createAt: createAt,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String creatorId,
                required String link,
                required String createAt,
                required String description,
                Value<int> rowid = const Value.absent(),
              }) => ContractsCompanion.insert(
                id: id,
                name: name,
                creatorId: creatorId,
                link: link,
                createAt: createAt,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContractsTable, ContractModel>(table),
                  BaseReferences<_$Database, $ContractsTable, ContractModel>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContractsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ContractsTable,
      ContractModel,
      $$ContractsTableFilterComposer,
      $$ContractsTableOrderingComposer,
      $$ContractsTableAnnotationComposer,
      $$ContractsTableCreateCompanionBuilder,
      $$ContractsTableUpdateCompanionBuilder,
      (
        ContractModel,
        BaseReferences<_$Database, $ContractsTable, ContractModel>,
      ),
      ContractModel,
      PrefetchHooks Function()
    >;
typedef $$TranscriptionsTableCreateCompanionBuilder =
    TranscriptionsCompanion Function({
      required String id,
      required String name,
      required String creatorId,
      required String link,
      required String createAt,
      required String description,
      Value<int> rowid,
    });
typedef $$TranscriptionsTableUpdateCompanionBuilder =
    TranscriptionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> creatorId,
      Value<String> link,
      Value<String> createAt,
      Value<String> description,
      Value<int> rowid,
    });

class $$TranscriptionsTableFilterComposer
    extends Composer<_$Database, $TranscriptionsTable> {
  $$TranscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TranscriptionsTableOrderingComposer
    extends Composer<_$Database, $TranscriptionsTable> {
  $$TranscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranscriptionsTableAnnotationComposer
    extends Composer<_$Database, $TranscriptionsTable> {
  $$TranscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get createAt =>
      $composableBuilder(column: $table.createAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$TranscriptionsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $TranscriptionsTable,
          TranscriptionModel,
          $$TranscriptionsTableFilterComposer,
          $$TranscriptionsTableOrderingComposer,
          $$TranscriptionsTableAnnotationComposer,
          $$TranscriptionsTableCreateCompanionBuilder,
          $$TranscriptionsTableUpdateCompanionBuilder,
          (
            TranscriptionModel,
            BaseReferences<
              _$Database,
              $TranscriptionsTable,
              TranscriptionModel
            >,
          ),
          TranscriptionModel,
          PrefetchHooks Function()
        > {
  $$TranscriptionsTableTableManager(_$Database db, $TranscriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> creatorId = const Value.absent(),
                Value<String> link = const Value.absent(),
                Value<String> createAt = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranscriptionsCompanion(
                id: id,
                name: name,
                creatorId: creatorId,
                link: link,
                createAt: createAt,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String creatorId,
                required String link,
                required String createAt,
                required String description,
                Value<int> rowid = const Value.absent(),
              }) => TranscriptionsCompanion.insert(
                id: id,
                name: name,
                creatorId: creatorId,
                link: link,
                createAt: createAt,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TranscriptionsTable, TranscriptionModel>(table),
                  BaseReferences<
                    _$Database,
                    $TranscriptionsTable,
                    TranscriptionModel
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TranscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $TranscriptionsTable,
      TranscriptionModel,
      $$TranscriptionsTableFilterComposer,
      $$TranscriptionsTableOrderingComposer,
      $$TranscriptionsTableAnnotationComposer,
      $$TranscriptionsTableCreateCompanionBuilder,
      $$TranscriptionsTableUpdateCompanionBuilder,
      (
        TranscriptionModel,
        BaseReferences<_$Database, $TranscriptionsTable, TranscriptionModel>,
      ),
      TranscriptionModel,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$AudiosTableTableManager get audios =>
      $$AudiosTableTableManager(_db, _db.audios);
  $$ContractsTableTableManager get contracts =>
      $$ContractsTableTableManager(_db, _db.contracts);
  $$TranscriptionsTableTableManager get transcriptions =>
      $$TranscriptionsTableTableManager(_db, _db.transcriptions);
}
