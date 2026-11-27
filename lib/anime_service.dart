import 'package:dio/dio.dart';
import 'package:myanime_1/anime.dart';
import 'package:myanime_1/api_exception.dart';
import 'package:myanime_1/api_client.dart';

class AnimeService {
  static final Dio _dio = ApiClient.dio;

  static bool hasNextPage = true;

  static const String _animeFields =
      'id,canonicalTitle,description,posterImage,averageRating,episodeCount';

  static List<Anime> _parseList(List data) {
    final list = <Anime>[];
    for (final item in data) {
      try {
        list.add(Anime.fromJson(item));
      } catch (_) {}
    }
    return list;
  }

  static Future<List<Anime>> getAllData({
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/anime',
        queryParameters: {
          'page[limit]': 20,
          'page[offset]': offset,
          'fields[anime]': _animeFields,
        },
      );

      final responseData = response.data;
      final data = responseData['data'] as List;
      final links = responseData['links'] as Map?;
      final nextLink = links?['next'];

      hasNextPage = data.length == 20 &&
          nextLink != null &&
          nextLink.toString().isNotEmpty;

      return _parseList(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw const ApiException('Failed to read data from the server.');
    }
  }

  static Future<List<Anime>> getUpcomingAnime({
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/anime',
        queryParameters: {
          'filter[status]': 'upcoming',
          'page[limit]': 20,
          'page[offset]': offset,
          'fields[anime]': _animeFields,
        },
      );

      final responseData = response.data;
      final data = responseData['data'] as List;
      final links = responseData['links'] as Map?;
      final nextLink = links?['next'];

      hasNextPage = data.length == 20 &&
          nextLink != null &&
          nextLink.toString().isNotEmpty;

      return _parseList(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw const ApiException('Failed to read upcoming anime.');
    }
  }

  static Future<List<Anime>> searchAnime(
    String query, {
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/anime',
        queryParameters: {
          'filter[text]': query,
          'page[limit]': 20,
          'page[offset]': offset,
          'fields[anime]': _animeFields,
        },
      );

      final responseData = response.data;
      final data = responseData['data'] as List;
      final links = responseData['links'] as Map?;
      final nextLink = links?['next'];

      hasNextPage = data.length == 20 &&
          nextLink != null &&
          nextLink.toString().isNotEmpty;

      return _parseList(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw const ApiException('Failed to search anime.');
    }
  }

  static Future<List<Anime>> getAnimeByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final response = await _dio.get(
        '/anime',
        queryParameters: {
          'filter[id]': ids.join(','),
          'page[limit]': ids.length > 20 ? 20 : ids.length,
          'fields[anime]': _animeFields,
        },
      );

      final data = response.data['data'] as List;
      return _parseList(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw const ApiException('Failed to load favorite anime.');
    }
  }
}