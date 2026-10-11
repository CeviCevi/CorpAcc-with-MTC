import 'dart:convert';
import 'dart:io';

import 'package:corp_app/app/app_path/app_path.dart';
import 'package:corp_app/data/model/contract_model.dart';
import 'package:corp_app/data/storage/database/database.dart';
import 'package:corp_app/domain/repository/storage_repository.dart';
import 'package:corp_app/domain/repository/web_repository.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class ContractService {
  static final StorageRepository _storage = StorageRepository.instance;
  static final Dio _dio = Dio();

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw FormatException('Ожидался JSON-объект контракта');
  }

  static List<dynamic> _toList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final nested = data['data'] ?? data['contracts'];
      if (nested is List) return nested;
    }

    throw FormatException('Ожидался список контрактов');
  }

  static Future<void> _saveMeta(ContractModel contract) async {
    await _storage.db
        .into(_storage.db.contracts)
        .insertOnConflictUpdate(contract.toInsertable());
  }

  static Future<void> _deleteLocal(String id) async {
    await (_storage.db.delete(
      _storage.db.contracts,
    )..where((table) => table.id.equals(id))).go();
  }

  //! Получить метаданные контракта
  static Future<ContractModel> getById({required String contractId}) async {
    final response = await WebRepository.getHttp(
      path: '${AppPath.contractGetById}/$contractId',
    );

    if (response.containsKey('error')) {
      final local = await (_storage.db.select(
        _storage.db.contracts,
      )..where((table) => table.id.equals(contractId))).getSingleOrNull();

      if (local != null) return local;
      throw Exception(response['error']);
    }

    final contract = ContractModel.fromJson(response);
    await _saveMeta(contract);
    return contract;
  }

  //! Удалить контракт
  static Future<bool> deleteById({required String contractId}) async {
    final response = await WebRepository.deleteHttp(
      path: '${AppPath.contractDestroyById}/$contractId',
    );

    if (response.containsKey('error')) return false;

    await _deleteLocal(contractId);
    return true;
  }

  //! Обновить метаданные
  static Future<bool> updateMeta({required ContractModel contract}) async {
    final response = await WebRepository.putHttp(
      path: AppPath.contractUpdateMeta,
      data: contract.toJson(),
    );

    if (response.containsKey('error')) return false;

    await _saveMeta(contract);
    return true;
  }

  //! Заменить файл контракта
  static Future<bool> updateById({
    required String contractId,
    required String pathToNewAudio,
  }) async {
    return _uploadFile(contractId: contractId, filePath: pathToNewAudio);
  }

  //! Получить содержимое контракта из интернета.
  //! Возвращает Map и ничего не сохраняет локально.
  static Future<Map<String, dynamic>> download({
    required ContractModel contract,
  }) async {
    final response = await _dio.get<dynamic>(
      '${AppPath.contractDownload}/${contract.id}',
      options: Options(responseType: ResponseType.json),
    );

    dynamic data = response.data;

    // Если сервер вернул JSON строкой.
    if (data is String) {
      data = jsonDecode(data);
    }

    return _toMap(data);
  }

  //! Отправить JSON-файл контракта на сервер.
  //! Возвращает метаданные контракта.
  static Future<ContractModel> upload({required ContractModel contract}) async {
    final file = File(contract.link);

    if (!await file.exists()) {
      throw FileSystemException('Файл контракта не найден', contract.link);
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: p.basename(file.path),
      ),
    });

    final response = await _dio.post<dynamic>(
      '${AppPath.contractUpload}/${contract.id}',
      data: form,
    );

    final data = response.data;
    if (data is Map || data is Map<String, dynamic>) {
      final result = ContractModel.fromJson(_toMap(data));
      await _saveMeta(result);
      return result;
    }

    await _saveMeta(contract);
    return contract;
  }

  //! Получить список метаданных пользователя
  static Future<List<ContractModel>> getAllByUserId({
    required String userId,
  }) async {
    final response = await WebRepository.getHttp(
      path: '${AppPath.contractGetAllByUserId}/$userId',
    );

    if (response.containsKey('error')) {
      return (_storage.db.select(
        _storage.db.contracts,
      )..where((table) => table.creatorId.equals(userId))).get();
    }

    final contracts =
        _toList(response['data'] ?? response['contracts'] ?? response)
            .whereType<Map>()
            .map((item) {
              return ContractModel.fromJson(Map<String, dynamic>.from(item));
            })
            .toList();

    for (final contract in contracts) {
      await _saveMeta(contract);
    }

    return contracts;
  }

  //! Получить список метаданных компании
  static Future<List<ContractModel>> getAllByCorpId({
    required String corpId,
  }) async {
    final response = await WebRepository.getHttp(
      path: '${AppPath.contractGetAllByCorpId}/$corpId',
    );

    if (response.containsKey('error')) {
      throw Exception(response['error']);
    }

    final contracts =
        _toList(response['data'] ?? response['contracts'] ?? response)
            .whereType<Map>()
            .map((item) {
              return ContractModel.fromJson(Map<String, dynamic>.from(item));
            })
            .toList();

    for (final contract in contracts) {
      await _saveMeta(contract);
    }

    return contracts;
  }

  static Future<bool> _uploadFile({
    required String contractId,
    required String filePath,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw FileSystemException('Файл не найден', filePath);
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: p.basename(filePath),
      ),
    });

    final response = await _dio.post<dynamic>(
      '${AppPath.contractUpload}/$contractId',
      data: form,
    );

    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }
}
