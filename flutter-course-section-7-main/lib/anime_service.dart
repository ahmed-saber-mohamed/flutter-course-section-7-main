import 'package:dio/dio.dart';
import 'package:myanime_1/anime.dart';
import 'package:myanime_1/api_exception.dart';

class AnimeService {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: "https://kitsu.app/api/edge",

      // How long to wait while opening the connection to the server.
      connectTimeout: const Duration(seconds: 10),

      // How long to wait for the server to send the response back.
      receiveTimeout: const Duration(seconds: 15),

      // How long to wait while uploading the request body (useful for POST/PUT).
      sendTimeout: const Duration(seconds: 10),

      // Headers sent with every request. Kitsu uses the JSON:API format.
      headers: {
        "Accept": "application/vnd.api+json",
        "Content-Type": "application/vnd.api+json",
      },
    ),
  );

  static Future<List<Anime>> getAllData({int offset = 0}) async {
    try {
      final response = await _dio.get(
        "/anime",
        queryParameters: {"page[offset]": offset},
      );
      final data = response.data["data"] as List;
      final List<Anime> animes = [];
      for (var item in data) {
        animes.add(Anime.fromJson(item));
      }

      return animes;
    } on DioException catch (e) {
      // Network / HTTP errors -> a clear message for the user.
      throw ApiException.fromDioException(e);
    } catch (e) {
      // Anything else (e.g. the JSON did not have the shape we expected).
      throw const ApiException("Failed to read data from the server.");
    }
  }
}
