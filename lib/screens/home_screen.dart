import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _quitDate = "";
  int _cigarettesPerDay = 0;
  int _yearsOfSmoking = 0;
  double _pricePerCigarette = 10;
  Duration _timeSmokeFree = Duration();
  double _moneySaved = 0;
  double _lifeRegained = 0;
  int _cigarettesNotSmoked = 0;
  List<String> _quotes = [
    "It takes 21 days to form a habit",
    "It takes 90 days to create a lifestyle",
    "Every cigarette not smoked is a victory",
    "You're doing amazing, keep it up",
    "Health is the greatest wealth",
  ];
  String _currentQuote = "";
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _loadOnboardingData();
    _setRandomQuote();
    Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (_isMounted) {
        _updateTimeSmokeFree();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _loadOnboardingData() async {
    final path = await _getFilePath();
    final file = File('$path/onboarding_data.txt');
    if (await file.exists()) {
      final lines = await file.readAsLines();
      if (lines.length >= 4) {
        if (_isMounted) {
          setState(() {
            _quitDate = lines[0].split(": ")[1];
            _cigarettesPerDay = int.parse(lines[1].split(": ")[1]);
            _yearsOfSmoking = int.parse(lines[2].split(": ")[1]);
            _pricePerCigarette = double.parse(lines[3].split(": ")[1]);
          });
          _updateTimeSmokeFree();
        }
      }
    }
  }

  void _updateTimeSmokeFree() {
    if (_quitDate.isEmpty) return;
    try {
      final quitDate = DateTime.parse(_quitDate);
      if (_isMounted) {
        setState(() {
          _timeSmokeFree = DateTime.now().difference(quitDate);
          _cigarettesNotSmoked =
              (_timeSmokeFree.inDays * _cigarettesPerDay).toInt();
          _moneySaved = _cigarettesNotSmoked * _pricePerCigarette;
          _lifeRegained = _cigarettesNotSmoked *
              11 /
              60; // assuming 11 minutes per cigarette
        });
      }
    } catch (e) {
      print("Error parsing date: $e");
    }
  }

  void _setRandomQuote() {
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _quotes.length;
    if (_isMounted) {
      setState(() {
        _currentQuote = _quotes[randomIndex];
      });
    }
  }

  int _currentMilestoneDays() {
    if (_timeSmokeFree.inDays >= 21 && _timeSmokeFree.inDays < 90) {
      return 90;
    } else if (_timeSmokeFree.inDays >= 90 && _timeSmokeFree.inDays < 365) {
      return 365;
    } else if (_timeSmokeFree.inDays >= 365 && _timeSmokeFree.inDays < 1825) {
      return 1825; // 5 years
    } else {
      return 21; // default milestone
    }
  }

  double _calculatePercentage() {
    if (_quitDate.isEmpty) return 0.0;
    try {
      final quitDate = DateTime.parse(_quitDate);
      final daysPassed = DateTime.now().difference(quitDate).inDays;
      final milestoneDays = _currentMilestoneDays();
      return (daysPassed / milestoneDays) * 100;
    } catch (e) {
      print("Error parsing date: $e");
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BF63), Color(0xFF26E1D8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Day ${_timeSmokeFree.inDays} / ${_currentMilestoneDays()}",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00BF63),
              ),
            ),
            SizedBox(height: 20),
            CircularPercentIndicator(
              radius: 150,
              lineWidth: 15,
              percent: _calculatePercentage() / 100,
              center: Text(
                "${_calculatePercentage().toStringAsFixed(1)}%",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              progressColor: Color(0xFF00BF63),
              backgroundColor: Color(0xFFE0E0E0),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  _currentQuote,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 30),
            _buildInfoRow(Icons.smoke_free, "Smoke Free",
                "${_timeSmokeFree.inDays} Days ${_timeSmokeFree.inHours % 24} Hours ${_timeSmokeFree.inMinutes % 60} Minutes ${_timeSmokeFree.inSeconds % 60} Seconds"),
            _buildInfoRow(Icons.attach_money, "Money Saved",
                "₹${_moneySaved.toStringAsFixed(2)}"),
            _buildInfoRow(Icons.health_and_safety, "Life Regained",
                "${_lifeRegained.toStringAsFixed(2)} hours"),
            _buildInfoRow(
                Icons.cancel, "Cigarettes Not Smoked", "$_cigarettesNotSmoked"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF00BF63), size: 40),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(value, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
