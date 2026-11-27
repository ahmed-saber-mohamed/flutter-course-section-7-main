import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(
    this.message, {
    this.statusCode,
  });

  factory ApiException.fromDioException(DioException e) {
    final response = e.response;
    final code = response?.statusCode;
    final data = response?.data;

    if (data is Map) {
      final errors = data['errors'];

      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first;

        if (firstError is Map) {
          final detail = firstError['detail'];

          if (detail is String && detail.isNotEmpty) {
            return ApiException(detail, statusCode: code);
          }
        }
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException(
          'Connection timed out. Please try again.',
        );

      case DioExceptionType.sendTimeout:
        return const ApiException(
          'Sending request timed out. Please try again.',
        );

      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'Receiving response timed out. Please try again.',
        );

      case DioExceptionType.transformTimeout:
        return const ApiException(
          'Response processing timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.cancel:
        return const ApiException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const ApiException('Security certificate error.');

      case DioExceptionType.badResponse:
        return ApiException._fromStatusCode(code);

      case DioExceptionType.unknown:
        return ApiException._fromStatusCode(code);
    }
  }

  factory ApiException._fromStatusCode(int? code) {
    switch (code) {
      case 400:
        return ApiException(
          'Bad request. Please check your request.',
          statusCode: code,
        );

      case 406:
        return ApiException(
          'Not acceptable. Check the request headers.',
          statusCode: code,
        );

      case 401:
        return ApiException('Unauthorized. Please log in.', statusCode: code);

      case 403:
        return ApiException('Access denied.', statusCode: code);

      case 404:
        return ApiException(
          'The requested resource was not found.',
          statusCode: code,
        );

      case 429:
        return ApiException(
          'Too many requests. Please try again later.',
          statusCode: code,
        );

      case 500:
      case 502:
      case 503:
        return ApiException(
          'Server error. Please try again later.',
          statusCode: code,
        );

      default:
        return ApiException(
          'Something went wrong. Please try again.',
          statusCode: code,
        );
    }
  }

  @override
  String toString() => message;
}