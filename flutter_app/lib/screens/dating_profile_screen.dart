import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../utils/constants.dart';

class DatingProfileScreen extends StatefulWidget {
  const DatingProfileScreen({super.key});

  @override
  State<DatingProfileScreen> createState() => _DatingProfileScreenState();
}

class _DatingProfileScreenState extends State<DatingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();

  // PageController für Step-by-Step Form
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _aboutMeController = TextEditingController();
  final _lookingForController = TextEditingController();
  final _importantController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _jobController = TextEditingController();
  final _educationController = TextEditingController();

  // State Variables
  bool _isLoading = false;
  bool _isSaving = false;

  // Dating Profil Daten
  String? _relationshipGoal;
  String? _hasKids;
  String? _wantsKids;
  String? _smoking;
  String? _drinking;
  String? _religion;
  String? _politics;
  String? _pets;
  String? _exercise;
  String? _diet;

  // Weitere Bilder (max 5)
  final List<File?> _additionalImages = List.filled(5, null);
  List<String> _uploadedImageUrls = [];

  // Matching-Fragen Antworten
  Map<String, int> _matchingAnswers = {};

  // Die 10 Matching-Fragen
  final List<Map<String, dynamic>> _matchingQuestions = [
    {
      'id': 'q1',
      'question': 'Was ist dir in einer Beziehung am wichtigsten?',
      'options': [
        'Tiefe emotionale Verbindung',
        'Gemeinsame Abenteuer erleben',
        'Ehrlichkeit und Vertrauen',
        'Humor und Spaß haben',
        'Gemeinsame Zukunftspläne'
      ]
    },
    {
      'id': 'q2',
      'question': 'Wie verbringst du am liebsten deine Freizeit?',
      'options': [
        'Aktiv in der Natur',
        'Gemütlich zu Hause',
        'Mit Freunden ausgehen',
        'Neue Orte entdecken',
        'Kreativ sein'
      ]
    },
    {
      'id': 'q3',
      'question': 'Was beschreibt deine Persönlichkeit am besten?',
      'options': [
        'Extrovertiert und gesellig',
        'Introvertiert und nachdenklich',
        'Ausgeglichen',
        'Spontan und abenteuerlustig',
        'Strukturiert und zielstrebig'
      ]
    },
    {
      'id': 'q4',
      'question': 'Wie wichtig ist dir körperliche Nähe?',
      'options': [
        'Sehr wichtig',
        'Wichtig',
        'Mittel',
        'Nicht so wichtig',
        'Kommt auf die Situation an'
      ]
    },
    {
      'id': 'q5',
      'question': 'Wie gehst du mit Konflikten um?',
      'options': [
        'Direkt ansprechen',
        'Erstmal nachdenken',
        'Kompromisse suchen',
        'Aus dem Weg gehen',
        'Mit Humor lösen'
      ]
    },
    {
      'id': 'q6',
      'question': 'Was ist deine Vorstellung vom perfekten Date?',
      'options': [
        'Romantisches Dinner',
        'Aktiv in der Natur',
        'Kulturelle Veranstaltung',
        'Entspannter Kaffee',
        'Spontanes Abenteuer'
      ]
    },
    {
      'id': 'q7',
      'question': 'Wie wichtig ist dir Familie?',
      'options': [
        'Das Wichtigste überhaupt',
        'Sehr wichtig',
        'Wichtig',
        'Nicht so wichtig',
        'Kommt auf die Familie an'
      ]
    },
    {
      'id': 'q8',
      'question': 'Was ist deine Einstellung zu Treue?',
      'options': [
        'Absolute Priorität',
        'Sehr wichtig',
        'Selbstverständlich',
        'Definitionssache',
        'Vertrauen ist wichtiger'
      ]
    },
    {
      'id': 'q9',
      'question': 'Wie siehst du deine Zukunft in 5 Jahren?',
      'options': [
        'Verheiratet mit Kindern',
        'In fester Partnerschaft',
        'Karriere im Fokus',
        'Reisen und Erleben',
        'Flexibel bleiben'
      ]
    },
    {
      'id': 'q10',
      'question':
          'Möchtest du viel an der Seite deines Partners/Partnerin sein?',
      'options': [
        'Ja, ich mag es wenn alles stimmt',
        'Nein, ich mach gerne mein eigenes ding',
        'Ich Liebe es, wenn wir alles zusammen machen',
        'Jeder macht seinen Part',
        'Absprechen und alternativen planen'
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadDatingProfile();
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    _lookingForController.dispose();
    _importantController.dispose();
    _hobbiesController.dispose();
    _jobController.dispose();
    _educationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDatingProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dating')
          .doc('profile')
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        // Textfelder
        _aboutMeController.text = data['aboutMe'] ?? '';
        _lookingForController.text = data['lookingFor'] ?? '';
        _importantController.text = data['important'] ?? '';
        _hobbiesController.text = data['hobbies'] ?? '';
        _jobController.text = data['job'] ?? '';
        _educationController.text = data['education'] ?? '';

        // Auswahlfelder
        _relationshipGoal = data['relationshipGoal'];
        _hasKids = data['hasKids'];
        _wantsKids = data['wantsKids'];
        _smoking = data['smoking'];
        _drinking = data['drinking'];
        _religion = data['religion'];
        _politics = data['politics'];
        _pets = data['pets'];
        _exercise = data['exercise'];
        _diet = data['diet'];

        // Bilder
        if (data['additionalImages'] != null) {
          _uploadedImageUrls = List<String>.from(data['additionalImages']);
        }

        // Matching-Antworten
        if (data['matchingAnswers'] != null) {
          _matchingAnswers = Map<String, int>.from(data['matchingAnswers']);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAdditionalImage(int index) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _additionalImages[index] = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler bei Bildauswahl: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> urls = List.from(_uploadedImageUrls);

    try {
      final user = _auth.currentUser;
      if (user == null) return urls;

      for (int i = 0; i < _additionalImages.length; i++) {
        if (_additionalImages[i] != null) {
          final ref = _storage.ref().child('dating_images/${user.uid}_$i.jpg');
          final uploadTask = await ref.putFile(_additionalImages[i]!);

          if (uploadTask.state == TaskState.success) {
            final url = await ref.getDownloadURL();
            if (i < urls.length) {
              urls[i] = url;
            } else {
              urls.add(url);
            }
          }
        }
      }
    } catch (e) {
      print('Fehler beim Upload: $e');
    }

    return urls;
  }

  Future<void> _saveDatingProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Prüfen ob mindestens 75% der Matching-Fragen beantwortet wurden
    if (_matchingAnswers.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte beantworte mindestens 8 der 10 Matching-Fragen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Bilder hochladen
      final imageUrls = await _uploadImages();

      // Dating-Profil Daten
      final datingData = {
        // Textfelder
        'aboutMe': _aboutMeController.text.trim(),
        'lookingFor': _lookingForController.text.trim(),
        'important': _importantController.text.trim(),
        'hobbies': _hobbiesController.text.trim(),
        'job': _jobController.text.trim(),
        'education': _educationController.text.trim(),

        // Eigenschaften
        'relationshipGoal': _relationshipGoal,
        'hasKids': _hasKids,
        'wantsKids': _wantsKids,
        'smoking': _smoking,
        'drinking': _drinking,
        'religion': _religion,
        'politics': _politics,
        'pets': _pets,
        'exercise': _exercise,
        'diet': _diet,

        // Bilder
        'additionalImages': imageUrls,

        // Matching
        'matchingAnswers': _matchingAnswers,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // In Firestore speichern
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dating')
          .doc('profile')
          .set(datingData, SetOptions(merge: true));

      // Basis-Profil aktualisieren
      await _firestore.collection('users').doc(user.uid).update({
        'hasDatingProfile': true,
        'datingProfileCompleted': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dating-Profil erfolgreich gespeichert!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MukkeDating Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentPage == 3)
            TextButton(
              onPressed: _isSaving ? null : _saveDatingProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Speichern',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: index <= _currentPage
                                ? AppColors.accent
                                : Colors.grey[700],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // Page Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        // Seite 1: Basis-Informationen
                        _buildBasicInfoPage(),

                        // Seite 2: Lifestyle & Eigenschaften
                        _buildLifestylePage(),

                        // Seite 3: Bilder
                        _buildImagesPage(),

                        // Seite 4: Matching-Fragen
                        _buildMatchingQuestionsPage(),
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        ElevatedButton.icon(
                          onPressed: _previousPage,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Zurück'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                          ),
                        )
                      else
                        const SizedBox(width: 120),
                      if (_currentPage < 3)
                        ElevatedButton.icon(
                          onPressed: _nextPage,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Weiter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                          ),
                        )
                      else
                        const SizedBox(width: 120),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Seite 1: Basis-Informationen
  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Erzähl etwas über dich',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),

          // Über mich
          TextFormField(
            controller: _aboutMeController,
            decoration: const InputDecoration(
              labelText: 'Über mich',
              hintText: 'Beschreibe dich in ein paar Sätzen...',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.person),
            ),
            maxLines: 4,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte erzähle etwas über dich';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Was ich suche
          TextFormField(
            controller: _lookingForController,
            decoration: const InputDecoration(
              labelText: 'Was ich suche',
              hintText: 'Was suchst du in einer Beziehung?',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.search),
            ),
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 16),

          // Was mir wichtig ist
          TextFormField(
            controller: _importantController,
            decoration: const InputDecoration(
              labelText: 'Was mir wichtig ist',
              hintText: 'Welche Werte sind dir wichtig?',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.favorite),
            ),
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 16),

          // Hobbys
          TextFormField(
            controller: _hobbiesController,
            decoration: const InputDecoration(
              labelText: 'Meine Hobbys',
              hintText: 'Was machst du gerne in deiner Freizeit?',
              prefixIcon: Icon(Icons.sports_esports),
            ),
            maxLength: 200,
          ),
          const SizedBox(height: 16),

          // Beruf
          TextFormField(
            controller: _jobController,
            decoration: const InputDecoration(
              labelText: 'Beruf',
              hintText: 'Was machst du beruflich?',
              prefixIcon: Icon(Icons.work),
            ),
          ),
          const SizedBox(height: 16),

          // Bildung
          TextFormField(
            controller: _educationController,
            decoration: const InputDecoration(
              labelText: 'Bildung',
              hintText: 'Dein Bildungsweg',
              prefixIcon: Icon(Icons.school),
            ),
          ),
        ],
      ),
    );
  }

  // Seite 2: Lifestyle & Eigenschaften
  Widget _buildLifestylePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dein Lifestyle',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),

          // Beziehungsziel
          _buildDropdownField(
            label: 'Was suchst du?',
            value: _relationshipGoal,
            icon: Icons.favorite_border,
            items: const [
              'Feste Beziehung',
              'Etwas Lockeres',
              'Neue Freunde',
              'Noch unsicher',
              'Ehe',
            ],
            onChanged: (value) {
              setState(() {
                _relationshipGoal = value;
              });
            },
          ),

          // Kinder
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Hast du Kinder?',
                  value: _hasKids,
                  icon: Icons.child_care,
                  items: const [
                    'Ja',
                    'Nein',
                    'Ja, leben nicht bei mir',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _hasKids = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Kinderwunsch?',
                  value: _wantsKids,
                  icon: Icons.child_friendly,
                  items: const [
                    'Ja',
                    'Nein',
                    'Vielleicht',
                    'Bereits vorhanden',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _wantsKids = value;
                    });
                  },
                ),
              ),
            ],
          ),

          // Rauchen & Alkohol
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Rauchen',
                  value: _smoking,
                  icon: Icons.smoking_rooms,
                  items: const [
                    'Nie',
                    'Gelegentlich',
                    'Regelmäßig',
                    'Versuche aufzuhören',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _smoking = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Alkohol',
                  value: _drinking,
                  icon: Icons.local_bar,
                  items: const [
                    'Nie',
                    'Selten',
                    'Gesellschaftlich',
                    'Regelmäßig',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _drinking = value;
                    });
                  },
                ),
              ),
            ],
          ),

          // Sport & Ernährung
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Sport',
                  value: _exercise,
                  icon: Icons.fitness_center,
                  items: const [
                    'Täglich',
                    'Mehrmals pro Woche',
                    'Gelegentlich',
                    'Selten',
                    'Nie',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _exercise = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Ernährung',
                  value: _diet,
                  icon: Icons.restaurant,
                  items: const [
                    'Alles',
                    'Vegetarisch',
                    'Vegan',
                    'Pescetarisch',
                    'Flexitarisch',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _diet = value;
                    });
                  },
                ),
              ),
            ],
          ),

          // Religion & Politik
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Religion',
                  value: _religion,
                  icon: Icons.church,
                  items: const [
                    'Nicht religiös',
                    'Christlich',
                    'Muslimisch',
                    'Jüdisch',
                    'Buddhistisch',
                    'Hinduistisch',
                    'Spirituell',
                    'Andere',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _religion = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Politik',
                  value: _politics,
                  icon: Icons.how_to_vote,
                  items: const [
                    'Nicht politisch',
                    'Liberal',
                    'Konservativ',
                    'Mitte',
                    'Andere',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _politics = value;
                    });
                  },
                ),
              ),
            ],
          ),

          // Haustiere
          _buildDropdownField(
            label: 'Haustiere',
            value: _pets,
            icon: Icons.pets,
            items: const [
              'Keine',
              'Hund(e)',
              'Katze(n)',
              'Andere',
              'Mag keine Tiere',
              'Allergisch',
            ],
            onChanged: (value) {
              setState(() {
                _pets = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Seite 3: Bilder
  Widget _buildImagesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zeig dich von deiner besten Seite',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Füge bis zu 5 weitere Fotos hinzu',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Bilder Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 5,
            itemBuilder: (context, index) {
              final hasImage = _additionalImages[index] != null ||
                  (index < _uploadedImageUrls.length &&
                      _uploadedImageUrls[index].isNotEmpty);

              return GestureDetector(
                onTap: () => _pickAdditionalImage(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasImage ? AppColors.accent : Colors.grey,
                      width: 2,
                    ),
                    image: _additionalImages[index] != null
                        ? DecorationImage(
                            image: FileImage(_additionalImages[index]!),
                            fit: BoxFit.cover,
                          )
                        : (index < _uploadedImageUrls.length &&
                                _uploadedImageUrls[index].isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(_uploadedImageUrls[index]),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: !hasImage
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo,
                                color: Colors.grey,
                                size: 30,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Foto ${index + 1}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _additionalImages[index] = null;
                                    if (index < _uploadedImageUrls.length) {
                                      _uploadedImageUrls[index] = '';
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Tipps
          Card(
            color: AppColors.surfaceDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Foto-Tipps',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Zeige verschiedene Seiten von dir\n'
                    '• Lächeln macht sympathisch\n'
                    '• Gute Beleuchtung ist wichtig\n'
                    '• Aktuelle Fotos verwenden\n'
                    '• Keine Filter übertreiben',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Seite 4: Matching-Fragen
  Widget _buildMatchingQuestionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Matching-Fragen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppColors.surfaceDark,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nur Matches mit 75% Übereinstimmung werden angezeigt!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fragen
          ..._matchingQuestions.map((question) {
            final questionId = question['id'];
            final selectedAnswer = _matchingAnswers[questionId];

            return Card(
              color: AppColors.surfaceDark,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: selectedAnswer != null
                                ? AppColors.accent
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_matchingQuestions.indexOf(question) + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question['question'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      question['options'].length,
                      (index) {
                        final option = question['options'][index];
                        final isSelected = selectedAnswer == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _matchingAnswers[questionId] = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : Colors.grey[700]!,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? AppColors.accent
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Fortschritt
          Center(
            child: Column(
              children: [
                Text(
                  '${_matchingAnswers.length} von 10 Fragen beantwortet',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _matchingAnswers.length / 10,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _matchingAnswers.length >= 8
                        ? Colors.green
                        : AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown Field Widget
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
