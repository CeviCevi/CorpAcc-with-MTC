import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppConst {
  static final double height = 500;
  static final double width = 400;

  static late final String appDataPath;

  static final String userInSystemId = "userInSystemId";
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    appDataPath = '${dir.path}${Platform.pathSeparator}CorpAcc';

    await Directory(appDataPath).create(recursive: true);
  }
}
