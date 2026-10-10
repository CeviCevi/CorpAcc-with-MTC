import 'package:corp_app/data/model/audio_model.dart';
import 'package:corp_app/domain/service/web_service.dart';

class AudioService {
  static WebService _ws = WebService();

  //! For All
  static Future<AudioModel> getById({required String audioId}) async {
    //* Audio
    return AudioModel.empty;
  }

  static Future<bool> deleteById({required String audioId}) async {
    //* http 200
    return true;
  }

  static Future<bool> updateMeta({required AudioModel audio}) async {
    //* http 200
    return true;
  }

  static Future<bool> updateById({
    required String audioId,
    required String pathToNewAudio,
  }) async {
    //* http 200
    return true;
  }

  static Future<AudioModel> download({required AudioModel audio}) async {
    //* Audio
    return AudioModel.empty;
  }

  static Future<AudioModel> upload({required AudioModel audio}) async {
    //* Audio
    return AudioModel.empty;
  }

  static Future<List<AudioModel>> getAllByUserId({
    required String userId,
  }) async {
    //* Audio List
    return [];
  }

  static Future<List<AudioModel>> getAllByCorpId({
    required AudioModel audio,
  }) async {
    //* Audio List
    return [];
  }
}
