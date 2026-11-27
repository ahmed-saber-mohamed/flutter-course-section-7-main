import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myanime_1/anime.dart';
import 'package:myanime_1/anime_card.dart';
import 'package:myanime_1/anime_service.dart';
import 'package:myanime_1/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  List<Anime> animeList = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;

  String searchQuery = '';
  bool showUpcoming = false;

  @override
  void initState() {
    super.initState();
    debugPrint("Home: initState");
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      _loadNextPage();
    }
  }

  Future<List<Anime>> _fetchData({int offset = 0}) {
    if (searchQuery.isNotEmpty) {
      return AnimeService.searchAnime(searchQuery, offset: offset);
    }
    if (showUpcoming) {
      return AnimeService.getUpcomingAnime(offset: offset);
    }
    return AnimeService.getAllData(offset: offset);
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _fetchData(offset: 0);
      if (!mounted) return;

      setState(() {
        animeList = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (isLoading || isLoadingMore || !AnimeService.hasNextPage) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final data = await _fetchData(offset: animeList.length);
      if (!mounted) return;

      setState(() {
        animeList.addAll(data);
        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMore = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
    }
  }

  void _onSearch(String value) {
    setState(() {
      searchQuery = value.trim();
    });
    _loadFirstPage();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
    });
    _loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyAnime'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                showUpcoming = !showUpcoming;
                searchQuery = '';
                _searchController.clear();
              });
              _loadFirstPage();
            },
            child: Text(
              showUpcoming ? 'All' : 'Upcoming',
              style: TextStyle(
                fontWeight: showUpcoming ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Push Favourites (Test 2)',
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => context.push('/fav'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'MyAnime',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favourites'),
              onTap: () {
                Navigator.pop(context);
                context.go('/fav');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () async {
                await AuthService.logout();
                if (!context.mounted) return;
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadFirstPage,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (animeList.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isNotEmpty
              ? 'No results for "$searchQuery"'
              : 'No anime found',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return AnimeCard(anime: animeList[index]);
                },
                childCount: animeList.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
              ),
            ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}