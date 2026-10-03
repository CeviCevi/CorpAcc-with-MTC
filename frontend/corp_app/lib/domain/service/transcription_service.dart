import 'package:corp_app/data/model/transcription_model.dart';
import 'package:corp_app/domain/service/web_service.dart';

class TranscriptionService {
  static WebService _ws = WebService();

  //! For All
  static Future<TranscriptionModel> getById({required String audioId}) async {
    //* Transcription
    return TranscriptionModel.empty;
  }

  static Future<bool> deleteById({required String audioId}) async {
    //* http 200
    return true;
  }

  static Future<bool> updateMeta({required TranscriptionModel audio}) async {
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

  static Future<TranscriptionModel> download({
    required TranscriptionModel audio,
  }) async {
    //* Transcription
    return TranscriptionModel.empty;
  }

  static Future<TranscriptionModel> upload({
    required TranscriptionModel audio,
  }) async {
    //* Transcription
    return TranscriptionModel.empty;
  }

  static Future<List<TranscriptionModel>> getAllByUserId({
    required TranscriptionModel audio,
  }) async {
    //* Transcription List
    return [];
  }

  static Future<List<TranscriptionModel>> getAllByCorpId({
    required TranscriptionModel audio,
  }) async {
    //* Transcription List
    return [];
  }
}
