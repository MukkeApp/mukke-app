import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

// Utils imports
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class MukkeFeedbackScreen extends StatefulWidget {
  const MukkeFeedbackScreen({super.key});

  @override
  State<MukkeFeedbackScreen> createState() => _MukkeFeedbackScreenState();
}

class _MukkeFeedbackScreenState extends State<MukkeFeedbackScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  
  // Animation Controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _successAnimationController;
  
  // State Variables
  bool _isSubmitting = false;
  bool _showSuccess = false;
  String _selectedCategory = 'Allgemein';
  
  // Kategorien für Vorschläge
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Allgemein', 'icon': Icons.lightbulb, 'color': const Color(0xFF00BFFF)},
    {'name': 'Neue Features', 'icon': Icons.add_circle, 'color': const Color(0xFF32CD32)},
    {'name': 'Verbesserungen', 'icon': Icons.upgrade, 'color': const Color(0xFFFF1493)},
    {'name': 'Bugs', 'icon': Icons.bug_report, 'color': const Color(0xFFFF4500)},
    {'name': 'Design', 'icon': Icons.palette, 'color': const Color(0xFF9370DB)},
    {'name': 'Performance', 'icon': Icons.speed, 'color': const Color(0xFFFFD700)},
  ];

  @override
  void initState() {
    super.initState();
    
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _backgroundAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  Future<void> _submitSuggestion() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Nicht angemeldet');
      
      // Nutzer-Daten abrufen
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      
      // Vorschlag erstellen
      final suggestion = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'userId': user.uid,
        'userName': userData['name'] ?? 'Anonym',
        'userEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'votingEndsAt': DateTime.now().add(const Duration(hours: 24)),
        'status': 'voting', // voting, approved, rejected, implemented
        'votes': {
          'yes': 0,
          'no': 0,
        },
        'voters': [], // Liste der User IDs die bereits abgestimmt haben
        'adminDecision': null,
        'implementationNotes': null,
      };
      
      // In Firestore speichern
      final docRef = await _firestore.collection('suggestions').add(suggestion);
      
      // Benachrichtigung für Admin erstellen
      await _firestore.collection('admin_notifications').add({
        'type': 'new_suggestion',
        'suggestionId': docRef.id,
        'title': 'Neuer Verbesserungsvorschlag',
        'message': '${userData['name'] ?? 'Ein Nutzer'} hat einen neuen Vorschlag eingereicht: ${_titleController.text}',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      
      // Erfolg anzeigen
      setState(() {
        _showSuccess = true;
        _isSubmitting = false;
      });
      
      _successAnimationController.forward();
      
      // Form zurücksetzen nach 3 Sekunden
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            _titleController.clear();
            _descriptionController.clear();
            _selectedCategory = 'Allgemein';
          });
        }
      });
      
    } catch (e) {
      setState(() => _isSubmitting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Einreichen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeveloper = _auth.currentUser?.email == 'mapstar1588@web.de';
    
    return DefaultTabController(
      length: isDeveloper ? 3 : 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Verbesserungsvorschläge',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFF00BFFF),
            indicatorWeight: 3,
            tabs: [
              const Tab(
                icon: Icon(Icons.add_circle_outline),
                text: 'Neuer Vorschlag',
              ),
              const Tab(
                icon: Icon(Icons.how_to_vote),
                text: 'Abstimmungen',
              ),
              if (isDeveloper)
                const Tab(
                  icon: Icon(Icons.admin_panel_settings),
                  text: 'Admin',
                ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Animierter Hintergrund
            AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ImprovementBackgroundPainter(
                    animation: _backgroundAnimationController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            
            // Tab Views
            TabBarView(
              children: [
                _buildSuggestionForm(),
                _buildVotingList(),
                if (isDeveloper) _buildAdminPanel(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tab 1: Vorschlag einreichen
  Widget _buildSuggestionForm() {
    if (_showSuccess) {
      return _buildSuccessView();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00BFFF).withOpacity(0.2),
                    const Color(0xFF32CD32).withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 48,
                    color: Color(0xFF32CD32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Deine Idee zählt!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Teile deine Verbesserungsvorschläge und lass die Community abstimmen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Kategorie Auswahl
            const Text(
              'Kategorie wählen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['name'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'];
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category['color'].withOpacity(0.3)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? category['color']
                              : Colors.white.withOpacity(0.1),
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
                                  ? FontWeight.w600
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
            const SizedBox(height: 24),
            
            // Titel
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Titel deines Vorschlags',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.title, color: Color(0xFF00BFFF)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF00BFFF),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib einen Titel ein';
                }
                if (value.length < 5) {
                  return 'Der Titel sollte mindestens 5 Zeichen lang sein';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Beschreibung
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 6,
              maxLength: 1000,
              decoration: InputDecoration(
                labelText: 'Beschreibe deine Idee ausführlich',
                labelStyle: const TextStyle(color: Colors.white70),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.description, color: Color(0xFF00BFFF)),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF00BFFF),
                    width: 2,
                  ),
                ),
                counterStyle: const TextStyle(color: Colors.white54),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte beschreibe deinen Vorschlag';
                }
                if (value.length < 20) {
                  return 'Die Beschreibung sollte mindestens 20 Zeichen lang sein';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00BFFF).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF00BFFF),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nach dem Einreichen startet eine 24-Stunden-Abstimmung. '
                      'Bei über 60% Zustimmung wird dein Vorschlag umgesetzt!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Submit Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF32CD32),
                    Color(0xFF00FA9A),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF32CD32).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitSuggestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'Vorschlag einreichen',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Success View nach Einreichung
  Widget _buildSuccessView() {
    return Center(
      child: AnimatedBuilder(
        animation: _successAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _successAnimationController.value,
            child: Container(
              padding: const EdgeInsets.all(40),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF32CD32).withOpacity(0.2),
                    const Color(0xFF00FA9A).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF32CD32),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF32CD32).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 48,
                      color: Color(0xFF32CD32),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Erfolgreich eingereicht!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF32CD32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Die 24-Stunden-Abstimmung läuft jetzt.\n'
                    'Du wirst per WhatsApp benachrichtigt,\n'
                    'wenn dein Vorschlag umgesetzt wird.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Icon(
                    Icons.timer,
                    size: 32,
                    color: Color(0xFF00BFFF),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '24:00:00',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00BFFF),
                      fontFamily: 'monospace',
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

  // Tab 2: Aktuelle Abstimmungen
  Widget _buildVotingList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('suggestions')
          .where('status', isEqualTo: 'voting')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF00BFFF),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.how_to_vote_outlined,
                  size: 64,
                  color: Colors.white30,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Keine aktiven Abstimmungen',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _buildVotingCard(doc.id, data);
          },
        );
      },
    );
  }

  // Voting Card Widget
  Widget _buildVotingCard(String docId, Map<String, dynamic> data) {
    final votes = data['votes'] as Map<String, dynamic>;
    final totalVotes = (votes['yes'] ?? 0) + (votes['no'] ?? 0);
    final yesPercentage = totalVotes > 0 ? (votes['yes'] / totalVotes * 100) : 0.0;
    final hasVoted = (data['voters'] as List).contains(_auth.currentUser?.uid);
    
    // Berechne verbleibende Zeit
    final votingEndsAt = (data['votingEndsAt'] as Timestamp).toDate();
    final timeRemaining = votingEndsAt.difference(DateTime.now());
    final hoursRemaining = timeRemaining.inHours;
    final minutesRemaining = timeRemaining.inMinutes % 60;
    
    // Finde Kategorie für Farbe
    final categoryData = _categories.firstWhere(
      (cat) => cat['name'] == data['category'],
      orElse: () => _categories[0],
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryData['color'].withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: categoryData['color'].withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: categoryData['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        categoryData['icon'],
                        size: 16,
                        color: categoryData['color'],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        data['category'],
                        style: TextStyle(
                          color: categoryData['color'],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Zeit verbleibend
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: timeRemaining.isNegative
                        ? Colors.red.withOpacity(0.2)
                        : const Color(0xFF00BFFF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: timeRemaining.isNegative
                            ? Colors.red
                            : const Color(0xFF00BFFF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeRemaining.isNegative
                            ? 'Abgelaufen'
                            : '${hoursRemaining}h ${minutesRemaining}m',
                        style: TextStyle(
                          color: timeRemaining.isNegative
                              ? Colors.red
                              : const Color(0xFF00BFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Titel
            Text(
              data['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Beschreibung
            Text(
              data['description'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Einreicher
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF00BFFF).withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: Color(0xFF00BFFF),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'von ${data['userName']}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Abstimmungs-Fortschritt
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${yesPercentage.toStringAsFixed(0)}% Zustimmung',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$totalVotes Stimmen',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: yesPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.red.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      yesPercentage >= 60
                          ? const Color(0xFF32CD32)
                          : const Color(0xFF00BFFF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Abstimmungs-Buttons
            if (!hasVoted && !timeRemaining.isNegative) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _vote(docId, true),
                      icon: const Icon(Icons.thumb_up),
                      label: const Text('Dafür'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF32CD32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _vote(docId, false),
                      icon: const Icon(Icons.thumb_down),
                      label: const Text('Dagegen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (hasVoted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00BFFF).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF00BFFF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Du hast bereits abgestimmt',
                      style: TextStyle(
                        color: Color(0xFF00BFFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Vote Function
  Future<void> _vote(String suggestionId, bool voteYes) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;
      
      await _firestore.runTransaction((transaction) async {
        final suggestionDoc = await transaction.get(
          _firestore.collection('suggestions').doc(suggestionId),
        );
        
        if (!suggestionDoc.exists) return;
        
        final data = suggestionDoc.data()!;
        final voters = List<String>.from(data['voters'] ?? []);
        
        if (voters.contains(userId)) {
          throw Exception('Du hast bereits abgestimmt');
        }
        
        voters.add(userId);
        final votes = Map<String, dynamic>.from(data['votes']);
        votes[voteYes ? 'yes' : 'no'] = (votes[voteYes ? 'yes' : 'no'] ?? 0) + 1;
        
        transaction.update(
          suggestionDoc.reference,
          {
            'voters': voters,
            'votes': votes,
          },
        );
      });
      
      HapticFeedback.mediumImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deine Stimme wurde gezählt!'),
          backgroundColor: Color(0xFF32CD32),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Tab 3: Admin Panel (nur für Entwickler)
  Widget _buildAdminPanel() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Color(0xFFFF1493),
            tabs: [
              Tab(text: 'Aktiv'),
              Tab(text: 'Entschieden'),
              Tab(text: 'Statistiken'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAdminActiveList(),
                _buildAdminDecidedList(),
                _buildAdminStatistics(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Admin: Aktive Vorschläge
  Widget _buildAdminActiveList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('suggestions')
          .where('adminDecision', isEqualTo: null)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _buildAdminCard(doc.id, data, true);
          },
        );
      },
    );
  }

  // Admin: Entschiedene Vorschläge
  Widget _buildAdminDecidedList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('suggestions')
          .where('adminDecision', isNotEqualTo: null)
          .orderBy('adminDecision')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _buildAdminCard(doc.id, data, false);
          },
        );
      },
    );
  }

  // Admin Card
  Widget _buildAdminCard(String docId, Map<String, dynamic> data, bool showActions) {
    final votes = data['votes'] as Map<String, dynamic>;
    final totalVotes = (votes['yes'] ?? 0) + (votes['no'] ?? 0);
    final yesPercentage = totalVotes > 0 ? (votes['yes'] / totalVotes * 100) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF1493).withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF1493).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Status
          Row(
            children: [
              if (data['adminDecision'] == 'approved')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF32CD32).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 16, color: Color(0xFF32CD32)),
                      const SizedBox(width: 4),
                      const Text(
                        'Genehmigt',
                        style: TextStyle(
                          color: Color(0xFF32CD32),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (data['adminDecision'] == 'rejected')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.close, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      const Text(
                        'Abgelehnt',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Text(
                '${yesPercentage.toStringAsFixed(0)}% | $totalVotes Stimmen',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Titel & Beschreibung
          Text(
            data['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['description'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // User Info
          Text(
            'Von: ${data['userName']} (${data['userEmail']})',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          
          // Admin Actions
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _adminDecision(docId, 'approved'),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Umsetzen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF32CD32),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _adminDecision(docId, 'rejected'),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Ablehnen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // Implementation Notes
          if (data['implementationNotes'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Umsetzungsnotizen:',
                    style: TextStyle(
                      color: Color(0xFFFF1493),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['implementationNotes'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Admin Decision
  Future<void> _adminDecision(String suggestionId, String decision) async {
    // Show confirmation dialog
    String? implementationNotes;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: Text(
          decision == 'approved' ? 'Vorschlag umsetzen?' : 'Vorschlag ablehnen?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (decision == 'approved')
              TextField(
                decoration: InputDecoration(
                  labelText: 'Umsetzungsnotizen (optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                onChanged: (value) {
                  implementationNotes = value;
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: decision == 'approved'
                  ? const Color(0xFF32CD32)
                  : Colors.red,
            ),
            child: Text(decision == 'approved' ? 'Umsetzen' : 'Ablehnen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      await _firestore.collection('suggestions').doc(suggestionId).update({
        'adminDecision': decision,
        'status': decision == 'approved' ? 'approved' : 'rejected',
        'decidedAt': FieldValue.serverTimestamp(),
        'implementationNotes': decision == 'approved' 
            ? (implementationNotes ?? 'Wird in der nächsten Version umgesetzt')
            : null,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decision == 'approved'
                ? 'Vorschlag wird umgesetzt!'
                : 'Vorschlag wurde abgelehnt',
          ),
          backgroundColor: decision == 'approved'
              ? const Color(0xFF32CD32)
              : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Admin Statistics
  Widget _buildAdminStatistics() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('suggestions').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final docs = snapshot.data!.docs;
        final total = docs.length;
        final approved = docs.where((d) => (d.data() as Map)['adminDecision'] == 'approved').length;
        final rejected = docs.where((d) => (d.data() as Map)['adminDecision'] == 'rejected').length;
        final pending = docs.where((d) => (d.data() as Map)['adminDecision'] == null).length;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Statistik Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Gesamt',
                      total.toString(),
                      Icons.inventory,
                      const Color(0xFF00BFFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Ausstehend',
                      pending.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Genehmigt',
                      approved.toString(),
                      Icons.check_circle,
                      const Color(0xFF32CD32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Abgelehnt',
                      rejected.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Umsetzungsrate
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF32CD32).withOpacity(0.1),
                      const Color(0xFF00FA9A).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF32CD32).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Umsetzungsrate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: total > 0 ? approved / total : 0,
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF32CD32),
                            ),
                          ),
                        ),
                        Text(
                          total > 0
                              ? '${(approved / total * 100).toStringAsFixed(0)}%'
                              : '0%',
                          style: const TextStyle(
                            color: Color(0xFF32CD32),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Stat Card Widget
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Background Painter
class ImprovementBackgroundPainter extends CustomPainter {
  final double animation;
  
  ImprovementBackgroundPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Floating Bubbles
    for (int i = 0; i < 5; i++) {
      final progress = (animation + i * 0.2) % 1.0;
      final y = size.height - (progress * size.height * 1.5);
      final x = size.width * 0.2 + (i * size.width * 0.15) + 
                 math.sin(progress * math.pi * 2 + i) * 30;
      final radius = 20 + i * 5.0;
      
      paint.color = (i % 2 == 0 ? const Color(0xFF00BFFF) : const Color(0xFF32CD32))
          .withOpacity(0.1 - progress * 0.1);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
    
    // Grid Pattern
    paint.color = Colors.white.withOpacity(0.02);
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < size.width / 50; i++) {
      canvas.drawLine(
        Offset(i * 50, 0),
        Offset(i * 50, size.height),
        paint,
      );
    }
    
    for (int i = 0; i < size.height / 50; i++) {
      canvas.drawLine(
        Offset(0, i * 50),
        Offset(size.width, i * 50),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}