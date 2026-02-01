import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AGBScreen extends StatefulWidget {
  /// Kompatibel für:
  /// - onAccept: () { ... }
  /// - onAccept: (bool accepted) { ... }
  final Function? onAccept;

  const AGBScreen({super.key, this.onAccept});

  @override
  State<AGBScreen> createState() => _AGBScreenState();
}

class _AGBScreenState extends State<AGBScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasAccepted = false;
  int _currentSection = 0;

  final List<Map<String, dynamic>> _sections = [
    {
      'title': '1. Geltungsbereich',
      'content': '''
Diese Allgemeinen Geschäftsbedingungen (nachfolgend "AGB") gelten für die Nutzung der Mukke App (nachfolgend "App") und alle damit verbundenen Dienstleistungen.

Durch die Nutzung der App erklären Sie sich mit diesen AGB einverstanden. Wenn Sie mit diesen AGB nicht einverstanden sind, dürfen Sie die App nicht nutzen.
      ''',
    },
    {
      'title': '2. Nutzungsbedingungen',
      'content': '''
2.1 Registrierung und Account
- Die Nutzung bestimmter Funktionen erfordert eine Registrierung.
- Sie müssen bei der Registrierung wahrheitsgemäße Angaben machen.
- Sie sind für die Sicherheit Ihres Accounts verantwortlich.
- Sie müssen mindestens 16 Jahre alt sein.

2.2 Verbotene Aktivitäten
Folgende Aktivitäten sind untersagt:
- Hochladen illegaler Inhalte
- Belästigung anderer Nutzer
- Spam und unerwünschte Werbung
- Verletzung von Urheberrechten
- Manipulation oder Hacking der App
      ''',
    },
    {
      'title': '3. Inhalte & Urheberrechte',
      'content': '''
3.1 Ihre Inhalte
- Sie behalten die Rechte an den von Ihnen hochgeladenen Inhalten.
- Sie gewähren uns eine Lizenz zur Nutzung Ihrer Inhalte im Rahmen der App.

3.2 Unsere Inhalte
- Alle Inhalte der App (Design, Texte, Code) sind urheberrechtlich geschützt.
- Die Nutzung ist nur im Rahmen der App gestattet.
      ''',
    },
    {
      'title': '4. Datenschutz',
      'content': '''
Der Schutz Ihrer Daten ist uns wichtig. Details zur Datenverarbeitung finden Sie in unserer Datenschutzerklärung.

Wichtige Punkte:
- Wir speichern nur notwendige Daten für die App-Funktionalität.
- Ihre Daten werden nicht ohne Ihre Zustimmung an Dritte weitergegeben.
- Sie haben jederzeit das Recht auf Auskunft und Löschung Ihrer Daten.
      ''',
    },
    {
      'title': '5. Haftung',
      'content': '''
5.1 Haftungsausschluss
- Die App wird "wie gesehen" bereitgestellt.
- Wir übernehmen keine Garantie für Verfügbarkeit oder Fehlerfreiheit.

5.2 Haftungsbegrenzung
- Unsere Haftung ist auf Vorsatz und grobe Fahrlässigkeit beschränkt.
- Bei leichter Fahrlässigkeit haften wir nur bei Verletzung wesentlicher Vertragspflichten.
      ''',
    },
    {
      'title': '6. Kündigung',
      'content': '''
6.1 Kündigung durch Sie
- Sie können Ihren Account jederzeit löschen.
- Die Kündigung ist sofort wirksam.

6.2 Kündigung durch uns
- Wir können Accounts bei Verstoß gegen diese AGB sperren oder löschen.
- Bei schwerwiegenden Verstößen erfolgt dies ohne Vorankündigung.
      ''',
    },
    {
      'title': '7. Änderungen',
      'content': '''
Wir behalten uns vor, diese AGB jederzeit zu ändern. Über wesentliche Änderungen werden Sie in der App informiert.

Die weitere Nutzung der App nach Inkrafttreten der Änderungen gilt als Zustimmung.
      ''',
    },
    {
      'title': '8. Schlussbestimmungen',
      'content': '''
8.1 Anwendbares Recht
Es gilt deutsches Recht.

8.2 Gerichtsstand
Gerichtsstand ist, soweit zulässig, der Sitz des Anbieters.

8.3 Salvatorische Klausel
Sollte eine Bestimmung unwirksam sein, bleiben die übrigen Bestimmungen wirksam.
      ''',
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _notifyAccepted() {
    final cb = widget.onAccept;
    if (cb == null) return;

    // onAccept: () { ... }
    if (cb is VoidCallback) {
      cb();
      return;
    }

    // onAccept: (bool accepted) { ... }
    if (cb is ValueChanged<bool>) {
      cb(true);
      return;
    }
  }

  void _scrollToSection(int index) {
    setState(() {
      _currentSection = index;
    });

    // Approximate position for smooth navigation
    final position = index * 600.0;
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: const Text(
          'AGB & Nutzungsbedingungen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Column(
        children: [
          // Section Navigation
          Container(
            height: 60,
            color: surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentSection;
                return GestureDetector(
                  onTap: () => _scrollToSection(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.withAlpha(77),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _sections[index]['title'].toString().split('.').first,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(77),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wichtige Informationen',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Bitte lesen Sie die folgenden Nutzungsbedingungen sorgfältig durch. '
                              'Diese regeln die Nutzung der Mukke App und Ihre Rechte und Pflichten.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sections
                  ...List.generate(_sections.length, (index) {
                    final section = _sections[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(51),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            section['content'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Acceptance
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _hasAccepted
                          ? AppColors.success.withAlpha(26)
                          : surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _hasAccepted
                            ? AppColors.success
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _hasAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _hasAccepted = value ?? false;
                                });
                              },
                              activeColor: AppColors.success,
                              checkColor: Colors.white,
                            ),
                            const Expanded(
                              child: Text(
                                'Ich akzeptiere die Allgemeinen Geschäftsbedingungen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _hasAccepted
                                ? () {
                              _notifyAccepted();
                              Navigator.of(context).pop(true);
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasAccepted
                                  ? AppColors.primary
                                  : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _hasAccepted ? 'Fortfahren' : 'Bitte akzeptieren',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  const Text(
                    'Stand: Januar 2025',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
