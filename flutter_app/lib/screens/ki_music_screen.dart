import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class KiMusicScreen extends StatefulWidget {
  const KiMusicScreen({super.key});

  @override
  State<KiMusicScreen> createState() => _KiMusicScreenState();
}

class _KiMusicScreenState extends State<KiMusicScreen>
    with TickerProviderStateMixin {
  // Text Controllers
  final TextEditingController _songTitleController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();

  // Animation Controllers
  late AnimationController _waveAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  // State Variables (ersetze die bestehenden final Variablen)
  String _selectedGenre = 'Pop';
  String _selectedMood = 'Happy';
  double _tempo = 120.0;
  double _energy = 0.7;
  bool _isGenerating = false;
  bool _includeVocals = true;
  bool _useCustomLyrics = false;
  double _generationProgress = 0.0;
  String _generationStatus = '';

  // Genre & Mood Lists
  final List<String> _genres = [
    'Pop',
    'Rock',
    'Hip-Hop',
    'Electronic',
    'Jazz',
    'Classical',
    'R&B',
    'Country',
    'Metal',
    'Reggae',
    'Blues',
    'Folk'
  ];

  final List<String> _moods = [
    'Happy',
    'Sad',
    'Energetic',
    'Calm',
    'Romantic',
    'Aggressive',
    'Mysterious',
    'Uplifting',
    'Dark',
    'Dreamy',
    'Nostalgic'
  ];

  // Instrument Selection
  final Map<String, bool> _instruments = {
    'Piano': true,
    'Guitar': true,
    'Drums': true,
    'Bass': true,
    'Strings': false,
    'Synthesizer': false,
    'Saxophone': false,
    'Trumpet': false,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _songTitleController.dispose();
    _lyricsController.dispose();
    _promptController.dispose();
    _waveAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<void> _generateMusic() async {
    if (_songTitleController.text.isEmpty) {
      _showSnackBar('Bitte gib einen Songtitel ein');
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
      _generationStatus = 'KI wird initialisiert...';
    });

    // Simulierte Musikgenerierung mit Fortschritt
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _generationProgress = i / 100;
        _updateGenerationStatus(i);
      });
    }

    setState(() {
      _isGenerating = false;
    });

    _showSuccessDialog();
  }

  void _updateGenerationStatus(int progress) {
    if (progress < 20) {
      _generationStatus = 'Analysiere Musikparameter...';
    } else if (progress < 40) {
      _generationStatus = 'Erstelle Melodie...';
    } else if (progress < 60) {
      _generationStatus = 'Komponiere Harmonie...';
    } else if (progress < 80) {
      _generationStatus = 'Mixe Instrumente...';
    } else {
      _generationStatus = 'Finalisiere deinen Song...';
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00BFFF), width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text(
              'Song erstellt!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${_songTitleController.text}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Genre: $_selectedGenre | Stimmung: $_selectedMood',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dein Song wurde erfolgreich generiert!',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Song wurde zu deiner Bibliothek hinzugefügt');
            },
            child: const Text(
              'Später anhören',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to player
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Jetzt abspielen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFFF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2D2D2D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF00BFFF)),
            SizedBox(width: 8),
            Text(
              'KI-Musikstudio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: _isGenerating ? _buildGeneratingView() : _buildMainView(),
    );
  }

  Widget _buildMainView() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSongInfoCard(),
              const SizedBox(height: 20),
              _buildGenreMoodSection(),
              const SizedBox(height: 20),
              _buildParametersCard(),
              const SizedBox(height: 20),
              _buildInstrumentsCard(),
              const SizedBox(height: 20),
              _buildLyricsSection(),
              const SizedBox(height: 20),
              _buildAdvancedOptions(),
              const SizedBox(height: 30),
              _buildGenerateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00BFFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.music_note, color: Color(0xFF00BFFF)),
              SizedBox(width: 8),
              Text(
                'Song Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _songTitleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Songtitel *',
              labelStyle: TextStyle(color: Colors.grey[400]),
              hintText: 'z.B. "Sommernacht in Berlin"',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.title, color: Color(0xFF00BFFF)),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00BFFF)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _promptController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Beschreibe deinen Song (optional)',
              labelStyle: TextStyle(color: Colors.grey[400]),
              hintText: 'z.B. "Ein fröhlicher Sommerhit mit Strandvibes"',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon:
                  const Icon(Icons.description, color: Color(0xFF00BFFF)),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00BFFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParametersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00BFFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune, color: Color(0xFF00BFFF)),
              SizedBox(width: 8),
              Text(
                'Musik-Parameter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSlider(
            'Tempo',
            '${_tempo.round()} BPM',
            _tempo,
            60,
            180,
            Icons.speed,
            (value) => setState(() => _tempo = value),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Energie',
            '${(_energy * 100).round()}%',
            _energy,
            0,
            1,
            Icons.flash_on,
            (value) => setState(() => _energy = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    String value,
    double sliderValue,
    double min,
    double max,
    IconData icon,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFF1493), size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: const Color(0xFF00BFFF).withOpacity(0.5)),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: const Color(0xFF00BFFF),
            inactiveTrackColor: Colors.grey[800],
            thumbColor: const Color(0xFFFF1493),
            overlayColor: const Color(0xFFFF1493).withOpacity(0.3),
          ),
          child: Slider(
            value: sliderValue,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreMoodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00BFFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category, color: Color(0xFF00BFFF)),
              SizedBox(width: 8),
              Text(
                'Genre & Stimmung',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Genre Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedGenre,
                dropdownColor: const Color(0xFF2D2D2D),
                style: const TextStyle(color: Colors.white),
                icon:
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF00BFFF)),
                hint: Text(
                  'Wähle ein Genre',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                items: _genres.map((String genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Row(
                      children: [
                        Icon(
                          _getGenreIcon(genre),
                          color: const Color(0xFF00BFFF),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(genre),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedGenre = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Mood Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedMood,
                dropdownColor: const Color(0xFF2D2D2D),
                style: const TextStyle(color: Colors.white),
                icon:
                    const Icon(Icons.arrow_drop_down, color: Color(0xFFFF1493)),
                hint: Text(
                  'Wähle eine Stimmung',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                items: _moods.map((String mood) {
                  return DropdownMenuItem<String>(
                    value: mood,
                    child: Row(
                      children: [
                        Icon(
                          _getMoodIcon(mood),
                          color: const Color(0xFFFF1493),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(mood),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMood = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick Select Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSelectChip('Party Hit', 'Electronic', 'Energetic'),
              _buildQuickSelectChip('Chill Vibes', 'Jazz', 'Calm'),
              _buildQuickSelectChip('Love Song', 'R&B', 'Romantic'),
              _buildQuickSelectChip('Workout', 'Hip-Hop', 'Energetic'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectChip(String label, String genre, String mood) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        setState(() {
          _selectedGenre = genre;
          _selectedMood = mood;
        });
        HapticFeedback.lightImpact();
      },
      backgroundColor: const Color(0xFF1A1A1A),
      side: BorderSide(color: Colors.grey[700]!),
      labelStyle: TextStyle(color: Colors.grey[300]),
    );
  }

  IconData _getGenreIcon(String genre) {
    switch (genre) {
      case 'Pop':
        return Icons.star;
      case 'Rock':
        return Icons.music_note; // Geändert von guitar_acoustic
      case 'Hip-Hop':
        return Icons.mic;
      case 'Electronic':
        return Icons.equalizer;
      case 'Jazz':
        return Icons.music_note; // Geändert von saxophon
      case 'Classical':
        return Icons.piano;
      case 'R&B':
        return Icons.favorite;
      case 'Country':
        return Icons.landscape;
      case 'Metal':
        return Icons.bolt;
      case 'Reggae':
        return Icons.wb_sunny;
      case 'Blues':
        return Icons.nightlight;
      case 'Folk':
        return Icons.nature_people;
      default:
        return Icons.music_note;
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'Happy':
        return Icons.sentiment_very_satisfied;
      case 'Sad':
        return Icons.sentiment_dissatisfied;
      case 'Energetic':
        return Icons.flash_on;
      case 'Calm':
        return Icons.spa;
      case 'Romantic':
        return Icons.favorite;
      case 'Aggressive':
        return Icons.whatshot;
      case 'Mysterious':
        return Icons.help_outline;
      case 'Uplifting':
        return Icons.trending_up;
      case 'Dark':
        return Icons.dark_mode;
      case 'Dreamy':
        return Icons.cloud;
      case 'Nostalgic':
        return Icons.access_time;
      default:
        return Icons.mood;
    }
  }

  Widget _buildInstrumentsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00BFFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.piano, color: Color(0xFF00BFFF)),
              SizedBox(width: 8),
              Text(
                'Instrumente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _instruments.entries.map((entry) {
              return FilterChip(
                label: Text(entry.key),
                selected: entry.value,
                onSelected: (selected) {
                  setState(() {
                    _instruments[entry.key] = selected;
                  });
                  HapticFeedback.lightImpact();
                },
                selectedColor: const Color(0xFF00BFFF).withOpacity(0.3),
                backgroundColor: const Color(0xFF1A1A1A),
                checkmarkColor: const Color(0xFF00BFFF),
                labelStyle: TextStyle(
                  color: entry.value ? Colors.white : Colors.grey[400],
                ),
                side: BorderSide(
                  color:
                      entry.value ? const Color(0xFF00BFFF) : Colors.grey[700]!,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[400], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Die KI wählt die passenden Sounds basierend auf deiner Auswahl',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF1493).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.lyrics, color: Color(0xFFFF1493)),
                  SizedBox(width: 8),
                  Text(
                    'Gesang & Text',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _includeVocals,
                onChanged: (value) {
                  setState(() {
                    _includeVocals = value;
                    if (!value) _useCustomLyrics = false;
                  });
                },
                activeColor: const Color(0xFF00BFFF),
              ),
            ],
          ),
          if (_includeVocals) ...[
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text(
                'Eigene Lyrics verwenden',
                style: TextStyle(color: Colors.white),
              ),
              value: _useCustomLyrics,
              onChanged: (value) {
                setState(() {
                  _useCustomLyrics = value!;
                });
              },
              activeColor: const Color(0xFF00BFFF),
              contentPadding: EdgeInsets.zero,
            ),
            if (_useCustomLyrics) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _lyricsController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Schreibe deine Lyrics hier...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF1493)),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(Icons.settings, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text(
            'Erweiterte Optionen',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              CheckboxListTile(
                title: const Text(
                  'Automatisches Mastering',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Optimiert den Klang professionell',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF00BFFF),
              ),
              CheckboxListTile(
                title: const Text(
                  'Variationen erstellen',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Erstellt 3 verschiedene Versionen',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                value: false,
                onChanged: (value) {},
                activeColor: const Color(0xFF00BFFF),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BFFF), Color(0xFFFF1493)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BFFF).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _generateMusic,
                borderRadius: BorderRadius.circular(30),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Song generieren',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneratingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Wave
            AnimatedBuilder(
              animation: _waveAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(300, 100),
                  painter: WavePainter(
                    animationValue: _waveAnimationController.value,
                    color: const Color(0xFF00BFFF),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            // Progress Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _generationProgress,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(
                        const Color(0xFF00BFFF),
                        const Color(0xFFFF1493),
                        _generationProgress,
                      )!,
                    ),
                    strokeWidth: 8,
                  ),
                ),
                Text(
                  '${(_generationProgress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Status Text
            Text(
              _generationStatus,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Song Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00BFFF).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _songTitleController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getGenreIcon(_selectedGenre),
                        color: const Color(0xFF00BFFF),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedGenre,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        _getMoodIcon(_selectedMood),
                        color: const Color(0xFFFF1493),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedMood,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Cancel Button
            TextButton(
              onPressed: () {
                setState(() {
                  _isGenerating = false;
                });
              },
              child: const Text(
                'Abbrechen',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF00BFFF)),
            SizedBox(width: 12),
            Text(
              'KI-Musikstudio Hilfe',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(
                'Songtitel',
                'Gib deinem Song einen einprägsamen Namen.',
              ),
              _buildHelpItem(
                'Genre & Stimmung',
                'Wähle die musikalische Richtung und emotionale Atmosphäre.',
              ),
              _buildHelpItem(
                'Tempo',
                'BPM (Beats per Minute) - Langsam: 60-90, Mittel: 90-120, Schnell: 120-180.',
              ),
              _buildHelpItem(
                'Energie',
                'Bestimmt die Intensität und Dynamik des Songs.',
              ),
              _buildHelpItem(
                'Instrumente',
                'Wähle die Instrumente, die in deinem Song vorkommen sollen.',
              ),
              _buildHelpItem(
                'Lyrics',
                'Lass die KI Texte generieren oder verwende deine eigenen.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF1493).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: Color(0xFFFF1493),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tipp: Je detaillierter deine Beschreibung, desto besser das Ergebnis!',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Verstanden',
              style: TextStyle(color: Color(0xFF00BFFF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Wave Painter for animation
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    const waveHeight = 10.0;
    const waveCount = 3;

    path.moveTo(0, size.height / 2);

    for (int i = 0; i <= waveCount * 2; i++) {
      final x = (size.width / (waveCount * 2)) * i;
      final y = size.height / 2 +
          sin((i * pi / waveCount) + (animationValue * 2 * pi)) * waveHeight;

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final controlX = x - (size.width / (waveCount * 4));
        final controlY = size.height / 2 +
            sin(((i - 0.5) * pi / waveCount) + (animationValue * 2 * pi)) *
                waveHeight *
                1.5;

        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
