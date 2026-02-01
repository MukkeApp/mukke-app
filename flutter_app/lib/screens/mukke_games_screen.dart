import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../utils/constants.dart';
import '../providers/user_provider.dart';
import '../services/payment_service.dart';

class MukkeGamesScreen extends StatefulWidget {
  const MukkeGamesScreen({super.key});

  @override
  State<MukkeGamesScreen> createState() => _MukkeGamesScreenState();
}

class _MukkeGamesScreenState extends State<MukkeGamesScreen>
    with TickerProviderStateMixin {
  // Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late AnimationController _coinController;

  // User Stats
  int _mukkeCoins = 0;
  int _totalWins = 0;
  int _winStreak = 0;
  double _totalEarnings = 0.0;
  bool _isLoadingStats = true;

  // Games List
  final List<Map<String, dynamic>> _games = [
    {
      'id': 'tauziehen',
      'name': 'Tauziehen Battle',
      'icon': Icons.sports_handball,
      'description': 'Tippe schneller als dein Gegner!',
      'minBet': 0.5,
      'maxBet': 50.0,
      'coinReward': 10,
      'gradient': [const Color(0xFF00BFFF), const Color(0xFF1E90FF)],
      'isLive': true,
      'players': 0,
    },
    {
      'id': 'reaction',
      'name': 'Reaction Master',
      'icon': Icons.flash_on,
      'description': 'Teste deine Reflexe!',
      'minBet': 0.2,
      'maxBet': 20.0,
      'coinReward': 5,
      'gradient': [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      'isLive': false,
      'players': 0,
    },
    {
      'id': 'speed',
      'name': 'Speed Challenge',
      'icon': Icons.speed,
      'description': 'Wer ist der Schnellste?',
      'minBet': 1.0,
      'maxBet': 100.0,
      'coinReward': 20,
      'gradient': [const Color(0xFFFF1493), const Color(0xFFFF69B4)],
      'isLive': true,
      'players': 0,
    },
    {
      'id': 'oneeuro',
      'name': '1€ Quick Duel',
      'icon': Icons.euro,
      'description': 'Schnelles Duell um 1€!',
      'fixedBet': 1.0,
      'coinReward': 15,
      'gradient': [const Color(0xFF32CD32), const Color(0xFF00FA9A)],
      'isLive': true,
      'players': 0,
    },
    {
      'id': 'fitness',
      'name': 'Fitness Battle',
      'icon': Icons.fitness_center,
      'description': 'Sport-Duell mit Einsatz!',
      'minBet': 2.0,
      'maxBet': 50.0,
      'coinReward': 25,
      'gradient': [const Color(0xFFFF4500), const Color(0xFFFF6347)],
      'isLive': false,
      'players': 0,
    },
  ];

  // Leaderboard
  List<Map<String, dynamic>> _topPlayers = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserStats();
    _loadLeaderboard();
    _listenToActivePlayers();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _coinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  Future<void> _loadUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _mukkeCoins = data['mukkeCoins'] ?? 0;
          _totalWins = data['gameStats']?['totalWins'] ?? 0;
          _winStreak = data['gameStats']?['currentStreak'] ?? 0;
          _totalEarnings =
              (data['gameStats']?['totalEarnings'] ?? 0.0).toDouble();
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Load stats error: $e');
      setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('gameStats.totalEarnings', descending: true)
          .limit(10)
          .get();

      setState(() {
        _topPlayers = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'uid': doc.id,
            'name': data['name'] ?? 'Anonym',
            'earnings': data['gameStats']?['totalEarnings'] ?? 0.0,
            'wins': data['gameStats']?['totalWins'] ?? 0,
          };
        }).toList();
      });
    } catch (e) {
      print('Load leaderboard error: $e');
    }
  }

  void _listenToActivePlayers() {
    // Simuliere aktive Spieler (später durch echte Daten ersetzen)
    Stream.periodic(const Duration(seconds: 5), (count) {
      return List.generate(_games.length, (index) {
        return math.Random().nextInt(50) + 10;
      });
    }).listen((playerCounts) {
      if (mounted) {
        setState(() {
          for (int i = 0; i < _games.length; i++) {
            _games[i]['players'] = playerCounts[i];
          }
        });
      }
    });
  }

  void _navigateToGame(Map<String, dynamic> game) {
    HapticFeedback.mediumImpact();

    // Check if user has subscription for premium games
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData;
    final hasSubscription = userData?['subscription']?['active'] ?? false;

    // Some games might require subscription
    if (!hasSubscription && game['requiresSubscription'] == true) {
      _showSubscriptionDialog();
      return;
    }

    // Show coming soon dialog for now
    _showComingSoonDialog(game['name']);
  }

  void _showComingSoonDialog(String gameName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.construction,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Coming Soon!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.videogame_asset,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              gameName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dieses Spiel wird bald verfügbar sein!\n'
              'Wir arbeiten hart daran, dir die besten Spielerlebnisse zu bieten.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'Premium Spiel',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Dieses Spiel ist nur für Abo-Nutzer verfügbar. '
          'Hol dir jetzt dein Mukke-Abo für nur 9,99€/Monat!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Später'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Abo holen'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Stats
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Animated Background
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: SweepGradient(
                            center: Alignment.center,
                            colors: [
                              AppColors.primary.withOpacity(0.3),
                              AppColors.accent.withOpacity(0.3),
                              AppColors.primary.withOpacity(0.3),
                            ],
                            transform: GradientRotation(
                              _rotationController.value * 2 * math.pi,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),

                          // Title
                          const Text(
                            'Mukke Games',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Spiele mit Echtgeld & gewinne MukkeCoins!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stats Cards
                          if (!_isLoadingStats)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.monetization_on,
                                    label: 'MukkeCoins',
                                    value: _mukkeCoins.toString(),
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.emoji_events,
                                    label: 'Siege',
                                    value: _totalWins.toString(),
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.local_fire_department,
                                    label: 'Streak',
                                    value: _winStreak.toString(),
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Earnings Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _coinController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _coinController.value * 2 * math.pi,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.euro,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gesamtgewinn',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_totalEarnings.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/payout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Auszahlen'),
                  ),
                ],
              ),
            ),
          ),

          // Games Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final game = _games[index];
                  return _buildGameCard(game);
                },
                childCount: _games.length,
              ),
            ),
          ),

          // Leaderboard Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Top Spieler',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/leaderboard');
                        },
                        child: const Text(
                          'Alle anzeigen',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Top 3 Players
                  ..._topPlayers.take(3).map((player) {
                    final index = _topPlayers.indexOf(player);
                    return _buildLeaderboardItem(player, index + 1);
                  }),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    return GestureDetector(
      onTap: () => _navigateToGame(game),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: game['isLive'] ? 1.0 + (_pulseController.value * 0.02) : 1.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: game['gradient'],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        (game['gradient'] as List<Color>)[0].withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Live Indicator
                  if (game['isLive'])
                    Positioned(
                      top: 12,
                      right: 12,
                      child: AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(
                                    0.5 + (_glowController.value * 0.5),
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          game['icon'],
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          game['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          game['description'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        const Spacer(),

                        // Bet Info
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            game['fixedBet'] != null
                                ? '${game['fixedBet']}€'
                                : '${game['minBet']}€ - ${game['maxBet']}€',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Players Count
                        if (game['players'] > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${game['players']} spielen',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildLeaderboardItem(Map<String, dynamic> player, int rank) {
    Color medalColor = Colors.grey;
    if (rank == 1) medalColor = Colors.amber;
    if (rank == 2) medalColor = Colors.grey[300]!;
    if (rank == 3) medalColor = Colors.orange[700]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rank <= 3
                ? medalColor.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3
              ? medalColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? medalColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      Icons.emoji_events,
                      color: medalColor,
                      size: 24,
                    )
                  : Text(
                      rank.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${player['wins']} Siege',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Earnings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player['earnings'].toStringAsFixed(2)}€',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Gewinn',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
