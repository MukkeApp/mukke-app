import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class MukkeTrackingScreen extends StatefulWidget {
  const MukkeTrackingScreen({super.key});

  @override
  State<MukkeTrackingScreen> createState() => _MukkeTrackingScreenState();
}

class _MukkeTrackingScreenState extends State<MukkeTrackingScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _mapAnimationController;
  late Animation<double> _pulseAnimation;

  // State Variables
  bool _isAddingChild = false;
  final bool _showMap = false;
  String? _selectedChildId;

  // Form Controllers
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _childPhoneController = TextEditingController();
  final TextEditingController _childAgeController = TextEditingController();

  // Mock Data für verknüpfte Kinder
  final List<Map<String, dynamic>> _children = [
    {
      'id': '1',
      'name': 'Lena',
      'age': 12,
      'phone': '+49 151 12345678',
      'location': 'Schule',
      'address': 'Hauptstraße 15, Berlin',
      'battery': 85,
      'screenTime': '1h 20min',
      'screenTimeMinutes': 80,
      'lastSeen': '2 Min',
      'isOnline': true,
      'lat': 52.520008,
      'lng': 13.404954,
      'restrictions': {
        'maxScreenTime': 180, // Minuten
        'blockedApps': ['TikTok', 'Instagram'],
        'sleepTime': '21:00',
        'wakeTime': '07:00',
      },
      'todayApps': [
        {'name': 'WhatsApp', 'time': 25, 'icon': Icons.message},
        {'name': 'YouTube', 'time': 30, 'icon': Icons.play_circle},
        {'name': 'Spotify', 'time': 15, 'icon': Icons.music_note},
        {'name': 'Browser', 'time': 10, 'icon': Icons.language},
      ],
    },
    {
      'id': '2',
      'name': 'Max',
      'age': 10,
      'phone': '+49 151 87654321',
      'location': 'Zuhause',
      'address': 'Gartenweg 8, Berlin',
      'battery': 45,
      'screenTime': '45min',
      'screenTimeMinutes': 45,
      'lastSeen': '15 Min',
      'isOnline': true,
      'lat': 52.515008,
      'lng': 13.399954,
      'restrictions': {
        'maxScreenTime': 120,
        'blockedApps': ['YouTube'],
        'sleepTime': '20:00',
        'wakeTime': '06:30',
      },
      'todayApps': [
        {'name': 'Minecraft', 'time': 20, 'icon': Icons.games},
        {'name': 'WhatsApp', 'time': 15, 'icon': Icons.message},
        {'name': 'Kamera', 'time': 10, 'icon': Icons.camera_alt},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLocationUpdates();
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

    _mapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _startLocationUpdates() {
    // Simuliere Location Updates
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          for (var child in _children) {
            // Simuliere kleine Bewegungen
            child['lat'] += (Random().nextDouble() - 0.5) * 0.001;
            child['lng'] += (Random().nextDouble() - 0.5) * 0.001;
            child['lastSeen'] = '${Random().nextInt(5)} Min';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapAnimationController.dispose();
    _childNameController.dispose();
    _childPhoneController.dispose();
    _childAgeController.dispose();
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
            Icon(Icons.location_on, color: Color(0xFF00BFFF)),
            SizedBox(width: 8),
            Text(
              'Mukke Tracking',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotificationSettings,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: _isAddingChild ? _buildAddChildView() : _buildMainView(),
      floatingActionButton: !_isAddingChild
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isAddingChild = true;
                });
              },
              backgroundColor: const Color(0xFF00BFFF),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        _buildInfoBanner(),
        _buildQuickStats(),
        Expanded(
          child: _children.isEmpty ? _buildEmptyState() : _buildChildrenList(),
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
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield,
            color: Color(0xFF00BFFF),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Familienschutz aktiv',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_children.length} Kinder verknüpft • GPS aktiv • Notfall-System bereit',
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

  Widget _buildQuickStats() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Online',
              '${_children.where((c) => c['isOnline']).length}',
              Icons.wifi,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Bildschirmzeit',
              '${_calculateAverageScreenTime()}min',
              Icons.phone_android,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Batterie',
              '${_calculateAverageBattery()}%',
              Icons.battery_charging_full,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
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
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom,
            size: 80,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 20),
          Text(
            'Noch keine Kinder verknüpft',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Füge dein erstes Kind hinzu',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isAddingChild = true;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Kind hinzufügen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFFF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _children.length,
      itemBuilder: (context, index) {
        return _buildChildCard(_children[index]);
      },
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    final bool isOnline = child['isOnline'];
    final int battery = child['battery'];
    final bool lowBattery = battery < 20;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline
              ? const Color(0xFF00BFFF).withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showChildDetails(child),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00BFFF),
                          Color(0xFFFF1493),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        child['name'][0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              child['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: isOnline ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isOnline ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      color:
                                          isOnline ? Colors.green : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${child['age']} Jahre • ${child['phone']}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            lowBattery
                                ? Icons.battery_alert
                                : Icons.battery_full,
                            color: lowBattery ? Colors.red : Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$battery%',
                            style: TextStyle(
                              color: lowBattery ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'vor ${child['lastSeen']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFFF1493),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child['location'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            child['address'],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showMapView(child),
                      icon: const Icon(
                        Icons.map,
                        color: Color(0xFF00BFFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    Icons.phone,
                    'Anrufen',
                    () => _callChild(child),
                    Colors.green,
                  ),
                  _buildActionButton(
                    Icons.message,
                    'Nachricht',
                    () => _messageChild(child),
                    Colors.blue,
                  ),
                  _buildActionButton(
                    Icons.block,
                    'Sperren',
                    () => _lockDevice(child),
                    Colors.orange,
                  ),
                  _buildActionButton(
                    Icons.warning,
                    'Notfall',
                    () => _showEmergencyOptions(child),
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
    Color color,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddChildView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
                const Row(
                  children: [
                    Icon(Icons.person_add, color: Color(0xFF00BFFF)),
                    SizedBox(width: 8),
                    Text(
                      'Neues Kind hinzufügen',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _childNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    'Name des Kindes',
                    Icons.badge,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _childAgeController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: _buildInputDecoration(
                          'Alter',
                          Icons.cake,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _childPhoneController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration(
                          'Handynummer',
                          Icons.phone,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Wichtige Schritte',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                          '1', 'MukkeApp auf dem Kinderhandy installieren'),
                      _buildStep('2', 'Mit der Handynummer anmelden'),
                      _buildStep('3', 'Verknüpfungscode hier eingeben'),
                      _buildStep(
                          '4', 'Berechtigungen auf dem Kinderhandy erlauben'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingChild = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Abbrechen'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _addChild,
                  icon: const Icon(Icons.check),
                  label: const Text('Kind hinzufügen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: const Color(0xFFFF1493)),
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
        borderSide: const BorderSide(color: Color(0xFFFF1493), width: 2),
      ),
    );
  }

  void _showChildDetails(Map<String, dynamic> child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    _buildChildDetailHeader(child),
                    const TabBar(
                      indicatorColor: Color(0xFF00BFFF),
                      tabs: [
                        Tab(text: 'Übersicht'),
                        Tab(text: 'Bildschirmzeit'),
                        Tab(text: 'Einstellungen'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildOverviewTab(child),
                          _buildScreenTimeTab(child),
                          _buildSettingsTab(child),
                        ],
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

  Widget _buildChildDetailHeader(Map<String, dynamic> child) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00BFFF),
                  Color(0xFFFF1493),
                ],
              ),
            ),
            child: Center(
              child: Text(
                child['name'][0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${child['age']} Jahre',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editChild(child),
            icon: const Icon(Icons.edit, color: Color(0xFF00BFFF)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDetailCard(
            'Aktueller Standort',
            Icons.location_on,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child['location'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  child['address'],
                  style: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showMapView(child),
                  icon: const Icon(Icons.map),
                  label: const Text('Auf Karte anzeigen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFFF),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            'Gerätestatus',
            Icons.phone_android,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.battery_full,
                      color: child['battery'] > 20 ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${child['battery']}%',
                      style: TextStyle(
                        color:
                            child['battery'] > 20 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Batterie',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.wifi,
                      color: Colors.blue,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child['isOnline'] ? 'Verbunden' : 'Getrennt',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Internet',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.screen_lock_landscape,
                      color: Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child['screenTime'],
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Heute',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
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
  }

  Widget _buildScreenTimeTab(Map<String, dynamic> child) {
    final restrictions = child['restrictions'] as Map<String, dynamic>;
    final maxScreenTime = restrictions['maxScreenTime'] as int;
    final currentScreenTime = child['screenTimeMinutes'] as int;
    final percentage = (currentScreenTime / maxScreenTime * 100).clamp(0, 100);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bildschirmzeit heute',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      child['screenTime'],
                      style: const TextStyle(
                        color: Color(0xFF00BFFF),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 80 ? Colors.red : const Color(0xFF00BFFF),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentScreenTime von $maxScreenTime Minuten genutzt',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'App-Nutzung heute',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(child['todayApps'] as List).map((app) => _buildAppUsageItem(app)),
          const SizedBox(height: 24),
          _buildDetailCard(
            'Zeitbeschränkungen',
            Icons.schedule,
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Schlafenszeit',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      restrictions['sleepTime'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aufwachzeit',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      restrictions['wakeTime'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            'Blockierte Apps',
            Icons.block,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (restrictions['blockedApps'] as List).map<Widget>((app) {
                return Chip(
                  label: Text(
                    app,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red.withOpacity(0.2),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  deleteIconColor: Colors.red,
                  onDeleted: () => _removeBlockedApp(child, app),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppUsageItem(Map<String, dynamic> app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              app['icon'],
              color: const Color(0xFFFF1493),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              app['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            '${app['time']} min',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(Map<String, dynamic> child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSettingItem(
            'Standort-Genauigkeit',
            'Hohe Genauigkeit für präzise Ortung',
            Icons.my_location,
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF00BFFF),
            ),
          ),
          _buildSettingItem(
            'Bewegungsbenachrichtigungen',
            'Benachrichtigung bei Verlassen von Zonen',
            Icons.notifications_active,
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF00BFFF),
            ),
          ),
          _buildSettingItem(
            'SOS-Funktion',
            'Notfall-Button auf dem Kinderhandy',
            Icons.emergency,
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF00BFFF),
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailCard(
            'Sichere Zonen',
            Icons.shield,
            Column(
              children: [
                _buildZoneItem('Zuhause', 'Gartenweg 8, Berlin', true),
                _buildZoneItem('Schule', 'Hauptstraße 15, Berlin', true),
                _buildZoneItem('Oma & Opa', 'Lindenallee 23, Berlin', false),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addSafeZone,
                  icon: const Icon(Icons.add_location),
                  label: const Text('Zone hinzufügen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFFF),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _removeChild(child),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Kind entfernen'),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneItem(String name, String address, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.green.withOpacity(0.3) : Colors.grey[800]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: isActive ? Colors.green : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) {},
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    Widget trailing,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF1493), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF1493), size: 24),
              const SizedBox(width: 12),
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
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  // Helper Methods
  int _calculateAverageScreenTime() {
    if (_children.isEmpty) return 0;
    int total = 0;
    for (var child in _children) {
      total += child['screenTimeMinutes'] as int;
    }
    return (total / _children.length).round();
  }

  int _calculateAverageBattery() {
    if (_children.isEmpty) return 0;
    int total = 0;
    for (var child in _children) {
      total += child['battery'] as int;
    }
    return (total / _children.length).round();
  }

  // Action Methods
  void _showNotificationSettings() {
    // Implementierung für Benachrichtigungseinstellungen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Benachrichtigungseinstellungen'),
        backgroundColor: Color(0xFF00BFFF),
      ),
    );
  }

  void _showSettings() {
    // Implementierung für allgemeine Einstellungen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Einstellungen'),
        backgroundColor: Color(0xFF00BFFF),
      ),
    );
  }

  void _showMapView(Map<String, dynamic> child) {
    // Implementierung für Kartenansicht
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Zeige ${child['name']} auf der Karte'),
        backgroundColor: const Color(0xFF00BFFF),
      ),
    );
  }

  void _callChild(Map<String, dynamic> child) {
    // Implementierung für Anruf
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rufe ${child['name']} an...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _messageChild(Map<String, dynamic> child) {
    // Implementierung für Nachricht
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sende Nachricht an ${child['name']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _lockDevice(Map<String, dynamic> child) {
    // Implementierung für Gerätesperre
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Gerät sperren?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Möchten Sie das Gerät von ${child['name']} wirklich sperren?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gerät wurde gesperrt'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Sperren'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyOptions(Map<String, dynamic> child) {
    // Implementierung für Notfalloptionen
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D2D),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notfall-Optionen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.red),
              title: const Text(
                'Notfall-Anruf',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Sofort ${child['name']} anrufen',
                style: TextStyle(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _callChild(child);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.orange),
              title: const Text(
                'Standort teilen',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Aktuellen Standort senden',
                style: TextStyle(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Standort wurde geteilt'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.yellow),
              title: const Text(
                'Alarm auslösen',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Lauten Ton auf Kinderhandy abspielen',
                style: TextStyle(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alarm wurde ausgelöst'),
                    backgroundColor: Colors.yellow,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addChild() {
    if (_childNameController.text.isEmpty ||
        _childAgeController.text.isEmpty ||
        _childPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte alle Felder ausfüllen'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _children.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _childNameController.text,
        'age': int.parse(_childAgeController.text),
        'phone': _childPhoneController.text,
        'location': 'Zuhause',
        'address': 'Neue Adresse hinzufügen',
        'battery': 100,
        'screenTime': '0min',
        'screenTimeMinutes': 0,
        'lastSeen': 'Jetzt',
        'isOnline': true,
        'lat': 52.520008 + Random().nextDouble() * 0.01,
        'lng': 13.404954 + Random().nextDouble() * 0.01,
        'restrictions': {
          'maxScreenTime': 120,
          'blockedApps': [],
          'sleepTime': '20:00',
          'wakeTime': '07:00',
        },
        'todayApps': [],
      });

      _childNameController.clear();
      _childAgeController.clear();
      _childPhoneController.clear();
      _isAddingChild = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_childNameController.text} wurde hinzugefügt'),
        backgroundColor: const Color(0xFF00BFFF),
      ),
    );
  }

  void _editChild(Map<String, dynamic> child) {
    // Implementierung für Bearbeiten
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bearbeite ${child['name']}'),
        backgroundColor: const Color(0xFF00BFFF),
      ),
    );
  }

  void _removeChild(Map<String, dynamic> child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Kind entfernen?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Möchten Sie ${child['name']} wirklich entfernen?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _children.removeWhere((c) => c['id'] == child['id']);
              });
              Navigator.pop(context);
              Navigator.pop(context); // Schließe auch das Detail-Modal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${child['name']} wurde entfernt'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );
  }

  void _removeBlockedApp(Map<String, dynamic> child, String app) {
    setState(() {
      (child['restrictions']['blockedApps'] as List).remove(app);
    });
  }

  void _addSafeZone() {
    // Implementierung für sichere Zone hinzufügen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Neue sichere Zone hinzufügen'),
        backgroundColor: Color(0xFF00BFFF),
      ),
    );
  }
}
