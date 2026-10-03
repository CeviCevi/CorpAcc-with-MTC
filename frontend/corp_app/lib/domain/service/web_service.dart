import 'package:corp_app/domain/repository/storage_repository.dart';
import 'package:corp_app/domain/repository/web_repository.dart';

class WebService {
  static WebRepository webRepository = WebRepository();
  static StorageRepository sRepository = StorageRepository.instance;

  void get potato {
    webRepository;
    sRepository;
  }

  static Future<bool> getAudioById(String userId) async {
    return true;
  }
}
