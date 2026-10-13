import 'package:shared_preferences/shared_preferences.dart';

class Sp {
  Sp._();
  static final Sp instance = Sp._();
  late final SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }
}
