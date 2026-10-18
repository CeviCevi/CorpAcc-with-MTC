import 'package:corp_app/app/app_path/app_path.dart';
import 'package:corp_app/data/model/transcription_model.dart';
import 'package:dio/dio.dart';

class TranscriptionService {
  static final Dio _dio = Dio();

  //! Получить метаданные по ID
  static Future<TranscriptionModel> getById({required String audioId}) async {
    try {
      final response = await _dio.get(
        '${AppPath.transcriptionGetById}/$audioId',
      );

      if (response.data is Map<String, dynamic>) {
        return TranscriptionModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return TranscriptionModel.empty;
    } catch (_) {
      return TranscriptionModel.empty;
    }
  }

  //! Удалить транскрипцию
  static Future<bool> deleteById({required String audioId}) async {
    try {
      final response = await _dio.delete(
        '${AppPath.transcriptionDestroyById}/$audioId',
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  //! Обновить метаданные
  static Future<bool> updateMeta({required TranscriptionModel audio}) async {
    try {
      final response = await _dio.put(
        AppPath.transcriptionUpdateMeta,
        data: audio.toJson(),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  //! Загрузить новый файл транскрипции
  static Future<bool> updateById({
    required String audioId,
    required String pathToNewAudio,
  }) async {
    try {
      final response = await _dio.post(
        '${AppPath.transcriptionUpload}/$audioId',
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(pathToNewAudio),
        }),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  //! Скачать содержимое — возвращает обычную строку
  static Future<String> download({required String audioId}) async {
    try {
      final response = await _dio.get(
        '${AppPath.transcriptionDownload}/$audioId',
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data.toString();
      }

      return '';
    } catch (_) {
      return '';
    }
  }

  //! Загрузить транскрипцию
  static Future<TranscriptionModel> upload({
    required TranscriptionModel audio,
  }) async {
    try {
      final response = await _dio.post(
        '${AppPath.transcriptionUpload}/${audio.id}',
        data: audio.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        return TranscriptionModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return audio;
    } catch (_) {
      return TranscriptionModel.empty;
    }
  }

  //! Получить все транскрипции пользователя
  static Future<List<TranscriptionModel>> getAllByUserId({
    required String userId,
  }) async {
    try {
      final response = await _dio.get(
        '${AppPath.transcriptionGetAllByUserId}/$userId',
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(TranscriptionModel.fromJson)
            .toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  //! Получить все транскрипции организации
  static Future<List<TranscriptionModel>> getAllByCorpId({
    required String corpId,
  }) async {
    try {
      final response = await _dio.get(
        '${AppPath.transcriptionGetAllByCorpId}/$corpId',
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(TranscriptionModel.fromJson)
            .toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }
}
