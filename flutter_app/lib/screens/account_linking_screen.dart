import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';

class AccountLinkingScreen extends StatefulWidget {
  final Map<String, String> socialLinks;
  final Function(Map<String, String>) onUpdate;

  const AccountLinkingScreen({
    super.key,
    required this.socialLinks,
    required this.onUpdate,
  });

  @override
  _AccountLinkingScreenState createState() => _AccountLinkingScreenState();
}

class _AccountLinkingScreenState extends State<AccountLinkingScreen> {
  late Map<String, TextEditingController> _controllers;
  late Map<String, String> _links;

  final Map<String, Map<String, dynamic>> _platforms = {
    'instagram': {
      'name': 'Instagram',
      'icon': Icons.camera_alt,
      'color': const Color(0xFFE4405F),
      'placeholder': 'instagram.com/deinname',
      'prefix': 'https://instagram.com/',
    },
    'facebook': {
      'name': 'Facebook',
      'icon': Icons.facebook,
      'color': const Color(0xFF1877F2),
      'placeholder': 'facebook.com/deinname',
      'prefix': 'https://facebook.com/',
    },
    'tiktok': {
      'name': 'TikTok',
      'icon': Icons.music_note,
      'color': Colors.black,
      'placeholder': 'tiktok.com/@deinname',
      'prefix': 'https://tiktok.com/@',
    },
    'youtube': {
      'name': 'YouTube',
      'icon': Icons.play_circle_filled,
      'color': const Color(0xFFFF0000),
      'placeholder': 'youtube.com/@deinkanal',
      'prefix': 'https://youtube.com/@',
    },
    'twitter': {
      'name': 'Twitter/X',
      'icon': Icons.tag,
      'color': const Color(0xFF1DA1F2),
      'placeholder': 'twitter.com/deinname',
      'prefix': 'https://twitter.com/',
    },
    'spotify': {
      'name': 'Spotify',
      'icon': Icons.library_music,
      'color': const Color(0xFF1DB954),
      'placeholder': 'open.spotify.com/artist/...',
      'prefix': 'https://open.spotify.com/',
    },
    'soundcloud': {
      'name': 'SoundCloud',
      'icon': Icons.cloud,
      'color': const Color(0xFFFF5500),
      'placeholder': 'soundcloud.com/deinname',
      'prefix': 'https://soundcloud.com/',
    },
    'twitch': {
      'name': 'Twitch',
      'icon': Icons.videogame_asset,
      'color': const Color(0xFF9146FF),
      'placeholder': 'twitch.tv/deinname',
      'prefix': 'https://twitch.tv/',
    },
  };

  @override
  void initState() {
    super.initState();
    _links = Map<String, String>.from(widget.socialLinks);
    _controllers = {};

    _platforms.forEach((key, value) {
      _controllers[key] = TextEditingController(text: _links[key] ?? '');
    });
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _saveLinks() {
    Map<String, String> updatedLinks = {};

    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        updatedLinks[key] = controller.text.trim();
      }
    });

    widget.onUpdate(updatedLinks);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Social Media Links gespeichert!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _testLink(String platform) async {
    final controller = _controllers[platform];
    if (controller == null || controller.text.isEmpty) return;

    String url = controller.text;
    if (!url.startsWith('http')) {
      url = _platforms[platform]!['prefix'] + url;
    }

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link konnte nicht geöffnet werden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Accounts verknüpfen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveLinks,
            tooltip: 'Speichern',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.surfaceDark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verknüpfe deine Social Media Accounts, um deine Reichweite zu erhöhen!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            ..._platforms.entries.map((entry) {
              final platform = entry.key;
              final data = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: AppColors.surfaceDark,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: data['color'],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                data['icon'],
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              data['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (_controllers[platform]!.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () => _testLink(platform),
                                tooltip: 'Link testen',
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controllers[platform],
                          decoration: InputDecoration(
                            hintText: data['placeholder'],
                            prefixIcon: const Icon(
                              Icons.link,
                              color: Colors.grey,
                            ),
                            suffixIcon: _controllers[platform]!.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _controllers[platform]!.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {}); // Für suffixIcon update
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Speichern Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLinks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Verknüpfungen speichern',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Text
            const Center(
              child: Text(
                'Deine Links werden in deinem Profil angezeigt',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
