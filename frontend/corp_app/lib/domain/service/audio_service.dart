import 'dart:developer';
import 'dart:io';

import 'package:corp_app/app/app_path/app_path.dart';
import 'package:corp_app/data/model/audio_model.dart';
import 'package:corp_app/data/short_db/short_db.dart';
import 'package:corp_app/data/storage/database/database.dart';
import 'package:corp_app/domain/repository/storage_repository.dart';
import 'package:corp_app/domain/repository/web_repository.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AudioService {
  static final StorageRepository _storage = StorageRepository.instance;
  static final Dio _dio = Dio();

  static String _audioDirectory(String userId, String audioId) {
    // Папка будет внутри Documents/corp_app.
    final base = Directory(
      p.join(Directory.systemTemp.path, 'corp_app_audio', userId, audioId),
    );

    return base.path;
  }

  /// Путь к локально сохранённому аудиофайлу.
  static Future<String> getLocalFilePath({
    required String userId,
    required String audioId,
  }) async {
    final documents = await getApplicationDocumentsDirectory();

    return p.join(documents.path, 'corp_app', userId, audioId, 'аудио.wav');
  }

  static Future<void> _saveLocal(AudioModel audio) async {
    await _storage.db
        .into(_storage.db.audios)
        .insertOnConflictUpdate(audio.toInsertable());
  }

  static Future<void> _deleteLocal(String audioId) async {
    await (_storage.db.delete(
      _storage.db.audios,
    )..where((table) => table.id.equals(audioId))).go();
  }

  static Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  static List<dynamic> _asList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final nested = data['data'] ?? data['audios'];
      if (nested is List) return nested;
    }

    return [];
  }

  //! For All

  static Future<AudioModel> getById({required String audioId}) async {
    final response = await WebRepository.getHttp(
      path: '${AppPath.audioGetById}/$audioId',
    );

    if (response.containsKey('error')) {
      final local = await (_storage.db.select(
        _storage.db.audios,
      )..where((table) => table.id.equals(audioId))).getSingleOrNull();

      if (local != null) return local;
      throw Exception(response['error']);
    }

    final audio = AudioModel.fromJson(response);
    await _saveLocal(audio);
    return audio;
  }

  static Future<bool> deleteById({required String audioId}) async {
    final response = await WebRepository.deleteHttp(
      path: '${AppPath.audioDestroyById}/$audioId',
    );

    if (response.containsKey('error')) return false;

    await _deleteLocal(audioId);
    return true;
  }

  static Future<bool> updateMeta({required AudioModel audio}) async {
    final response = await WebRepository.putHttp(
      path: AppPath.audioUpdateMeta,
      data: audio.toJson(),
    );

    if (response.containsKey('error')) return false;

    await _saveLocal(audio);
    return true;
  }

  /// Заменяет аудиофайл на сервере.
  /// pathToNewAudio — путь к новому локальному файлу.
  static Future<bool> updateById({
    required String audioId,
    required String pathToNewAudio,
  }) async {
    final file = File(pathToNewAudio);
    if (!await file.exists()) {
      throw FileSystemException('Аудиофайл не найден', pathToNewAudio);
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        pathToNewAudio,
        filename: p.basename(pathToNewAudio),
      ),
    });

    final response = await _dio.post(
      '${AppPath.audioUpload}/$audioId',
      data: form,
    );

    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }

  /// Скачивает аудиофайл в папку:
  // ignore: unintended_html_in_doc_comment
  /// Documents/corp_app/<creatorId>/<audioId>/аудио.wav
  ///
  /// Возвращает метаданные аудио. Путь к файлу можно получить
  /// через getLocalFilePath().
  static Future<AudioModel> download({required AudioModel audio}) async {
    final savePath = await getLocalFilePath(
      userId: audio.creatorId,
      audioId: audio.id,
    );

    final file = File(savePath);
    await file.parent.create(recursive: true);

    await _dio.download(
      '${AppPath.audioDownload}/${audio.id}',
      savePath,
      options: Options(responseType: ResponseType.bytes),
    );

    await _saveLocal(audio);
    return audio;
  }

  static Future<String> downloadFile({required AudioModel audio}) async {
    final savePath = await getLocalFilePath(
      userId: audio.creatorId,
      audioId: audio.id,
    );

    final file = File(savePath);
    await file.parent.create(recursive: true);

    await _dio.download(
      '${AppPath.audioDownload}/${audio.id}',
      savePath,
      options: Options(responseType: ResponseType.bytes),
    );

    if (!await file.exists() || await file.length() == 0) {
      throw FileSystemException('Не удалось скачать аудиофайл', savePath);
    }

    await _saveLocal(audio);

    return savePath;
  }

  /// Отправляет файл на сервер.
  /// audio.link должен содержать путь к существующему локальному файлу.
  static Future<AudioModel> upload({required AudioModel audio}) async {
    final file = File(audio.link);
    if (!await file.exists()) {
      throw FileSystemException('Аудиофайл не найден', audio.link);
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        audio.link,
        filename: p.basename(audio.link),
      ),
    });

    final response = await _dio.post(
      '${AppPath.audioUpload}/${ShortDb.instance.userInSystem.id}',
      data: form,
    );

    final result = _asMap(response.data);
    final uploaded = result == null
        ? audio
        : AudioModel.fromJson({...audio.toJson(), ...result});

    await _saveLocal(uploaded);
    return uploaded;
  }

  static Future<List<AudioModel>> getAllByUserId({
    required String userId,
  }) async {
    final response = await WebRepository.getHttp(
      path: '${AppPath.audioGetAllByUserId}/$userId',
    );

    if (response.containsKey('error')) {
      return (_storage.db.select(
        _storage.db.audios,
      )..where((table) => table.creatorId.equals(userId))).get();
    }

    final audios = _asList(response['data'] ?? response['audios'] ?? response)
        .whereType<Map>()
        .map((json) => AudioModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    for (final audio in audios) {
      await _saveLocal(audio);
    }

    return audios;
  }

  static Future<List<AudioModel>> getAllByCorpId({
    required String corpId,
  }) async {
    final response = await WebRepository.getHttp(
      path: '${AppPath.audioGetAllByCorpId}/$corpId',
    );
    log(response.toString());
    // if (response.containsKey('error')) {
    //   throw Exception(response['error']);
    // }

    final audios = _asList(response['data'] ?? response['audios'] ?? response)
        .whereType<Map>()
        .map((json) => AudioModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    for (final audio in audios) {
      await _saveLocal(audio);
    }

    return audios;
  }

  static Future<AudioModel> createAudio({required AudioModel audio}) async {
    final response = await WebRepository.postHttp(
      path: AppPath.createAudio,
      data: audio.toJson(),
    );

    if (response.containsKey('error')) {
      throw Exception(response['error']);
    }

    return AudioModel.fromJson(response);
  }
}
