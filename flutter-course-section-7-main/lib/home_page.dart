import 'package:flutter/material.dart';
import 'package:myanime_1/anime.dart';
import 'package:myanime_1/anime_card.dart';
import 'package:myanime_1/anime_service.dart';
import 'package:myanime_1/api_exception.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final List<Anime> animes = [];

  var offset = 0;
  var value = "No data loading ";

  Future<void> _getData() async {
    setState(() {
      value = "Loading ...";
    });

    try {
      final data = await AnimeService.getAllData(offset: offset);

      // The user may have left the page while we were waiting.
      if (!mounted) return;
      setState(() {
        animes.addAll(data);
        value = "Data Loaded ";
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        value = e.message;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels + 200 >
          _scrollController.position.maxScrollExtent) {
        offset += 10;
        _getData();
      }
    });
  }

  @override
  void dispose() {
    // Free the controller and its listeners when the page is removed.
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nothing loaded yet -> show the status message (loading / error).
    if (animes.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              if (value != "Loading ...")
                ElevatedButton(
                  onPressed: _getData,
                  child: const Text("Retry"),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return AnimeCard(anime: animes[index]);
                },
                itemCount: animes.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
