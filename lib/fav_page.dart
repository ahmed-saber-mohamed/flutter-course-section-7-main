import 'package:flutter/material.dart';
import 'package:myanime_1/anime.dart';
import 'package:myanime_1/anime_card.dart';
import 'package:myanime_1/anime_service.dart';
import 'package:myanime_1/auth_service.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  List<Anime> favorites = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final ids = await AuthService.getFavorites();
      final data = await AnimeService.getAnimeByIds(ids);

      if (!mounted) return;

      setState(() {
        favorites = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Failed to load favorites.';
        isLoading = false;
      });
    }
  }

  void _removeFavorite(String id) {
    setState(() {
      favorites.removeWhere((anime) => anime.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            onPressed: _loadFavorites,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMessage!),
                      ElevatedButton(
                        onPressed: _loadFavorites,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : favorites.isEmpty
                  ? const Center(
                      child: Text('No favorite anime yet.'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        return AnimeCard(
                          anime: favorites[index],
                          onFavoriteRemoved: _removeFavorite,
                        );
                      },
                    ),
    );
  }
}