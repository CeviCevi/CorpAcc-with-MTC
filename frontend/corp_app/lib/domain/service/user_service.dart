import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/domain/service/web_service.dart';

class UserService {
  static WebService _ws = WebService();

  //! for all
  static Future<bool> registration({
    required String mail,
    required String password,
  }) async {
    //* http 200
    return true;
  }

  static Future<bool> login({
    required String mail,
    required String password,
  }) async {
    //* http 200
    return true;
  }

  static Future<bool> deleteMyAcc({required String userId}) async {
    //* http 200
    return true;
  }

  static Future<bool> updateMyAcc({required UserModel user}) async {
    //* http 200
    return true;
  }

  static Future<bool> updateMyPhoto({
    required String userId,
    required String photo,
  }) async {
    //* http 200
    return true;
  }

  static Future<UserModel> getUserById({required String userId}) async {
    //* User
    return UserModel.empty;
  }

  //! for corp
  static Future<bool> setUserInCorpByEmail({
    required String corpId,
    required String userEmail,
  }) async {
    //* http 200
    return true;
  }

  static Future<List<UserModel>> getAllUsersInCorp({
    required String corpId,
  }) async {
    //* UserList
    return [];
  }

  static Future<bool> deleteUserInCorpById({
    required String corpId,
    required String userId,
  }) async {
    //* http 200
    return true;
  }

  static Future<bool> banUserById({
    required String userId,
    required String status,
  }) async {
    //* http 200
    return true;
  }
}
