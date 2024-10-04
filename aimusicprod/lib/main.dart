import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MusicProductionApp());
}

// Lyrics Service
class LyricsService {
  static const String baseUrl = 'http://localhost:8000';

  static Stream<String> generateLyrics({
    required String language,
    required String genre,
    required String description,
  }) async* {
    try {
      final request = http.Request(
        'POST',
        Uri.parse('$baseUrl/api/generate_lyrics'),
      );

      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode({
        'language': language,
        'genre': genre,
        'description': description,
      });

      final streamedResponse = await http.Client().send(request);

      if (streamedResponse.statusCode == 200) {
        var buffer = '';
        await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
          buffer += chunk;
          yield buffer;
        }
      } else {
        final errorBody = await streamedResponse.stream.transform(utf8.decoder).join();
        throw Exception('Failed to generate lyrics: $errorBody');
      }
    } catch (e) {
      yield 'Error generating lyrics: $e';
    }
  }
}

// Feature Card Widget
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black45,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Auto-Sliding Feature Carousel
class AutoSlidingFeatureCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> features;
  
  const AutoSlidingFeatureCarousel({
    super.key,
    required this.features,
  });

  @override
  State<AutoSlidingFeatureCarousel> createState() => _AutoSlidingFeatureCarouselState();
}

class _AutoSlidingFeatureCarouselState extends State<AutoSlidingFeatureCarousel> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < widget.features.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.features.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FeatureCard(
                  icon: widget.features[index]['icon'],
                  title: widget.features[index]['title'],
                  description: widget.features[index]['description'],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.features.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Colors.blue
                    : Colors.blue.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Animated Background
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  Colors.blue.shade900,
                  Colors.blue.shade300,
                  _controller.value,
                )!,
                Color.lerp(
                  Colors.blue.shade300,
                  Colors.blue.shade900,
                  _controller.value,
                )!,
              ],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Main App Widget
class MusicProductionApp extends StatelessWidget {
  const MusicProductionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Music Production',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const MusicProductionHome(),
    );
  }
}

// Home Screen
class MusicProductionHome extends StatefulWidget {
  const MusicProductionHome({super.key});

  @override
  State<MusicProductionHome> createState() => _MusicProductionHomeState();
}

class _MusicProductionHomeState extends State<MusicProductionHome> {
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  bool _isLoading = false;
  Stream<String>? _lyricsStream;
  StreamSubscription<String>? _lyricsSubscription;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.music_note,
      'title': 'AI-Powered Lyrics Generation',
      'description': 'Create unique lyrics in any language and genre using advanced AI technology',
    },
    {
      'icon': Icons.language,
      'title': 'Multi-Language Support',
      'description': 'Generate lyrics in multiple languages to reach a global audience',
    },
    {
      'icon': Icons.category,
      'title': 'Genre Versatility',
      'description': 'Create lyrics across various musical genres, from pop to classical',
    },
    {
      'icon': Icons.autorenew,
      'title': 'Real-Time Generation',
      'description': 'Watch your lyrics come to life with real-time streaming generation',
    },
  ];

  @override
  void dispose() {
    _languageController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _lyricsController.dispose();
    _lyricsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _generateLyrics() async {
    if (_languageController.text.isEmpty ||
        _genreController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields before generating lyrics'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    await _lyricsSubscription?.cancel();

    setState(() {
      _isLoading = true;
      _lyricsController.clear();
      _lyricsStream = LyricsService.generateLyrics(
        language: _languageController.text,
        genre: _genreController.text,
        description: _descriptionController.text,
      );
    });

    _lyricsSubscription = _lyricsStream?.listen(
      (data) {
        if (mounted) {
          setState(() {
            _lyricsController.text = data;
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _lyricsController.text = 'Error: $error';
          });
        }
      },
    );
  }

  Widget _buildInputTab({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          AutoSlidingFeatureCarousel(features: _features),
          const SizedBox(height: 32),
          _buildCenteredCard(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Colors.black12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildCenteredCard(
            child: Column(
              children: [
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Describe your song',
                    hintText: 'Enter theme, mood, or story of your song',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    fillColor: Colors.black12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _generateLyrics,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Generating...'),
                          ],
                        )
                      : const Text('Create/Update Lyrics'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lyricsController,
                  maxLines: null,
                  minLines: 10,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Generated Lyrics',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    fillColor: Colors.black12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            color: Colors.black38,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.black38,
              elevation: 0,
              title: const Text(
                'AI Music Production',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Language'),
                  Tab(text: 'Genre'),
                  Tab(text: 'Lyrics'),
                ],
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
              ),
            ),
            body: TabBarView(
              children: [
                _buildInputTab(
                  controller: _languageController,
                  label: 'Enter Language',
                  hint: 'e.g., English, Spanish, French',
                ),
                _buildInputTab(
                  controller: _genreController,
                  label: 'Enter Genre',
                  hint: 'e.g., Pop, Rock, Jazz',
                ),
                _buildLyricsTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}