import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';

class AGBScreen extends StatefulWidget {
  final Function()? onAccept;
  
  const AGBScreen({
    super.key,
    this.onAccept,
  });

  @override
  _AGBScreenState createState() => _AGBScreenState();
}

class _AGBScreenState extends State<AGBScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _agbAccepted = false;
  bool _haftungAccepted = false;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _acceptTerms() {
    if (_agbAccepted && _haftungAccepted) {
      widget.onAccept?.call();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte akzeptieren Sie beide Bedingungen'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AGB & Rechtliches'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'AGB & Schutz'),
            Tab(text: 'Haftung & Verantwortung'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: AGB & Schutz
                _buildAGBContent(),
                
                // Tab 2: Haftung & Verantwortung
                _buildHaftungContent(),
              ],
            ),
          ),
          
          // Akzeptieren Section
          Container(
            padding: const EdgeInsets.all(16),
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
                CheckboxListTile(
                  value: _agbAccepted,
                  onChanged: (value) {
                    setState(() {
                      _agbAccepted = value!;
                    });
                  },
                  title: const Text(
                    'Ich habe die AGB gelesen und akzeptiere diese',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                ),
                CheckboxListTile(
                  value: _haftungAccepted,
                  onChanged: (value) {
                    setState(() {
                      _haftungAccepted = value!;
                    });
                  },
                  title: const Text(
                    'Ich übernehme die volle Verantwortung für meine Aktivitäten',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_agbAccepted && _haftungAccepted)
                        ? _acceptTerms
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Bedingungen akzeptieren',
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
        ],
      ),
    );
  }

  Widget _buildAGBContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            '§1 Geltungsbereich und Anbieter',
            'Diese Allgemeinen Geschäftsbedingungen (nachfolgend "AGB") gelten für die Nutzung der MukkeApp '
            '(nachfolgend "App") und alle damit verbundenen Dienstleistungen.\n\n'
            'Anbieter der App ist:\n'
            'Florian Schulz (MAPSTAR)\n'
            'Querstraße 18\n'
            '29365 Sprakensehl\n'
            'Deutschland\n'
            'E-Mail: mapstar1588@web.de',
          ),
          
          _buildSection(
            '§2 Vertragsschluss und Registrierung',
            '1. Die Nutzung der App erfordert eine Registrierung mit gültiger E-Mail-Adresse.\n'
            '2. Mit der Registrierung bestätigt der Nutzer, mindestens 16 Jahre alt zu sein.\n'
            '3. Der Nutzer verpflichtet sich, wahrheitsgemäße Angaben zu machen.\n'
            '4. Ein Anspruch auf Registrierung besteht nicht.\n'
            '5. Pro Person ist nur ein Nutzerkonto erlaubt.',
          ),
          
          _buildSection(
            '§3 Leistungsumfang',
            'Die MukkeApp bietet folgende Hauptfunktionen:\n'
            '• Musik-Streaming und Upload\n'
            '• Dating-Funktionen (MukkeDating)\n'
            '• Sport- und Fitness-Features (MukkeSport)\n'
            '• Live-Challenges mit Geldgewinnen\n'
            '• Virtuelle Mode-Anprobe (MukkeMode)\n'
            '• Sprachlernsystem (MukkeSprache)\n'
            '• Spiele und Wettbewerbe\n'
            '• KI-Avatar als persönlicher Begleiter\n\n'
            'Der konkrete Funktionsumfang kann je nach Abo-Modell variieren.',
          ),
          
          _buildSection(
            '§4 Nutzungsrechte und Lizenzen',
            '1. Mit dem Upload von Inhalten räumt der Nutzer der MukkeApp ein einfaches, '
            'zeitlich und räumlich unbeschränktes Nutzungsrecht ein.\n'
            '2. Der Nutzer versichert, dass er über alle erforderlichen Rechte an den '
            'hochgeladenen Inhalten verfügt.\n'
            '3. Urheberrechtsverletzungen führen zur sofortigen Sperrung des Accounts.\n'
            '4. Die App und alle ihre Inhalte sind urheberrechtlich geschützt.',
          ),
          
          _buildSection(
            '§5 Zahlungsbedingungen',
            '1. Abo-Gebühren: 9,99€/Monat (Einzelperson), 19,99€/Monat (Familie)\n'
            '2. Zahlungen erfolgen über PayPal, Klarna, Google Pay, Apple Pay oder Kreditkarte.\n'
            '3. Bei Challenges und Spielen mit Geldeinsatz erhält der Betreiber 20% Verwaltungsgebühr.\n'
            '4. Auszahlungen erfolgen auf das hinterlegte PayPal-Konto.\n'
            '5. Keine Rückerstattung bei selbst verschuldeten Verlusten.',
          ),
          
          _buildSection(
            '§6 Datenschutz',
            '1. Die Verarbeitung personenbezogener Daten erfolgt gemäß DSGVO.\n'
            '2. Details zur Datenverarbeitung finden sich in der separaten Datenschutzerklärung.\n'
            '3. Der Nutzer hat jederzeit das Recht auf Auskunft, Berichtigung und Löschung.\n'
            '4. KI-Avatar-Daten werden nur lokal auf dem Gerät gespeichert (mit Zustimmung).',
          ),
          
          _buildSection(
            '§7 Verhaltensregeln',
            'Verboten sind insbesondere:\n'
            '• Beleidigungen, Hassrede oder Diskriminierung\n'
            '• Pornografische oder gewaltverherrlichende Inhalte\n'
            '• Spam oder kommerzielle Werbung ohne Genehmigung\n'
            '• Manipulation von Spielen oder Challenges\n'
            '• Mehrfachaccounts oder Identitätstäuschung\n'
            '• Verstöße gegen geltendes Recht',
          ),
          
          _buildSection(
            '§8 Schutz des geistigen Eigentums',
            '1. Die MukkeApp, ihr Design, Code und Konzept sind geschütztes Eigentum.\n'
            '2. Jegliche Nachahmung, Kopie oder Reverse Engineering ist untersagt.\n'
            '3. Bei Verstoß werden rechtliche Schritte eingeleitet.\n'
            '4. Schadensersatzforderungen in Höhe von mindestens 100.000€ pro Verstoß.\n'
            '5. Weltweiter Schutz durch internationale Urheberrechtsabkommen.',
          ),
          
          _buildSection(
            '§9 Kündigung und Sperrung',
            '1. Das Abo ist monatlich kündbar.\n'
            '2. Bei Verstößen erfolgt sofortige Sperrung ohne Rückerstattung.\n'
            '3. Der Nutzer kann sein Konto jederzeit selbst löschen.\n'
            '4. Nach Löschung werden alle Daten nach 30 Tagen endgültig entfernt.\n'
            '5. Ausnahme: Daten, die aus rechtlichen Gründen aufbewahrt werden müssen.',
          ),
          
          _buildSection(
            '§10 Änderungen der AGB',
            '1. Wir behalten uns vor, diese AGB jederzeit zu ändern.\n'
            '2. Änderungen werden 30 Tage vor Inkrafttreten angekündigt.\n'
            '3. Bei wesentlichen Änderungen haben Nutzer ein Sonderkündigungsrecht.\n'
            '4. Die Weiternutzung nach Ablauf der Frist gilt als Zustimmung.',
          ),
          
          _buildSection(
            '§11 Schlussbestimmungen',
            '1. Es gilt deutsches Recht unter Ausschluss des UN-Kaufrechts.\n'
            '2. Gerichtsstand ist Celle, Deutschland.\n'
            '3. Sollten einzelne Bestimmungen unwirksam sein, bleiben die übrigen gültig.\n'
            '4. Mündliche Nebenabreden bestehen nicht.\n\n'
            'Stand: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHaftungContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.red.withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'WICHTIGER HAFTUNGSAUSSCHLUSS',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            '§1 Eigenverantwortung',
            'Jeder Nutzer handelt bei der Teilnahme an Live-Challenges, Sport-Aktivitäten '
            'und allen anderen App-Funktionen auf eigenes Risiko und eigene Verantwortung.\n\n'
            'Dies umfasst insbesondere:\n'
            '• Körperliche Aktivitäten und Fitness-Challenges\n'
            '• Mutproben und waghalsige Aufgaben\n'
            '• Finanzielle Einsätze bei Spielen und Wetten\n'
            '• Treffen mit anderen Nutzern (Dating)\n'
            '• Befolgen von KI-Avatar-Empfehlungen',
          ),
          
          _buildSection(
            '§2 Haftungsausschluss',
            'Der Betreiber der MukkeApp (Florian Schulz / MAPSTAR) übernimmt KEINERLEI Haftung für:\n\n'
            '• Körperliche Verletzungen oder Gesundheitsschäden\n'
            '• Psychische Belastungen oder Traumata\n'
            '• Finanzielle Verluste durch Spiele oder Challenges\n'
            '• Schäden durch Treffen mit anderen Nutzern\n'
            '• Folgen von befolgten Avatar-Ratschlägen\n'
            '• Unfälle während der App-Nutzung\n'
            '• Schäden durch Dritte\n'
            '• Datenverlust oder Hackerangriffe\n'
            '• Suchtverhalten oder exzessive Nutzung',
          ),
          
          _buildSection(
            '§3 Gesundheitsrisiken',
            'WARNUNG: Die Teilnahme an Sport- und Fitness-Aktivitäten kann gesundheitliche '
            'Risiken bergen!\n\n'
            '• Konsultieren Sie vor Beginn einen Arzt\n'
            '• Überfordern Sie sich nicht\n'
            '• Beachten Sie Ihre körperlichen Grenzen\n'
            '• Bei Unwohlsein sofort abbrechen\n'
            '• Notruf-Funktion nutzen bei Notfällen\n\n'
            'Der Betreiber haftet nicht für Verletzungen oder Gesundheitsschäden!',
          ),
          
          _buildSection(
            '§4 Finanzielle Risiken',
            'Bei Spielen und Challenges mit Geldeinsatz:\n\n'
            '• Setzen Sie nur Geld ein, dessen Verlust Sie verkraften können\n'
            '• Es besteht Suchtgefahr - spielen Sie verantwortungsvoll\n'
            '• Gewinne sind nicht garantiert\n'
            '• Verluste werden nicht erstattet\n'
            '• Der Betreiber haftet nicht für Spielschulden\n\n'
            'Bei Anzeichen von Spielsucht wenden Sie sich an:\n'
            'Bundeszentrale für gesundheitliche Aufklärung\n'
            'Tel: 0800-1372700 (kostenlos)',
          ),
          
          _buildSection(
            '§5 Dating-Risiken',
            'Bei der Nutzung von MukkeDating:\n\n'
            '• Treffen erfolgen auf eigenes Risiko\n'
            '• Überprüfen Sie Profile auf Echtheit\n'
            '• Treffen Sie sich anfangs nur an öffentlichen Orten\n'
            '• Informieren Sie Freunde über Treffen\n'
            '• Der Betreiber haftet nicht für Schäden durch andere Nutzer\n'
            '• Keine Garantie für Echtheit von Profilen',
          ),
          
          _buildSection(
            '§6 Minderjährigenschutz',
            'Eltern haften für ihre Kinder!\n\n'
            '• Nutzer unter 18 Jahren benötigen Elternerlaubnis\n'
            '• Eltern müssen Aktivitäten überwachen\n'
            '• Altersgerechte Inhalte können nicht garantiert werden\n'
            '• Eltern tragen volle Verantwortung für minderjährige Nutzer\n'
            '• Tracking-Funktion entbindet nicht von Aufsichtspflicht',
          ),
          
          _buildSection(
            '§7 Technische Risiken',
            'Die App kann folgende technische Probleme aufweisen:\n\n'
            '• Serverausfälle oder Verbindungsprobleme\n'
            '• Fehlerhafte KI-Empfehlungen\n'
            '• Datenverlust durch technische Defekte\n'
            '• Sicherheitslücken trotz Schutzmaßnahmen\n'
            '• Inkompatibilität mit bestimmten Geräten\n\n'
            'Keine Haftung für Schäden durch technische Probleme!',
          ),
          
          _buildSection(
            '§8 Rechtliche Hinweise',
            '• Diese App ersetzt keine professionelle Beratung\n'
            '• KI-Avatar ist kein Ersatz für Ärzte oder Therapeuten\n'
            '• Fitness-Tipps ersetzen keinen Trainer\n'
            '• Bei rechtlichen Fragen konsultieren Sie einen Anwalt\n'
            '• Der Betreiber ist kein Finanzberater',
          ),
          
          _buildSection(
            '§9 Schadensersatz',
            'Schadensersatzansprüche gegen den Betreiber sind ausgeschlossen, es sei denn:\n\n'
            '• Bei Vorsatz oder grober Fahrlässigkeit\n'
            '• Bei Verletzung von Leben, Körper oder Gesundheit\n'
            '• Bei Verletzung wesentlicher Vertragspflichten\n\n'
            'Die Haftung ist auf den vorhersehbaren, typischen Schaden begrenzt.',
          ),
          
          _buildSection(
            '§10 Freistellung',
            'Der Nutzer stellt den Betreiber von allen Ansprüchen Dritter frei, die durch:\n\n'
            '• Verstöße gegen diese Nutzungsbedingungen\n'
            '• Verletzung von Rechten Dritter\n'
            '• Hochgeladene Inhalte\n'
            '• Teilnahme an Challenges\n'
            '• Sonstige Nutzung der App\n\n'
            'entstehen. Dies umfasst auch angemessene Rechtsverteidigungskosten.',
          ),
          
          const SizedBox(height: 24),
          
          Card(
            color: AppColors.primary.withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zusammenfassung:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Mit der Nutzung der MukkeApp erklären Sie:\n\n'
                    '✓ Sie handeln auf eigenes Risiko\n'
                    '✓ Sie übernehmen volle Verantwortung\n'
                    '✓ Sie verzichten auf Haftungsansprüche\n'
                    '✓ Sie sind sich aller Risiken bewusst\n'
                    '✓ Sie nutzen die App freiwillig\n\n'
                    'Der Betreiber (Florian Schulz) und die MukkeApp '
                    'übernehmen KEINE Haftung für Schäden jeglicher Art!',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}