import 'dart:async';
import 'package:cinegeek/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../model/movie.dart';
import '../../services/firestore_service.dart';
import '../../services/tmdb_service.dart';
import '../theme.dart';
import '../widgets/movie_carousel.dart';
import '../widgets/top_bar.dart';

class AtCinemaPage extends StatefulWidget
{
  const AtCinemaPage({super.key});

  @override
  State<AtCinemaPage> createState() => _AtCinemaPageState();
}

class _AtCinemaPageState extends State<AtCinemaPage>
{
  late Future<List<Movie>> _movieFuture;
  List<Movie> _searchResults = [];
  bool _isSearching = false;
  bool _isBarExpanded = false;
  int? _selectedMovieId;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState()
  {
    super.initState();
    _movieFuture = TmdbService().getMovieNowPlayingNotWatched();
  }

  void _onSearchSyncMovieNotWatched(String query)
  {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () async
    {
      if (query.isEmpty)
      {
        setState(()
        {
          _isSearching = false;
          _searchResults = [];
        });
        return;
      }

      final resultsFuture = TmdbService().searchMovies(query);
      final user = await AuthService().getCurrentUser();
      List<Movie> results = await resultsFuture;

      final watched = await FirestoreService().getWatched(user!.uid);
      final watchedIds = watched.map((m) => m.id).toSet();

      results = results.where((movie) => !watchedIds.contains(movie.id)).toList();

      setState(()
      {
        _searchResults = results;
        _isSearching = true;
      });
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      body:
      Stack
      (
        children:
        [
          Column
          (
            children:
            [
              const TopBarLogo(),
              const SizedBox(height: 30),
              Expanded(child: _isSearching ? _buildGridResults() : _buildCarousel()),
              const SizedBox(height: 100),
            ],
          ),
          Align
          (
            alignment: Alignment.bottomCenter,
            child: Padding
            (
              padding: const EdgeInsets.only(bottom: 100),
              child: _buildBigSearchButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridResults()
  {
    if (_searchResults.isEmpty)
    {
      return const Center(child: Text("Nessun film trovato"));
    }

    return Padding
      (
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child:
      Column
      (
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          const Text("Risultati", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Expanded
          (
            child:
            GridView.builder
            (
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.66),
              itemCount: _searchResults.length,
              itemBuilder: (context, index)
              {
                final movie = _searchResults[index];
                final isSelected = _selectedMovieId == movie.id;

                return GestureDetector
                (
                  onTap: () => setState(() => _selectedMovieId = movie.id),
                  child:
                  Stack
                  (
                    children:
                    [
                      Column
                      (
                        children:
                        [
                          Expanded
                          (
                            child:
                            AnimatedContainer
                            (
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: isSelected ? AppTheme.primaryLime : Colors.transparent, width: 3),),
                              child:
                              ClipRRect
                              (
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(movie.fullPosterUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Text(movie.title, maxLines: 1, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                      if (isSelected)
                        Positioned
                        (
                          bottom: 10, right: 3,
                          child: GestureDetector
                          (
                            onTap: () => _saveToMovieWatched(movie),
                            child: Container
                            (
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
                              child: const Icon(Icons.check, color: Colors.black, size: 20),
                            ),
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel()
  {
    return FutureBuilder<List<Movie>>
    (
      future: _movieFuture,
      builder: (context, snapshot)
      {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        return MovieCarousel
        (
          title: "Film al Cinema",
          movies: snapshot.data!,
          heroTagPrefix: "at_cinema",
          selectedMovieId: _selectedMovieId,
          onCustomTap: (movie, tag) => setState(() => _selectedMovieId = movie.id),
          onCheckConfirmTap: ()
          {
            final selected = snapshot.data!.firstWhere((m) => m.id == _selectedMovieId);
            _saveToMovieWatched(selected);
          },
        );
      },
    );
  }

  Widget _buildBigSearchButton()
  {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF1A1A1A) : AppTheme.primaryLime;
    final Color contentColor = isDark ? AppTheme.primaryLime : const Color(0xFF1A1A1A);
    final Color borderColor = isDark ? AppTheme.primaryLime.withAlpha(128) : const Color(0xFF1A1A1A);

    return AnimatedContainer
      (
      duration: const Duration(milliseconds: 300),
      width: _isBarExpanded ? MediaQuery.of(context).size.width * 0.9 : 85,
      height: 85,
      decoration: BoxDecoration
        (
        color: bgColor,
        borderRadius: BorderRadius.circular(42.5),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row
        (
        children:
        [
          SizedBox
            (
            width: 81,
            child: IconButton
              (
              icon: Icon(_isBarExpanded ? Icons.close : Icons.search, color: contentColor, size: 35),
              onPressed: ()
              {
                setState(()
                {
                  _isBarExpanded = !_isBarExpanded;
                  if (!_isBarExpanded)
                  {
                    _searchController.clear();
                    _isSearching = false;
                    FocusScope.of(context).unfocus();
                  }
                });
              },
            ),
          ),
          if (_isBarExpanded)
            Expanded
              (
              child: TextField
                (
                controller: _searchController,
                onChanged: _onSearchSyncMovieNotWatched,
                autofocus: true,
                style: TextStyle(color: contentColor, fontSize: 18),
                decoration: InputDecoration
                  (
                  hintText: "Cerca...",
                  hintStyle: TextStyle(color: contentColor.withAlpha(150)),
                  border: InputBorder.none,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _saveToMovieWatched(Movie movie) async
  {
    final user = await AuthService().getCurrentUser();
    if (user == null) return;

    bool done = await FirestoreService().toggleMovieInList(uid: user.uid, collection: 'watched', movieId: movie.id, title: movie.title, imageUrl: movie.fullPosterUrl, description: movie.overview, voteAverage: movie.voteAverage,);

    if (mounted && done)
    {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false);
    }
  }
}