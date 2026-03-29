import 'package:dio/dio.dart';

class NetworkService {
  final Dio _dio;

  NetworkService._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: "https://reqres.in/api",
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key':
                'pub_d69c11d63bb677b7d0d6a57c0aa47abb593cc89994d891d985596216653736a2',
          },
        ),
      );

  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  ///  COMMON ERROR HANDLER
  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout. Try again.";
      case DioExceptionType.sendTimeout:
        return "Request timeout. Try again.";
      case DioExceptionType.receiveTimeout:
        return "Server is taking too long.";
      case DioExceptionType.badResponse:
        return "Server error (${e.response?.statusCode})";
      case DioExceptionType.connectionError:
        return "No internet connection.";
      default:
        return "Something went wrong";
    }
  }

  /// GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// PUT
  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    try {
      return await _dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  ///  DELETE
  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(path);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Dio get client => _dio;
}
