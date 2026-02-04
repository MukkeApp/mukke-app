import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:mukke_app/screens/account_linking_screen.dart';
import 'package:mukke_app/screens/dating_profile_screen.dart';
import 'package:mukke_app/screens/mukke_avatar_screen.dart';
import 'package:mukke_app/screens/mukke_fashion_screen.dart';
import 'package:mukke_app/screens/mukke_feedback_screen.dart';
import 'package:mukke_app/screens/mukke_games_screen.dart';
import 'package:mukke_app/screens/mukke_home_screen.dart';
import 'package:mukke_app/screens/mukke_language_screen.dart';
import 'package:mukke_app/screens/mukke_live_screen.dart';
import 'package:mukke_app/screens/mukke_music_screen.dart';
import 'package:mukke_app/utils/constants.dart';

import 'package:mukke_app/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _locationController = TextEditingController();
  final _lookingForController = TextEditingController();

  String? _gender;
  List<String> _favoriteGenres = <String>[];
  List<String> _interests = <String>[];

  File? _profileImage;
  String? _profileImageUrl;

  bool _loading = true;
  bool _saving = false;

  // Banner: für Offline/Fehler-Infos (statt kurz aufblinkender roter Text unten)
  String? _bannerMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _birthdateController.dispose();
    _locationController.dispose();
    _lookingForController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final userProvider = context.read<UserProvider>();

    await userProvider.loadUserData(preferCache: true);

    if (!mounted) return;

    _applyUserData(userProvider.userData);

    setState(() {
      _loading = false;

      if (userProvider.lastErrorCode == 'unavailable') {
        _bannerMessage =
        'Keine Verbindung zu Cloud Firestore (unavailable). Profil wird aus dem Cache angezeigt. '
            'Änderungen werden gespeichert und synchronisieren, sobald die Verbindung wieder da ist.';
      } else {
        _bannerMessage = userProvider.lastErrorMessage;
      }
    });
  }

  void _applyUserData(Map<String, dynamic> data) {
    _nameController.text = (data['name'] ?? '').toString();
    _bioController.text = (data['bio'] ?? '').toString();
    _locationController.text = (data['location'] ?? '').toString();
    _lookingForController.text = (data['lookingFor'] ?? '').toString();

    final genderRaw = data['gender'];
    _gender = genderRaw == null ? null : genderRaw.toString();

    DateTime? birthdate;
    final birthRaw = data['birthdate'];
    if (birthRaw is Timestamp) {
      birthdate = birthRaw.toDate();
    } else if (birthRaw is String) {
      birthdate = DateTime.tryParse(birthRaw);
      if (birthdate == null) {
        try {
          birthdate = DateFormat('dd.MM.yyyy').parseStrict(birthRaw);
        } catch (_) {}
      }
    }
    _birthdateController.text =
    birthdate == null ? '' : DateFormat('dd.MM.yyyy').format(birthdate);

    final genresRaw = data['favoriteGenres'];
    if (genresRaw is List) {
      _favoriteGenres = genresRaw.map((e) => e.toString()).toList();
    } else {
      _favoriteGenres = <String>[];
    }

    final interestsRaw = data['interests'];
    if (interestsRaw is List) {
      _interests = interestsRaw.map((e) => e.toString()).toList();
    } else {
      _interests = <String>[];
    }

    _profileImageUrl =
        (data['photoUrl'] ?? data['profileImageUrl'])?.toString();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1440,
    );
    if (picked == null) return;

    setState(() {
      _profileImage = File(picked.path);
    });
  }

  Future<void> _selectBirthdate() async {
    final now = DateTime.now();
    DateTime initial = DateTime(now.year - 20, now.month, now.day);

    if (_birthdateController.text.trim().isNotEmpty) {
      try {
        initial =
            DateFormat('dd.MM.yyyy').parseStrict(_birthdateController.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Geburtsdatum auswählen',
      cancelText: 'Abbrechen',
      confirmText: 'OK',
    );

    if (picked == null) return;

    setState(() {
      _birthdateController.text = DateFormat('dd.MM.yyyy').format(picked);
    });
  }

  DateTime? _parseBirthdate() {
    final text = _birthdateController.text.trim();
    if (text.isEmpty) return null;
    try {
      return DateFormat('dd.MM.yyyy').parseStrict(text);
    } catch (_) {
      return null;
    }
  }

  bool _isProfileComplete() {
    return _nameController.text.trim().isNotEmpty &&
        _birthdateController.text.trim().isNotEmpty &&
        (_gender != null && _gender!.trim().isNotEmpty) &&
        _locationController.text.trim().isNotEmpty;
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_profileImage == null) return _profileImageUrl;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('profile.jpg');

      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      _showSnack(
        'Profilbild konnte nicht hochgeladen werden: ${e.message ?? e.code}',
        isError: true,
      );
      return _profileImageUrl;
    } catch (e) {
      _showSnack('Profilbild konnte nicht hochgeladen werden.', isError: true);
      return _profileImageUrl;
    }
  }

  Future<void> _saveProfile() async {
    if (_saving) return;

    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showSnack('Du bist nicht eingeloggt.', isError: true);
      return;
    }

    setState(() {
      _saving = true;
      _bannerMessage = null;
    });

    final userProvider = context.read<UserProvider>();

    try {
      final newUrl = await _uploadProfileImage(currentUser.uid);
      if (!mounted) return;

      final birthdate = _parseBirthdate();

      final profileData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'lookingFor': _lookingForController.text.trim(),
        'gender': _gender,
        'favoriteGenres': _favoriteGenres,
        'interests': _interests,
        if (birthdate != null) 'birthdate': Timestamp.fromDate(birthdate),
        if (newUrl != null && newUrl.trim().isNotEmpty) 'photoUrl': newUrl,
      };

      await userProvider.saveUserData(profileData);

      if (!mounted) return;

      if (userProvider.lastErrorMessage != null &&
          userProvider.lastErrorMessage!.trim().isNotEmpty) {
        setState(() {
          _bannerMessage = userProvider.lastErrorCode == 'unavailable'
              ? 'Offline: Änderungen wurden lokal gespeichert und synchronisieren später.'
              : userProvider.lastErrorMessage;
        });
      } else {
        _showSnack('Profil gespeichert.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _addChip({
    required String title,
    required List<String> target,
    required void Function(List<String>) onChanged,
  }) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Eingeben und hinzufügen',
            ),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => Navigator.of(context).pop(controller.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );

    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return;

    if (target.any((e) => e.toLowerCase() == trimmed.toLowerCase())) return;

    onChanged(<String>[...target, trimmed]);
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konto löschen?'),
        content: const Text(
          'Das löscht dein Konto. Je nach App-Logik können Profildaten in Firestore bestehen bleiben '
              'oder separat gelöscht werden. Fortfahren?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.delete();

      if (!mounted) return;
      context.read<UserProvider>().clear();
      _showSnack('Konto gelöscht.');
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        _showSnack(
          'Aus Sicherheitsgründen bitte erneut einloggen und dann Konto löschen.',
          isError: true,
        );
      } else {
        _showSnack('Konto konnte nicht gelöscht werden: ${e.message ?? e.code}',
            isError: true);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Konto konnte nicht gelöscht werden.', isError: true);
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menü',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<UserProvider>(
                  builder: (context, provider, _) {
                    final name = (provider.userData['name'] ?? '').toString();
                    final email = (provider.userData['email'] ?? '').toString();
                    return Text(
                      name.isNotEmpty ? '$name\n$email' : email,
                      style: const TextStyle(color: Colors.white70),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Dating-Profil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DatingProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.face),
            title: const Text('Avatar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MukkeAvatarScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('Musik'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MukkeMusicScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.live_tv),
            title: const Text('Live'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MukkeLiveScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sports_esports),
            title: const Text('Games'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MukkeGamesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.checkroom),
            title: const Text('Fashion'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MukkeFashionScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Sprache'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MukkeLanguageScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MukkeFeedbackScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Konten verknüpfen'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountLinkingScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Abmelden'),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              context.read<UserProvider>().clear();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (r) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Konto löschen',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> values,
    required VoidCallback onAdd,
    required void Function(String) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Hinzufügen'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (values.isEmpty)
          const Text(
            'Noch nichts hinzugefügt.',
            style: TextStyle(color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values
                .map(
                  (v) => Chip(
                label: Text(v),
                onDeleted: () => onRemove(v),
              ),
            )
                .toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primary,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_bannerMessage != null && _bannerMessage!.trim().isNotEmpty)
              MaterialBanner(
                content: Text(_bannerMessage!),
                leading: const Icon(Icons.info_outline),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _bannerMessage = null),
                    child: const Text('OK'),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (_profileImageUrl != null &&
                      _profileImageUrl!.trim().isNotEmpty)
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: (_profileImage == null &&
                      (_profileImageUrl == null ||
                          _profileImageUrl!.trim().isEmpty))
                      ? const Icon(Icons.camera_alt, size: 32)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Bitte Name eingeben';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _birthdateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Geburtsdatum*',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectBirthdate,
                      ),
                    ),
                    onTap: _selectBirthdate,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Bitte Geburtsdatum auswählen';
                      }
                      if (_parseBirthdate() == null) {
                        return 'Ungültiges Datum';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Männlich')),
                      DropdownMenuItem(value: 'female', child: Text('Weiblich')),
                      DropdownMenuItem(value: 'diverse', child: Text('Divers')),
                      DropdownMenuItem(value: 'not_specified', child: Text('Keine Angabe')),
                    ],
                    onChanged: (v) => setState(() => _gender = v),
                    decoration: const InputDecoration(
                      labelText: 'Geschlecht*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Bitte auswählen';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Ort*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Bitte Ort eingeben';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lookingForController,
                    decoration: const InputDecoration(
                      labelText: 'Ich suche…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildChipSection(
                    title: 'Lieblings-Genres',
                    values: _favoriteGenres,
                    onAdd: () => _addChip(
                      title: 'Genre hinzufügen',
                      target: _favoriteGenres,
                      onChanged: (list) =>
                          setState(() => _favoriteGenres = list),
                    ),
                    onRemove: (v) => setState(
                          () => _favoriteGenres =
                          _favoriteGenres.where((e) => e != v).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildChipSection(
                    title: 'Interessen',
                    values: _interests,
                    onAdd: () => _addChip(
                      title: 'Interesse hinzufügen',
                      target: _interests,
                      onChanged: (list) => setState(() => _interests = list),
                    ),
                    onRemove: (v) => setState(
                          () => _interests =
                          _interests.where((e) => e != v).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _saveProfile,
                      icon: const Icon(Icons.save),
                      label: Text(_saving ? 'Speichere…' : 'Profil speichern'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_isProfileComplete())
                    const Text(
                      'Tipp: Name, Geburtsdatum, Geschlecht und Ort ausfüllen, damit dein Profil komplett ist.',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
