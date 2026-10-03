import 'package:corp_app/domain/repository/storage_repository.dart';
import 'package:corp_app/domain/repository/web_repository.dart';

class WebService {
  static final WebRepository _webRepository = WebRepository();
  static final StorageRepository _sRepository = StorageRepository.instance;

  void get potato {
    _webRepository;
    _sRepository;
  }
}
