import 'package:flutter/material.dart';
import 'package:myanime_1/anime.dart';

class AnimeCard extends StatefulWidget {
  final Anime anime;

  const AnimeCard({super.key, required this.anime});

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: height / 4,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.onPrimary,
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                fit: BoxFit.fill,
                anime.image,
                width: width / 4,
                height: height / 4,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (context, object, trace) {
                  return Container(
                    width: width / 4,
                    height: height / 4,
                    decoration: BoxDecoration(color: Colors.red),
                  );
                },
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.all(3),
                  ),
                  onPressed: () {},
                  icon: Icon(Icons.favorite, color: Colors.red),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.red),
                    color: Colors.red,
                  ),
                  child: Text(
                    anime.rating,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          Text(anime.name),
          Text(anime.desc, maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
