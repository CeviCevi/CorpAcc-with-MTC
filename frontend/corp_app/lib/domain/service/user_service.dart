import 'dart:developer';

import 'package:corp_app/app/app_const.dart';
import 'package:corp_app/app/app_path/app_path.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/data/short_db/short_db.dart';
import 'package:corp_app/data/short_db/sp.dart';
import 'package:corp_app/domain/repository/storage_repository.dart';
import 'package:corp_app/domain/repository/web_repository.dart';

class UserService {
  static final StorageRepository _storage = StorageRepository.instance;

  static Future<Map<String, dynamic>> _get({required String path}) {
    return WebRepository.getHttp(path: path);
  }

  static Future<Map<String, dynamic>> _post({
    required String path,
    Map<String, dynamic>? data,
  }) {
    return WebRepository.postHttp(path: path, data: data);
  }

  static Future<Map<String, dynamic>> _put({
    required String path,
    Map<String, dynamic>? data,
  }) {
    return WebRepository.putHttp(path: path, data: data);
  }

  static Future<Map<String, dynamic>> _delete({required String path}) {
    return WebRepository.deleteHttp(path: path);
  }

  static bool _hasError(Map<String, dynamic> result) {
    return result.containsKey('error');
  }

  static UserModel _userFromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      login: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      role: json['status']?.toString() ?? 'DEFAULT',
      createAt: json['createdAt']?.toString() ?? '',
    );
  }

  static Future<void> _saveUser(UserModel user) async {
    await _storage.init();
    await _storage.upsertUser(user);
  }

  static Future<void> _removeUser(String id) async {
    await _storage.init();
    await _storage.deleteUser(id);
  }

  // Регистрация
  static Future<bool> registration({required UserModel user}) async {
    final result = await _post(path: AppPath.registration, data: user.toJson());

    //if (_hasError(result)) return false;

    if (result['id'] != null) {
      ShortDb.instance.userInSystem = _userFromJson(result);
      await _saveUser(_userFromJson(result));
    } else {
      return false;
    }

    Sp.instance.prefs.setString(
      AppConst.userInSystemId,
      ShortDb.instance.userInSystem.id.toString(),
    );
    return true;
  }

  // Вход
  static Future<bool> login({required UserModel user}) async {
    final result = await _post(path: AppPath.login, data: user.toJson());

    //if (_hasError(result)) return false;

    if (result['id'] != null) {
      ShortDb.instance.userInSystem = _userFromJson(result);
      await _saveUser(_userFromJson(result));
    } else {
      return false;
    }

    Sp.instance.prefs.setString(
      AppConst.userInSystemId,
      ShortDb.instance.userInSystem.id.toString(),
    );
    return true;
  }

  // Удаление своего аккаунта
  static Future<bool> deleteMyAcc({required String userId}) async {
    final result = await _delete(path: '${AppPath.destroyMyAcc}/$userId');

    if (_hasError(result)) return false;

    await _removeUser(userId);
    return true;
  }

  // Обновление пользователя
  static Future<bool> updateMyAcc({required UserModel user}) async {
    final result = await _put(
      path: AppPath.updateMyAcc,
      data: {
        'id': user.id,
        'name': user.login,
        'email': user.email,
        'password': user.password,
        'status': user.role,
      },
    );

    if (_hasError(result)) return false;

    await _saveUser(user);
    return true;
  }

  // Обновление фотографии.
  // Использует общий endpoint PUT /api/users.
  static Future<bool> updateMyPhoto({
    required String userId,
    required String photo,
  }) async {
    final current = await getUserById(userId: userId);

    if (current.id == UserModel.empty.id) return false;

    final updated = current.copyWith(image: photo);
    return updateMyAcc(user: updated);
  }

  // Получение пользователя по ID
  static Future<UserModel> getUserById({required String userId}) async {
    final result = await _get(path: '${AppPath.getUserById}/$userId');

    final user = _userFromJson(result);
    await _saveUser(user);
    return user;
  }

  static Future<UserModel> getUserByEmail({required String email}) async {
    final result = await _get(path: '${AppPath.getUserByEmail}/$email');

    final user = _userFromJson(result);
    await _saveUser(user);
    return user;
  }

  // Добавление пользователя в корпорацию
  static Future<bool> setUserInCorpByEmail({
    required String corpId,
    required String userEmail,
  }) async {
    final result = await _post(
      path: '${AppPath.setUserInCorpByEmail}/$corpId/$userEmail',
    );

    return !_hasError(result);
  }

  // Получение пользователей корпорации
  static Future<List<UserModel>> getAllUsersInCorp({
    required String corpId,
  }) async {
    final result = await _get(path: '${AppPath.getAllUsersInCorp}/$corpId');

    if (_hasError(result)) return [];

    final rawUsers = result['users'] ?? result['data'];

    if (rawUsers is! List) return [];

    final users = rawUsers
        .whereType<Map>()
        .map((item) => _userFromJson(Map<String, dynamic>.from(item)))
        .toList();

    for (final user in users) {
      await _saveUser(user);
    }

    return users;
  }

  // Удаление пользователя из корпорации.
  // В таблице endpoint указан как /api/users/delete/{id}.
  static Future<bool> deleteUserInCorpById({
    required String corpId,
    required String userId,
  }) async {
    final result = await _delete(
      path: '${AppPath.deleteUserInCorpById}/\$$userId',
    );

    if (_hasError(result)) return false;

    await _removeUser(userId);
    return true;
  }

  // Для блокировки в предоставленной таблице отдельного endpoint нет.
  static Future<bool> banUserById({
    required String userId,
    required String status,
  }) async {
    throw UnimplementedError(
      'Для блокировки пользователя нужно указать endpoint бэкенда.',
    );
  }
}

Future<void> main(List<String> args) async {
  // await UserService.registration(user: UserModel.empty.copyWith(email: "33"));
  //c7e747cf-89b3-4179-a649-9b3a563afc3d
  log(
    (await UserService.login(
      user: ShortDb.instance.userInSystem.copyWith(
        login: "NoN",
        password: "Non",
        email: "33",
      ),
    )).toString(),
  );
  log(
    (await UserService.getUserById(userId: ShortDb.instance.userInSystem.id))
        .toString(),
  );
  log(ShortDb.instance.userInSystem.toString());
  log(
    (await StorageRepository.instance.getUserById(
      ShortDb.instance.userInSystem.id,
    )).toString(),
  );
  // log(
  //   (await UserService.deleteMyAcc(userId: ShortDb.instance.userInSystem.id))
  //       .toString(),
  // );

  log(
    (await UserService.updateMyAcc(
      user: ShortDb.instance.userInSystem.copyWith(role: "DEFAULT"),
    )).toString(),
  );

  log(
    (await UserService.setUserInCorpByEmail(
      corpId: "a9adef01-b147-42cb-aab9-c07c99a529a4",
      userEmail: "33",
    )).toString(),
  );

  log(
    (await UserService.getAllUsersInCorp(
      corpId: "a9adef01-b147-42cb-aab9-c07c99a529a4",
    )).toString(),
  );

  log((await UserService.getUserByEmail(email: "33")).toString());
}
