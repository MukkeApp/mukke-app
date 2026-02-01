import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MukkeRealChallengeScreen extends StatefulWidget {
  const MukkeRealChallengeScreen({super.key});

  @override
  State<MukkeRealChallengeScreen> createState() => _MukkeRealChallengeScreenState();
}

class _MukkeRealChallengeScreenState extends State<MukkeRealChallengeScreen> 
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Tab Controller
  late TabController _tabController;
  
  // State Variables
  bool _isCreatingChallenge = false;
  
  // Challenge Creation Controllers
  final TextEditingController _challengeTitleController = TextEditingController();
  final TextEditingController _challengeDescriptionController = TextEditingController();
  final TextEditingController _challengeAmountController = TextEditingController();
  int _challengeDurationMinutes = 5;
  
  // Mock Data für offene Challenges
  final List<Map<String, dynamic>> _openChallenges = [
    {
      'id': '1',
      'title': '50 Liegestütze in 2 Minuten',
      'description': 'Schaffe 50 saubere Liegestütze in nur 2 Minuten!',
      'amount': 25.00,
      'duration': 2,
      'creator': 'FitnessMike',
      'participants': 127,
      'locked': false,
    },
    {
      'id': '2',
      'title': 'Eiskalte Dusche für 3 Minuten',
      'description': 'Halte 3 Minuten unter eiskaltem Wasser durch!',
      'amount': 50.00,
      'duration': 3,
      'creator': 'CrazyChallenger',
      'participants': 89,
      'locked': false,
    },
    {
      'id': '3',
      'title': '1km Sprint unter 4 Minuten',
      'description': 'Laufe 1 Kilometer in weniger als 4 Minuten!',
      'amount': 100.00,
      'duration': 4,
      'creator': 'SpeedRunner',
      'participants': 234,
      'locked': true,
      'lockedBy': 'FastMax',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    _challengeTitleController.dispose();
    _challengeDescriptionController.dispose();
    _challengeAmountController.dispose();
    super.dispose();
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
            Icon(Icons.flash_on, color: Color(0xFFFF1493)),
            SizedBox(width: 8),
            Text(
              'Mukke Real Challenge',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00BFFF),
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.play_circle_outline),
              text: 'Offene Challenges',
            ),
            Tab(
              icon: Icon(Icons.add_circle_outline),
              text: 'Challenge erstellen',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOpenChallengesTab(),
          _buildCreateChallengeTab(),
        ],
      ),
    );
  }
  
  Widget _buildOpenChallengesTab() {
    return Column(
      children: [
        _buildInfoBanner(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _openChallenges.length,
            itemBuilder: (context, index) {
              return _buildChallengeCard(_openChallenges[index]);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BFFF).withOpacity(0.2),
            const Color(0xFFFF1493).withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF00BFFF),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Challenges mit echtem Geld!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '20% Boss-Anteil • 5 Bestätigungen nötig • Live-Übertragung',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    final bool isLocked = challenge['locked'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLocked 
            ? Colors.orange.withOpacity(0.5)
            : const Color(0xFF00BFFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isLocked ? null : () => _showChallengeDetails(challenge),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'von ${challenge['creator']}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00BFFF),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${challenge['amount'].toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Color(0xFF00BFFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                challenge['description'],
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge['duration']} Min.',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.remove_red_eye,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge['participants']} Zuschauer',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            challenge['lockedBy'],
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCreateChallengeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepCard(
            1,
            'Challenge Details',
            Icons.edit,
            Column(
              children: [
                TextField(
                  controller: _challengeTitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Challenge Titel *',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'z.B. "100 Burpees in 5 Minuten"',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(
                      Icons.title,
                      color: Color(0xFFFF1493),
                    ),
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
                      borderSide: const BorderSide(
                        color: Color(0xFFFF1493),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _challengeDescriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Beschreibung *',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'Erkläre genau, was zu tun ist...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Icon(
                        Icons.description,
                        color: Color(0xFFFF1493),
                      ),
                    ),
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
                      borderSide: const BorderSide(
                        color: Color(0xFFFF1493),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStepCard(
            2,
            'Zeit & Betrag',
            Icons.euro,
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _challengeAmountController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Betrag in € *',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          hintText: 'Min. 5€',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: const Icon(
                            Icons.euro,
                            color: Color(0xFF00BFFF),
                          ),
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
                            borderSide: const BorderSide(
                              color: Color(0xFF00BFFF),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zeitlimit',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$_challengeDurationMinutes Min.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (_challengeDurationMinutes > 1) {
                                          setState(() {
                                            _challengeDurationMinutes--;
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Color(0xFF00BFFF),
                                      ),
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        if (_challengeDurationMinutes < 30) {
                                          setState(() {
                                            _challengeDurationMinutes++;
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Color(0xFF00BFFF),
                                      ),
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Gebührenübersicht',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFeeRow(
                        'Dein Betrag:',
                        _calculateAmount(),
                        Colors.white,
                      ),
                      _buildFeeRow(
                        'Boss-Anteil (20%):',
                        _calculateBossFee(),
                        Colors.orange,
                      ),
                      const Divider(color: Colors.orange),
                      _buildFeeRow(
                        'Gewinner erhält:',
                        _calculateWinnerAmount(),
                        Colors.green,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStepCard(
            3,
            'Zahlungsmethode',
            Icons.payment,
            Column(
              children: [
                _buildPaymentOption(
                  'PayPal',
                  Icons.payment,
                  const Color(0xFF00457C),
                  true,
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  'Klarna',
                  Icons.shopping_bag,
                  const Color(0xFFFFB3C7),
                  false,
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  'Google Pay',
                  Icons.g_mobiledata,
                  const Color(0xFF4285F4),
                  false,
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  'Kreditkarte',
                  Icons.credit_card,
                  Colors.grey[700]!,
                  false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1493), Color(0xFF00BFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1493).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _createChallenge,
                icon: const Icon(Icons.rocket_launch, size: 28),
                label: const Text(
                  'Challenge erstellen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildStepCard(
    int step,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      color: Color(0xFF00BFFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: const Color(0xFFFF1493)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }
  
  Widget _buildPaymentOption(
    String name,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Colors.grey[700]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color)
            : null,
        onTap: () {
          // TODO: Payment method selection
        },
      ),
    );
  }
  
  Widget _buildFeeRow(String label, String amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  String _calculateAmount() {
    final amount = double.tryParse(_challengeAmountController.text) ?? 0;
    return '${amount.toStringAsFixed(2)} €';
  }
  
  String _calculateBossFee() {
    final amount = double.tryParse(_challengeAmountController.text) ?? 0;
    final fee = amount * 0.2;
    return '${fee.toStringAsFixed(2)} €';
  }
  
  String _calculateWinnerAmount() {
    final amount = double.tryParse(_challengeAmountController.text) ?? 0;
    final winnerAmount = amount * 0.8;
    return '${winnerAmount.toStringAsFixed(2)} €';
  }
  
  void _showChallengeDetails(Map<String, dynamic> challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildChallengeDetailsSheet(challenge),
    );
  }
  
  Widget _buildChallengeDetailsSheet(Map<String, dynamic> challenge) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF00BFFF),
                                child: Text(
                                  challenge['creator'][0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                challenge['creator'],
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFFF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF00BFFF),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Preisgeld',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${challenge['amount'].toStringAsFixed(2)} €',
                            style: const TextStyle(
                              color: Color(0xFF00BFFF),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aufgabenbeschreibung',
                        style: TextStyle(
                          color: Color(0xFFFF1493),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        challenge['description'],
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        Icons.timer,
                        'Zeitlimit',
                        '${challenge['duration']} Minuten',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(
                        Icons.remove_red_eye,
                        'Zuschauer',
                        '${challenge['participants']}',
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Wichtige Hinweise',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• 5 Nutzer müssen bestätigen\n• Live-Übertragung erforderlich\n• Kein Betrug oder KI wird überwacht',
                              style: TextStyle(
                                color: Colors.red[300],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Abbrechen',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF1493), Color(0xFF00BFFF)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF1493).withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptChallenge(challenge),
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        'Challenge annehmen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
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
  
  Widget _buildDetailCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  void _acceptChallenge(Map<String, dynamic> challenge) {
    Navigator.pop(context);
    _showCountdownDialog(challenge);
  }
  
  void _showCountdownDialog(Map<String, dynamic> challenge) {
    int countdown = 10;
    Timer? countdownTimer;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            countdownTimer ??= Timer.periodic(
                const Duration(seconds: 1),
                (timer) {
                  setState(() {
                    countdown--;
                  });
                  if (countdown == 0) {
                    timer.cancel();
                    Navigator.pop(context);
                    _startLiveChallenge(challenge);
                  }
                },
              );
            
            return AlertDialog(
              backgroundColor: const Color(0xFF2D2D2D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SizedBox(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Color(0xFFFF1493),
                      size: 60,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kamera öffnet in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00BFFF),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            '$countdown',
                            key: ValueKey(countdown),
                            style: const TextStyle(
                              color: Color(0xFF00BFFF),
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bereite dich vor!',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      countdownTimer?.cancel();
    });
  }
  
  void _startLiveChallenge(Map<String, dynamic> challenge) {
    // TODO: Kamera öffnen und Live-Stream starten
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.live_tv, color: Colors.white),
            SizedBox(width: 12),
            Text('Live-Challenge gestartet!'),
          ],
        ),
        backgroundColor: const Color(0xFFFF1493),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    
    // Ping an alle Nutzer senden
    _sendNotificationToAllUsers(challenge);
  }
  
  void _sendNotificationToAllUsers(Map<String, dynamic> challenge) {
    // TODO: Push-Notification an alle Nutzer
    debugPrint('Notification sent: ${challenge['title']} wurde gestartet!');
  }
  
  void _createChallenge() {
    if (_challengeTitleController.text.isEmpty ||
        _challengeDescriptionController.text.isEmpty ||
        _challengeAmountController.text.isEmpty) {
      _showSnackBar('Bitte fülle alle Pflichtfelder aus');
      return;
    }
    
    final amount = double.tryParse(_challengeAmountController.text) ?? 0;
    if (amount < 5) {
      _showSnackBar('Mindestbetrag ist 5€');
      return;
    }
    
    _showPaymentConfirmationDialog();
  }
  
  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.payment, color: Color(0xFF00BFFF)),
            SizedBox(width: 12),
            Text(
              'Zahlung bestätigen',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Möchtest du jetzt verbindlich deinen Betrag einzahlen?',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildConfirmationRow('Challenge:', _challengeTitleController.text),
                  const SizedBox(height: 8),
                  _buildConfirmationRow('Betrag:', _calculateAmount()),
                  const SizedBox(height: 8),
                  _buildConfirmationRow('Gebühr:', _calculateBossFee()),
                  const Divider(color: Colors.grey),
                  _buildConfirmationRow(
                    'Gesamt:',
                    _calculateAmount(),
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Abbrechen',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ja, zahlen'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfirmationRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFF00BFFF) : Colors.white,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  void _processPayment() {
    // TODO: PayPal Integration
    setState(() {
      _isCreatingChallenge = true;
    });
    
    // Simulierte Zahlung
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isCreatingChallenge = false;
      });
      _showSuccessDialog();
    });
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.green, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Challenge erstellt!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Deine Challenge ist jetzt für alle sichtbar',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
                _tabController.animateTo(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text('Zur Übersicht'),
            ),
          ),
        ],
      ),
    );
  }
  
  void _resetForm() {
    _challengeTitleController.clear();
    _challengeDescriptionController.clear();
    _challengeAmountController.clear();
    setState(() {
      _challengeDurationMinutes = 5;
    });
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
}