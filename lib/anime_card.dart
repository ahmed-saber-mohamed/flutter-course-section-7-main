import 'package:flutter/material.dart';
import 'package:myanime_1/anime.dart';
import 'package:myanime_1/auth_service.dart';

class AnimeCard extends StatefulWidget {
  final Anime anime;
  final ValueChanged<String>? onFavoriteRemoved;

  const AnimeCard({
    super.key,
    required this.anime,
    this.onFavoriteRemoved,
  });

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  bool isFavorite = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final favorites = await AuthService.getFavorites();

    if (!mounted) return;

    setState(() {
      isFavorite = favorites.contains(widget.anime.id);
      isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (isLoading) return;

    final wasFavorite = isFavorite;

    setState(() {
      isLoading = true;
    });

    try {
      if (wasFavorite) {
        await AuthService.removeFavorite(widget.anime.id);
      } else {
        await AuthService.addFavorite(widget.anime.id);
      }

      if (!mounted) return;

      setState(() {
        isFavorite = !wasFavorite;
        isLoading = false;
      });

      if (wasFavorite) {
        widget.onFavoriteRemoved?.call(widget.anime.id);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorites.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: height / 4,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              anime.image.isEmpty
                  ? SizedBox(
                      width: width / 4,
                      height: height / 4,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                      ),
                    )
                  : Image.network(
                      anime.image,
                      fit: BoxFit.fill,
                      width: width / 4,
                      height: height / 4,
                      webHtmlElementStrategy:
                          WebHtmlElementStrategy.prefer,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          width: width / 4,
                          height: height / 4,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                          ),
                        );
                      },
                    ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black54,
                  child: Text(
                    anime.rating,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            anime.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            anime.desc,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}