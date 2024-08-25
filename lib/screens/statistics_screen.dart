import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _quitDate = "";
  int _cigarettesPerDay = 0;
  int _yearsOfSmoking = 0;
  double _pricePerCigarette = 10;
  int _totalCigarettesSmoked = 0;
  double _totalMoneyWasted = 0;
  double _totalLifeLostInMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadOnboardingData();
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
      setState(() {
        _quitDate = lines[0].split(": ")[1];
        _cigarettesPerDay = int.parse(lines[1].split(": ")[1]);
        _yearsOfSmoking = int.parse(lines[2].split(": ")[1]);
        _pricePerCigarette = double.parse(lines[3].split(": ")[1]);
      });
      _calculateStatistics();
    }
  }

  void _calculateStatistics() {
    setState(() {
      _totalCigarettesSmoked = (_yearsOfSmoking * 365 +
              DateTime.now().difference(DateTime.parse(_quitDate)).inDays) *
          _cigarettesPerDay;
      _totalMoneyWasted = _totalCigarettesSmoked * _pricePerCigarette;
      _totalLifeLostInMinutes =
          _totalCigarettesSmoked * 11; // assuming 11 minutes per cigarette
    });
  }

  String _formatLifeLost(double totalMinutes) {
    if (totalMinutes < 1440) {
      return "${(totalMinutes / 60).toStringAsFixed(2)} hours";
    } else {
      final days = (totalMinutes / 1440).floor();
      final hours = ((totalMinutes % 1440) / 60).toStringAsFixed(2);
      return "$days days and $hours hours";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "During the period you smoked:",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BF63)),
            ),
            SizedBox(height: 10),
            Text(
              "Explanation: Based on your smoking history",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            _buildStatisticRow(
              "Number of Cigarettes Smoked",
              "$_totalCigarettesSmoked",
              Icons.smoking_rooms,
            ),
            _buildStatisticRow(
              "Money Wasted",
              "₹${_totalMoneyWasted.toStringAsFixed(2)}",
              Icons.money_off,
            ),
            _buildStatisticRow(
              "Life Lost",
              _formatLifeLost(_totalLifeLostInMinutes),
              Icons.sentiment_very_dissatisfied,
            ),
            SizedBox(height: 30),
            Text(
              "What you will get:",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BF63)),
            ),
            SizedBox(height: 20),
            _buildFutureBenefitsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value, IconData icon) {
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

  Widget _buildFutureBenefitsTable() {
    final benefits = [
      [
        "1 Week",
        _calculateMoneySaved(7).toStringAsFixed(2),
        _calculateLifeGained(7).toStringAsFixed(2)
      ],
      [
        "1 Month",
        _calculateMoneySaved(30).toStringAsFixed(2),
        _calculateLifeGained(30).toStringAsFixed(2)
      ],
      [
        "1 Year",
        _calculateMoneySaved(365).toStringAsFixed(2),
        _calculateLifeGained(365).toStringAsFixed(2)
      ],
      [
        "5 Years",
        _calculateMoneySaved(365 * 5).toStringAsFixed(2),
        _calculateLifeGained(365 * 5).toStringAsFixed(2)
      ],
      [
        "10 Years",
        _calculateMoneySaved(365 * 10).toStringAsFixed(2),
        _calculateLifeGained(365 * 10).toStringAsFixed(2)
      ],
      [
        "20 Years",
        _calculateMoneySaved(365 * 20).toStringAsFixed(2),
        _calculateLifeGained(365 * 20).toStringAsFixed(2)
      ],
    ];

    return Table(
      border: TableBorder.all(color: Color(0xFF00BF63), width: 2),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Color(0xFF00BF63),
          ),
          children: [
            _buildTableCell("Time Period", isHeader: true),
            _buildTableCell("Money Saved", isHeader: true),
            _buildTableCell("Life Gained", isHeader: true),
          ],
        ),
        for (var benefit in benefits)
          TableRow(
            children: [
              _buildTableCell(benefit[0]),
              _buildTableCell("₹${benefit[1]}"),
              _buildTableCell(_formatLifeLost(double.parse(benefit[2]) * 60)),
            ],
          ),
      ],
    );
  }

  Widget _buildTableCell(String value, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        value,
        style: TextStyle(
          fontSize: isHeader ? 18 : 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  double _calculateMoneySaved(int days) {
    return days * _cigarettesPerDay * _pricePerCigarette;
  }

  double _calculateLifeGained(int days) {
    return days *
        _cigarettesPerDay *
        11 /
        60; // assuming 11 minutes per cigarette
  }
}
