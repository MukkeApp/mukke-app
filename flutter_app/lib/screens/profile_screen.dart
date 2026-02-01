import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

// Import your providers
import '../providers/user_provider.dart';
import '../utils/constants.dart';

// Import Dating Profile Screen
import 'account_linking_screen.dart';
import 'agb_screen.dart';
import 'dating_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _paypalController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  // State Variables
  bool _isLoading = false;
  bool _isSaving = false;
  File? _profileImage;
  String? _profileImageUrl;
  bool _agbAccepted = false;
  bool _dsgvoAccepted = false;
  String? _selectedGender;

  // Social Media Links
  Map<String, String> _socialLinks = {
    'instagram': '',
    'facebook': '',
    'tiktok': '',
    'youtube': '',
    'twitter': '',
  };

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _paypalController.dispose();
    _descriptionController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // Profildaten laden
  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;

        // Grunddaten
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? user.email ?? '';
        _phoneController.text = data['phone'] ?? '';
        _paypalController.text = data['paypal'] ?? '';
        _descriptionController.text = data['description'] ?? '';

        // Physische Daten
        _heightController.text = data['height']?.toString() ?? '';
        _weightController.text = data['weight']?.toString() ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _selectedGender = data['gender'];

        // Profilbild
        _profileImageUrl = data['profileImageUrl'];

        // Zustimmungen
        _agbAccepted = data['agbAccepted'] ?? false;
        _dsgvoAccepted = data['dsgvoAccepted'] ?? false;

        // Social Media
        if (data['socialLinks'] != null) {
          _socialLinks = Map<String, String>.from(data['socialLinks']);
        }
      }
    } catch (e) {
      _showErrorSnackbar('Fehler beim Laden des Profils: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Profilbild auswählen
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackbar('Fehler beim Bildauswahl: $e');
    }
  }

  // Profilbild hochladen
  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return _profileImageUrl;

    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
      final uploadTask = await ref.putFile(_profileImage!);

      if (uploadTask.state == TaskState.success) {
        return await ref.getDownloadURL();
      }
    } catch (e) {
      _showErrorSnackbar('Fehler beim Hochladen des Bildes: $e');
    }

    return null;
  }

  // Profil speichern
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agbAccepted || !_dsgvoAccepted) {
      _showErrorSnackbar(
          'Bitte akzeptieren Sie die AGB und Datenschutzerklärung');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Profilbild hochladen
      String? imageUrl = await _uploadProfileImage();

      // Daten vorbereiten
      final profileData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'paypal': _paypalController.text.trim(),
        'description': _descriptionController.text.trim(),
        'height': int.tryParse(_heightController.text) ?? 0,
        'weight': int.tryParse(_weightController.text) ?? 0,
        'age': int.tryParse(_ageController.text) ?? 0,
        'gender': _selectedGender,
        'profileImageUrl': imageUrl,
        'socialLinks': _socialLinks,
        'agbAccepted': _agbAccepted,
        'dsgvoAccepted': _dsgvoAccepted,
        'updatedAt': FieldValue.serverTimestamp(),
        'profileCompleted': _isProfileComplete(),
      };

      // In Firestore speichern
      await _firestore.collection('users').doc(user.uid).set(
            profileData,
            SetOptions(merge: true),
          );

      // Provider aktualisieren
      context.read<UserProvider>().updateUserData(profileData);

      _showSuccessSnackbar('Profil erfolgreich gespeichert!');
    } catch (e) {
      _showErrorSnackbar('Fehler beim Speichern: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Prüfen ob Profil vollständig
  bool _isProfileComplete() {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _selectedGender != null &&
        _agbAccepted &&
        _dsgvoAccepted;
  }

  // Konto löschen Dialog
  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Konto vollständig löschen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Alle gespeicherten Daten, Videos und Musik werden gelöscht und können nicht wiederhergestellt werden.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Passwort zur Bestätigung',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => _deleteAccount(passwordController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Endgültig löschen'),
          ),
        ],
      ),
    );
  }

  // Konto löschen
  Future<void> _deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Passwort verifizieren
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Daten aus Firestore löschen
      await _firestore.collection('users').doc(user.uid).delete();

      // Profilbild löschen
      try {
        await _storage.ref().child('profile_images/${user.uid}.jpg').delete();
      } catch (e) {
        // Fehler ignorieren falls kein Bild existiert
      }

      // Account löschen
      await user.delete();

      // Zur Login-Seite navigieren
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );

      _showSuccessSnackbar('Konto erfolgreich gelöscht');
    } catch (e) {
      Navigator.pop(context);

      if (e.toString().contains('wrong-password')) {
        _showErrorSnackbar('Falsches Passwort');
        _showPasswordResetOption();
      } else {
        _showErrorSnackbar('Fehler beim Löschen: $e');
      }
    }
  }

  // Passwort zurücksetzen Option
  void _showPasswordResetOption() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passwort vergessen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Möchten Sie Ihr Passwort zurücksetzen?'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-Mail Adresse',
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _auth.sendPasswordResetEmail(
                  email: _emailController.text,
                );
                Navigator.pop(context);
                _showSuccessSnackbar(
                  'Passwort-Reset Link wurde an ${_emailController.text} gesendet',
                );
              } catch (e) {
                _showErrorSnackbar('Fehler: $e');
              }
            },
            child: const Text('Link senden'),
          ),
        ],
      ),
    );
  }

  // Success Snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Error Snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mein Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
              tooltip: 'Profil speichern',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profilbild
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 3,
                                ),
                                image: _profileImage != null
                                    ? DecorationImage(
                                        image: FileImage(_profileImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : _profileImageUrl != null
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(_profileImageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: (_profileImage == null &&
                                      _profileImageUrl == null)
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Tippe zum Ändern',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Persönliche Daten Section
                    _buildSectionTitle('Persönliche Daten'),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name oder Pseudonym',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben Sie einen Namen ein';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email (nicht editierbar wenn von Auth)
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-Mail Adresse',
                        prefixIcon: Icon(Icons.email),
                      ),
                      enabled: false,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Telefonnummer
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefonnummer (optional)',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Geschlecht, Alter, Größe, Gewicht in einer Reihe
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Geschlecht',
                              prefixIcon: Icon(Icons.wc),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text('Männlich'),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text('Weiblich'),
                              ),
                              DropdownMenuItem(
                                value: 'diverse',
                                child: Text('Divers'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Alter',
                              suffixText: 'Jahre',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Größe und Gewicht
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: 'Größe',
                              prefixIcon: Icon(Icons.height),
                              suffixText: 'cm',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                              labelText: 'Gewicht',
                              prefixIcon: Icon(Icons.monitor_weight),
                              suffixText: 'kg',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Beschreibung
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Über mich (optional)',
                        prefixIcon: Icon(Icons.info),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 24),

                    // Zahlungsinformationen
                    _buildSectionTitle('Zahlungsinformationen'),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _paypalController,
                      decoration: const InputDecoration(
                        labelText: 'PayPal E-Mail (für Auszahlungen)',
                        prefixIcon: Icon(Icons.payment),
                        helperText: 'Für Einnahmen aus Challenges und Spielen',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildSectionTitle('Profil-Aktionen'),
                    const SizedBox(height: 16),

                    // Accounts verknüpfen
                    _buildActionButton(
                      icon: Icons.link,
                      label: 'Accounts verknüpfen',
                      color: AppColors.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountLinkingScreen(
                              socialLinks: _socialLinks,
                              onUpdate: (links) {
                                setState(() {
                                  _socialLinks = links;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Dating Profil
                    _buildActionButton(
                      icon: Icons.favorite,
                      label: 'Profil für MukkeDating vervollständigen',
                      color: Colors.pink,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DatingProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Rechtliches
                    _buildSectionTitle('Rechtliches & Zustimmung'),
                    const SizedBox(height: 16),

                    // AGB Checkbox
                    Card(
                      color: AppColors.surfaceDark,
                      child: CheckboxListTile(
                        title: const Text('Ich akzeptiere die AGB'),
                        subtitle: const Text(
                          'Tippe hier um die AGB zu lesen',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _agbAccepted,
                        onChanged: (value) {
                          if (!_agbAccepted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AGBScreen(
                                  onAccept: () {
                                    setState(() {
                                      _agbAccepted = true;
                                    });
                                  },
                                ),
                              ),
                            );
                          } else {
                            setState(() {
                              _agbAccepted = value!;
                            });
                          }
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // DSGVO Checkbox
                    Card(
                      color: AppColors.surfaceDark,
                      child: CheckboxListTile(
                        title: const Text(
                            'Ich stimme der Datenschutzerklärung zu'),
                        subtitle: const Text(
                          'Deine Daten werden sicher und DSGVO-konform gespeichert',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _dsgvoAccepted,
                        onChanged: (value) {
                          setState(() {
                            _dsgvoAccepted = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Haftungsausschluss
                    Card(
                      color: AppColors.surfaceDark,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bei Challenges und Live-Aktivitäten handeln Sie auf eigenes Risiko. Die MukkeApp übernimmt keine Haftung.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Speichern Button
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Profil speichern',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),

                    // Konto löschen
                    Center(
                      child: TextButton.icon(
                        onPressed: _showDeleteAccountDialog,
                        icon:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text(
                          'Konto vollständig löschen',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  // Action Button Widget
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class dating_profile_screen {
  const dating_profile_screen();
}
