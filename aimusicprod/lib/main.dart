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
    List<String> emotions = const [],
    String? previousLyrics,
    int versionCount = 1,
    Map<String, dynamic>? musicalElements,
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
        'emotions': emotions,
        'previous_lyrics': previousLyrics,
        'version_count': versionCount,
        'musical_elements': musicalElements,
      });

      final streamedResponse = await http.Client().send(request);

      if (streamedResponse.statusCode == 200) {
        await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
          yield chunk;
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
  final List<TextEditingController> _lyricsControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isLoading = false;
  Stream<String>? _lyricsStream;
  StreamSubscription<String>? _lyricsSubscription;
  
  List<String> selectedEmotions = [];
  int selectedVersionCount = 1;
  Map<String, dynamic> musicalElements = {
    'melody_style': '',
    'harmony_type': '',
    'instruments': <String>[],
    'tempo': '',
  };

  final List<String> availableEmotions = [
    'Happy', 'Sad', 'Energetic', 'Calm', 'Romantic', 
    'Angry', 'Nostalgic', 'Hopeful', 'Mysterious', 'Funny'
  ];

  final List<String> availableInstruments = [
    'Piano', 'Guitar', 'Drums', 'Bass', 'Strings',
    'Synthesizer', 'Violin', 'Trumpet', 'Saxophone', 'Flute'
  ];

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.music_note,
      'title': 'Multi-Version Generation',
      'description': 'Create multiple versions of lyrics with different emotional tones',
    },
    {
      'icon': Icons.piano,
      'title': 'Musical Elements',
      'description': 'Specify melody, harmony, and instrumental arrangements',
    },
    {
      'icon': Icons.edit,
      'title': 'Iterative Refinement',
      'description': 'Refine and improve generated lyrics through multiple iterations',
    },
    {
      'icon': Icons.language,
      'title': 'Multi-Language Support',
      'description': 'Generate lyrics in any language of your choice',
    },
  ];

  @override
  void dispose() {
    _languageController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    for (var controller in _lyricsControllers) {
      controller.dispose();
    }
    _lyricsSubscription?.cancel();
    super.dispose();
  }

  Widget _buildEmotionSelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: availableEmotions.map((emotion) {
        final isSelected = selectedEmotions.contains(emotion);
        return FilterChip(
          label: Text(emotion),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (selectedEmotions.length < 3) {
                  selectedEmotions.add(emotion);
                }
              } else {
                selectedEmotions.remove(emotion);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildMusicalElements() {
    return Card(
      color: Colors.black38,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Melody Style',
                hintText: 'e.g., Upbeat, Melancholic, Flowing',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => musicalElements['melody_style'] = value,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Harmony Type',
                hintText: 'e.g., Simple, Complex, Jazz-inspired',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => musicalElements['harmony_type'] = value,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Instruments:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: availableInstruments.map((instrument) {
                final isSelected = (musicalElements['instruments'] as List<String>).contains(instrument);
                return FilterChip(
                  label: Text(instrument),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        (musicalElements['instruments'] as List<String>).add(instrument);
                      } else {
                        (musicalElements['instruments'] as List<String>).remove(instrument);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tempo',
                hintText: 'e.g., Fast, Moderate, Slow, 120 BPM',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => musicalElements['tempo'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateLyrics() async {
  if (_languageController.text.isEmpty ||
      _genreController.text.isEmpty ||
      _descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please fill in all required fields'),
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
    for (var controller in _lyricsControllers) {
      controller.clear();
    }
    
    _lyricsStream = LyricsService.generateLyrics(
      language: _languageController.text,
      genre: _genreController.text,
      description: _descriptionController.text,
      emotions: selectedEmotions,
      previousLyrics: _lyricsControllers[0].text.isNotEmpty ? _lyricsControllers[0].text : null,
      versionCount: selectedVersionCount,
      musicalElements: musicalElements,
    );
  });

  int currentVersion = 0;
  String buffer = '';

  _lyricsSubscription = _lyricsStream?.listen(
    (data) {
      if (mounted) {
        if (data.startsWith('Version')) {
          // Extract version number and update current version
          final versionMatch = RegExp(r'Version (\d+):').firstMatch(data);
          if (versionMatch != null) {
            currentVersion = int.parse(versionMatch.group(1)!) - 1;
            // Clear any existing content in this version's controller
            _lyricsControllers[currentVersion].clear();
          }
          buffer = '';  // Clear buffer for new version
        }
        
        // Add new data to buffer
        buffer += data;
        
        // Update the current version's controller
        setState(() {
          _lyricsControllers[currentVersion].text = buffer;
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
          _lyricsControllers[0].text = 'Error: $error';
        });
      }
    },
  );
}

  Widget _buildLyricsVersions() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Number of versions: '),
            DropdownButton<int>(
              value: selectedVersionCount,
              items: [1, 2, 3].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  selectedVersionCount = newValue!;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(selectedVersionCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              color: Colors.black38,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Version ${index + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _lyricsControllers[index],
                      maxLines: null,
                      minLines: 10,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInputTab({
    required TextEditingController controller,
    required String label,
    required String hint,
    Widget? extraContent,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AutoSlidingFeatureCarousel(features: _features),
          const SizedBox(height: 24),
          Card(
            color: Colors.black38,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      hintText: hint,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.black12,
                    ),
                  ),
                  if (extraContent != null) ...[
                    const SizedBox(height: 16),
                    extraContent,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.black38,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Emotional Tones (Select up to 3):',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildEmotionSelector(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Describe your song',
                      hintText: 'Enter theme, mood, or story of your song',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.black12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _generateLyrics,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
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
                        : const Text('Generate Lyrics'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLyricsVersions(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.black38,
              title: const Text(
                'AI Music Production',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Language'),
                  Tab(text: 'Genre'),
                  Tab(text: 'Musical Elements'),
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
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AutoSlidingFeatureCarousel(features: _features),
                      const SizedBox(height: 24),
                      _buildMusicalElements(),
                    ],
                  ),
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