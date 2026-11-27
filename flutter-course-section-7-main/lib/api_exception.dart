import 'package:dio/dio.dart';

/// Our own error type.
/// The UI never deals with DioException directly — it only gets a clear message.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  /// Converts any DioException into a user-friendly ApiException.
  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException("Connection timed out. Please try again.");
      case DioExceptionType.sendTimeout:
        return const ApiException("Sending the request took too long.");
      case DioExceptionType.receiveTimeout:
        return const ApiException("The server took too long to respond.");
      case DioExceptionType.transformTimeout:
        return const ApiException("Processing the response took too long.");
      case DioExceptionType.connectionError:
        return const ApiException("No internet connection.");
      case DioExceptionType.cancel:
        return const ApiException("Request was cancelled.");
      case DioExceptionType.badCertificate:
        return const ApiException("Secure connection failed (bad certificate).");
      case DioExceptionType.badResponse:
        return ApiException._fromStatusCode(e.response?.statusCode);
      case DioExceptionType.unknown:
        return const ApiException("Something went wrong. Please try again.");
    }
  }

  /// The server answered, but with an error status code.
  factory ApiException._fromStatusCode(int? code) {
    switch (code) {
      case 400:
        return ApiException("Bad request.", statusCode: code);
      case 401:
        return ApiException("Unauthorized. Please log in again.", statusCode: code);
      case 403:
        return ApiException("You don't have permission to do this.", statusCode: code);
      case 404:
        return ApiException("Requested data was not found.", statusCode: code);
      case 429:
        return ApiException("Too many requests. Slow down a little.", statusCode: code);
      case 500:
      case 502:
      case 503:
        return ApiException("Server error. Please try again later.", statusCode: code);
      default:
        return ApiException("Unexpected error ($code).", statusCode: code);
    }
  }

  @override
  String toString() => message;
}
