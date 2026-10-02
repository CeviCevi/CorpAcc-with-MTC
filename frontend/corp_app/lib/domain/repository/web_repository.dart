import 'package:dio/dio.dart';

class WebRepository {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>> getHttp({
    required String path,
    Map<String, dynamic>? data,
  }) async {
    try {
      final Response response = await _dio.get(path, queryParameters: data);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {"error": "${response.data.runtimeType}"};
    } on DioException catch (e) {
      return {"error": e.message ?? "Unknown error"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> postHttp({
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final Response response = await _dio.post(
        path,
        data: data,
        queryParameters: query,
      );
      return {"error": "${response.data.runtimeType}"};
    } on DioException catch (e) {
      return {"error": e.message ?? "Unknown error"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> putHttp({
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final Response response = await _dio.put(
        path,
        data: data,
        queryParameters: query,
      );
      return {"error": "${response.data.runtimeType}"};
    } on DioException catch (e) {
      return {"error": e.message ?? "Unknown error"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> patchHttp({
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final Response response = await _dio.patch(
        path,
        data: data,
        queryParameters: query,
      );
      return {"error": "${response.data.runtimeType}"};
    } on DioException catch (e) {
      return {"error": e.message ?? "Unknown error"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteHttp({
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final Response response = await _dio.delete(
        path,
        data: data,
        queryParameters: query,
      );
      return {"error": "${response.data.runtimeType}"};
    } on DioException catch (e) {
      return {"error": e.message ?? "Unknown error"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }
}
