import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math' as math;

import '../utils/constants.dart';

class MukkeFashionScreen extends StatefulWidget {
  const MukkeFashionScreen({super.key});

  @override
  _MukkeFashionScreenState createState() => _MukkeFashionScreenState();
}

class _MukkeFashionScreenState extends State<MukkeFashionScreen>
    with TickerProviderStateMixin {
  // Camera & Mirror Mode
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isMirrorMode = false;
  bool _isMeasuring = false;
  
  // Speech & TTS
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  
  // Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  // User Measurements
  Map<String, dynamic> _userMeasurements = {
    'height': 0,
    'shoeSize': 0,
    'clothingSize': '',
    'gender': '',
  };
  
  // Animation Controllers
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  
  // Fashion State
  String _selectedCategory = 'all';
  String _selectedOccasion = '';
  List<Map<String, dynamic>> _currentOutfits = [];
  int _currentOutfitIndex = 0;
  final List<Map<String, dynamic>> _shoppingCart = [];
  
  // Categories
  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'Alle', 'icon': Icons.all_inclusive, 'color': AppColors.primary},
    {'id': 'casual', 'name': 'Casual', 'icon': Icons.weekend, 'color': Colors.green},
    {'id': 'business', 'name': 'Business', 'icon': Icons.business_center, 'color': Colors.blue},
    {'id': 'party', 'name': 'Party', 'icon': Icons.nightlife, 'color': AppColors.accent},
    {'id': 'sport', 'name': 'Sport', 'icon': Icons.sports, 'color': Colors.orange},
    {'id': 'accessories', 'name': 'Accessoires', 'icon': Icons.watch, 'color': Colors.purple},
  ];
  
  // Sample Outfits (später durch echte Daten ersetzen)
  final List<Map<String, dynamic>> _allOutfits = [
    {
      'id': '1',
      'name': 'Street Style Deluxe',
      'category': 'casual',
      'price': 89.99,
      'items': ['Hoodie', 'Jeans', 'Sneakers'],
      'colors': ['Schwarz', 'Blau', 'Weiß', 'Grau'],
      'sizes': ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      'description': 'Lässiger Streetwear-Look für jeden Tag',
      'brand': 'MukkeWear',
      'image': 'assets/outfits/street_style.jpg',
    },
    {
      'id': '2',
      'name': 'Business Elite',
      'category': 'business',
      'price': 299.99,
      'items': ['Anzug', 'Hemd', 'Krawatte', 'Schuhe'],
      'colors': ['Navy', 'Grau', 'Schwarz'],
      'sizes': ['S', 'M', 'L', 'XL'],
      'description': 'Professioneller Look für wichtige Meetings',
      'brand': 'MukkeWear Premium',
      'image': 'assets/outfits/business.jpg',
    },
    {
      'id': '3',
      'name': 'Party Vibes',
      'category': 'party',
      'price': 129.99,
      'items': ['Shirt', 'Designer Jeans', 'Boots'],
      'colors': ['Schwarz', 'Gold', 'Silber'],
      'sizes': ['S', 'M', 'L', 'XL'],
      'description': 'Auffälliger Look für die Nacht',
      'brand': 'MukkeWear Night',
      'image': 'assets/outfits/party.jpg',
    },
    {
      'id': '4',
      'name': 'Fitness Pro',
      'category': 'sport',
      'price': 79.99,
      'items': ['Sport-Shirt', 'Shorts', 'Sneakers'],
      'colors': ['Neon', 'Schwarz', 'Weiß'],
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'description': 'Funktionale Sportkleidung für dein Workout',
      'brand': 'MukkeWear Active',
      'image': 'assets/outfits/sport.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserMeasurements();
    _setupTTS();
    _checkPermissions();
    _filterOutfits();
  }

  void _initializeAnimations() {
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  Future<void> _setupTTS() async {
    await _flutterTts.setLanguage('de-DE');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    
    if (cameraStatus.isGranted && micStatus.isGranted) {
      await _initializeCamera();
      await _speech.initialize();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );
        
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _loadUserMeasurements() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userMeasurements = {
            'height': data['height'] ?? 0,
            'shoeSize': data['shoeSize'] ?? 0,
            'clothingSize': data['clothingSize'] ?? '',
            'gender': data['gender'] ?? '',
          };
        });
      }
    } catch (e) {
      print('Load measurements error: $e');
    }
  }

  void _filterOutfits() {
    setState(() {
      if (_selectedCategory == 'all') {
        _currentOutfits = _allOutfits;
      } else {
        _currentOutfits = _allOutfits
            .where((outfit) => outfit['category'] == _selectedCategory)
            .toList();
      }
      _currentOutfitIndex = 0;
    });
  }

  void _toggleMirrorMode() async {
    if (!_isCameraInitialized) {
      await _checkPermissions();
      return;
    }
    
    setState(() {
      _isMirrorMode = !_isMirrorMode;
    });
    
    if (_isMirrorMode) {
      _speak('Spiegel-Modus aktiviert. Ich vermesse dich jetzt!');
      HapticFeedback.mediumImpact();
      
      // Starte Größenmessung nach 2 Sekunden
      Future.delayed(const Duration(seconds: 2), () {
        _startMeasurement();
      });
    } else {
      _speak('Spiegel-Modus deaktiviert.');
    }
  }

  void _startMeasurement() {
    setState(() => _isMeasuring = true);
    
    _speak('Bitte gehe ein paar Schritte zurück, damit ich deine Größe messen kann.');
    
    // Simuliere Messung (später durch echte KI-Messung ersetzen)
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _isMeasuring = false);
      
      // Zeige Größenbestätigung
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text(
            'Größenmessung',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.straighten,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Gemessene Größe: ${_userMeasurements["height"]} cm',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ist das korrekt?',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showManualSizeInput();
              },
              child: const Text('Anpassen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showOutfitSuggestions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Bestätigen'),
            ),
          ],
        ),
      );
    });
  }

  void _showManualSizeInput() {
    final heightController = TextEditingController(
      text: _userMeasurements['height'].toString(),
    );
    final shoeSizeController = TextEditingController(
      text: _userMeasurements['shoeSize'].toString(),
    );
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Größen anpassen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Körpergröße
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Körpergröße (cm)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.height, color: AppColors.primary),
                  suffixText: 'cm',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Schuhgröße
              TextField(
                controller: shoeSizeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Schuhgröße',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.do_not_step, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Kleidergröße
              DropdownButtonFormField<String>(
                value: _userMeasurements['clothingSize'].isEmpty
                    ? null
                    : _userMeasurements['clothingSize'],
                decoration: InputDecoration(
                  labelText: 'Kleidergröße',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.checkroom, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: AppColors.surfaceDark,
                style: const TextStyle(color: Colors.white),
                items: ['XS', 'S', 'M', 'L', 'XL', 'XXL']
                    .map((size) => DropdownMenuItem(
                          value: size,
                          child: Text(size),
                        ))
                    .toList(),
                onChanged: (value) {
                  _userMeasurements['clothingSize'] = value!;
                },
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Speichere Größen
                    setState(() {
                      _userMeasurements['height'] = int.tryParse(heightController.text) ?? 0;
                      _userMeasurements['shoeSize'] = int.tryParse(shoeSizeController.text) ?? 0;
                    });
                    
                    // In Firebase speichern
                    await _saveMeasurements();
                    
                    Navigator.pop(context);
                    _showOutfitSuggestions();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Speichern',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMeasurements() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      await _firestore.collection('users').doc(user.uid).update({
        'height': _userMeasurements['height'],
        'shoeSize': _userMeasurements['shoeSize'],
        'clothingSize': _userMeasurements['clothingSize'],
      });
    } catch (e) {
      print('Save measurements error: $e');
    }
  }

  void _showOutfitSuggestions() {
    _speak('Perfekt! Lass mich dir passende Outfits zeigen.');
    
    // Zeige Anlass-Auswahl
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Für welchen Anlass?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildOccasionCard('Date', Icons.favorite, AppColors.accent),
                    _buildOccasionCard('Business', Icons.business, Colors.blue),
                    _buildOccasionCard('Party', Icons.nightlife, Colors.purple),
                    _buildOccasionCard('Sport', Icons.fitness_center, Colors.orange),
                    _buildOccasionCard('Alltag', Icons.home, Colors.green),
                    _buildOccasionCard('Event', Icons.stars, Colors.amber),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccasionCard(String occasion, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOccasion = occasion;
        });
        Navigator.pop(context);
        
        // Zeige passende Outfits im Spiegel
        _speak('Super Wahl! Hier sind meine Vorschläge für $occasion.');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              occasion,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextOutfit() {
    if (_currentOutfits.isNotEmpty) {
      setState(() {
        _currentOutfitIndex = (_currentOutfitIndex + 1) % _currentOutfits.length;
      });
      HapticFeedback.lightImpact();
      
      final outfit = _currentOutfits[_currentOutfitIndex];
      _speak('Wie wäre es mit ${outfit["name"]}?');
    }
  }

  void _previousOutfit() {
    if (_currentOutfits.isNotEmpty) {
      setState(() {
        _currentOutfitIndex = (_currentOutfitIndex - 1 + _currentOutfits.length) % _currentOutfits.length;
      });
      HapticFeedback.lightImpact();
      
      final outfit = _currentOutfits[_currentOutfitIndex];
      _speak('Oder vielleicht ${outfit["name"]}?');
    }
  }

  void _addToCart(Map<String, dynamic> outfit) {
    setState(() {
      _shoppingCart.add(outfit);
    });
    
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${outfit["name"]} wurde zum Warenkorb hinzugefügt'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Zum Warenkorb',
          textColor: Colors.white,
          onPressed: _showShoppingCart,
        ),
      ),
    );
    
    _speak('Super Wahl! ${outfit["name"]} ist jetzt in deinem Warenkorb.');
  }

  void _showShoppingCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingCartScreen(
          items: _shoppingCart,
          onRemove: (index) {
            setState(() {
              _shoppingCart.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _startVoiceCommand() async {
    if (!_isListening && await _speech.hasPermission) {
      setState(() => _isListening = true);
      
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _processVoiceCommand(result.recognizedWords);
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 10),
        localeId: 'de_DE',
      );
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  void _processVoiceCommand(String command) {
    command = command.toLowerCase();
    
    if (command.contains('weiter') || command.contains('nächste')) {
      _nextOutfit();
    } else if (command.contains('zurück') || command.contains('vorherige')) {
      _previousOutfit();
    } else if (command.contains('kaufen') || command.contains('warenkorb')) {
      if (_currentOutfits.isNotEmpty) {
        _addToCart(_currentOutfits[_currentOutfitIndex]);
      }
    } else if (command.contains('farbe')) {
      _speak('Du kannst die Farbe durch Wischen nach oben oder unten ändern.');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mukke Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showShoppingCart,
              ),
              if (_shoppingCart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _shoppingCart.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          if (!_isMirrorMode) _buildMainView() else _buildMirrorView(),
          
          // Voice Command Indicator
          if (_isListening)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Höre zu...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['id'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['id'];
                  });
                  _filterOutfits();
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category['color'].withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? category['color']
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'],
                        color: isSelected
                            ? category['color']
                            : Colors.white70,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['name'],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Mirror Mode Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: _toggleMirrorMode,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spiegel-Modus aktivieren',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Virtuelle Anprobe mit KI-Größenerkennung',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Outfit Grid
        Expanded(
          child: _currentOutfits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checkroom,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Keine Outfits in dieser Kategorie',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _currentOutfits.length,
                  itemBuilder: (context, index) {
                    final outfit = _currentOutfits[index];
                    return _buildOutfitCard(outfit);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOutfitCard(Map<String, dynamic> outfit) {
    return GestureDetector(
      onTap: () {
        _showOutfitDetail(outfit);
      },
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, math.sin(_floatController.value * math.pi) * 2),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Placeholder
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.accent.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.checkroom,
                          size: 48,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outfit['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${outfit['price']}€',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          outfit['brand'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOutfitDetail(Map<String, dynamic> outfit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: OutfitDetailSheet(
          outfit: outfit,
          onAddToCart: () {
            Navigator.pop(context);
            _addToCart(outfit);
          },
          onTryOn: () {
            Navigator.pop(context);
            setState(() {
              _currentOutfitIndex = _currentOutfits.indexOf(outfit);
            });
            _toggleMirrorMode();
          },
        ),
      ),
    );
  }

  Widget _buildMirrorView() {
    return Stack(
      children: [
        // Camera Preview
        if (_cameraController != null && _isCameraInitialized)
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
        
        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        
        // Measurement Overlay
        if (_isMeasuring)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return CustomPaint(
                  painter: MeasurementPainter(
                    animation: _scanController.value,
                  ),
                );
              },
            ),
          ),
        
        // Top Controls
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: _toggleMirrorMode,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Virtuelle Anprobe',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Current Outfit Display
        if (!_isMeasuring && _currentOutfits.isNotEmpty)
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentOutfits[_currentOutfitIndex]['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${_currentOutfits[_currentOutfitIndex]['price']}€',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _userMeasurements['clothingSize'] ?? 'M',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        
        // Swipe Instructions
        if (!_isMeasuring && _currentOutfits.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe,
                  color: Colors.white.withOpacity(0.7),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Swipe für weitere Outfits',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        
        // Bottom Actions
        if (!_isMeasuring)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Previous
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _previousOutfit,
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Add to Cart
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_currentOutfits.isNotEmpty) {
                        _addToCart(_currentOutfits[_currentOutfitIndex]);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'In den Warenkorb',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Next
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _nextOutfit,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Voice Command Button
        Positioned(
          bottom: 120,
          right: 20,
          child: FloatingActionButton(
            onPressed: _startVoiceCommand,
            backgroundColor: _isListening ? Colors.red : AppColors.primary,
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// Outfit Detail Sheet
class OutfitDetailSheet extends StatefulWidget {
  final Map<String, dynamic> outfit;
  final VoidCallback onAddToCart;
  final VoidCallback onTryOn;
  
  const OutfitDetailSheet({
    super.key,
    required this.outfit,
    required this.onAddToCart,
    required this.onTryOn,
  });

  @override
  _OutfitDetailSheetState createState() => _OutfitDetailSheetState();
}

class _OutfitDetailSheetState extends State<OutfitDetailSheet> {
  String _selectedColor = '';
  String _selectedSize = '';
  
  @override
  void initState() {
    super.initState();
    _selectedColor = widget.outfit['colors'][0];
    _selectedSize = widget.outfit['sizes'][2]; // Default M
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.accent.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                Icons.checkroom,
                size: 80,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Name & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.outfit['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${widget.outfit['price']}€',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.outfit['brand'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            widget.outfit['description'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          // Color Selection
          const Text(
            'Farbe wählen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.outfit['colors'].length,
              itemBuilder: (context, index) {
                final color = widget.outfit['colors'][index];
                final isSelected = _selectedColor == color;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      color,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Size Selection
          const Text(
            'Größe wählen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.outfit['sizes'].length,
              itemBuilder: (context, index) {
                final size = widget.outfit['sizes'][index];
                final isSelected = _selectedSize == size;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = size;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        size,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onTryOn,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Anprobieren'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onAddToCart,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Kaufen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Shopping Cart Screen
class ShoppingCartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(int) onRemove;
  
  const ShoppingCartScreen({
    super.key,
    required this.items,
    required this.onRemove,
  });

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item['price']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Warenkorb'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dein Warenkorb ist leer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.3),
                                    AppColors.accent.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.checkroom,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['brand'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${item['price']}€',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => onRemove(index),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Checkout
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gesamt:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${totalPrice.toStringAsFixed(2)}€',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement checkout
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Zur Kasse',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
}

// Measurement Painter
class MeasurementPainter extends CustomPainter {
  final double animation;
  
  MeasurementPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Scan Line
    final y = size.height * animation;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
    
    // Corner Markers
    paint.strokeWidth = 4;
    const cornerSize = 50.0;
    
    // Top Left
    canvas.drawLine(
      const Offset(20, 20),
      const Offset(20 + cornerSize, 20),
      paint,
    );
    canvas.drawLine(
      const Offset(20, 20),
      const Offset(20, 20 + cornerSize),
      paint,
    );
    
    // Top Right
    canvas.drawLine(
      Offset(size.width - 20 - cornerSize, 20),
      Offset(size.width - 20, 20),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 20, 20),
      Offset(size.width - 20, 20 + cornerSize),
      paint,
    );
    
    // Bottom Left
    canvas.drawLine(
      Offset(20, size.height - 20 - cornerSize),
      Offset(20, size.height - 20),
      paint,
    );
    canvas.drawLine(
      Offset(20, size.height - 20),
      Offset(20 + cornerSize, size.height - 20),
      paint,
    );
    
    // Bottom Right
    canvas.drawLine(
      Offset(size.width - 20 - cornerSize, size.height - 20),
      Offset(size.width - 20, size.height - 20),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 20, size.height - 20 - cornerSize),
      Offset(size.width - 20, size.height - 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
                