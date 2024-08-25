import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
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
              "About NoCrave",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00BF63),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "NoCrave is designed to help you quit smoking by tracking your progress and providing you with valuable statistics and motivational insights. Our goal is to make your journey to a smoke-free life as smooth and informed as possible.",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              "Calculations Used in NoCrave",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00BF63),
              ),
            ),
            SizedBox(height: 10),
            _buildCalculationExplanation(
              "Number of Cigarettes Smoked:",
              "This is calculated based on the number of cigarettes you smoked per day multiplied by the total number of days you smoked before quitting.",
            ),
            _buildCalculationExplanation(
              "Money Wasted:",
              "This is calculated by multiplying the total number of cigarettes smoked by the price per cigarette.",
            ),
            _buildCalculationExplanation(
              "Life Lost:",
              "This is calculated based on the assumption that each cigarette smoked reduces life expectancy by 11 minutes. The total life lost is calculated by multiplying the total number of cigarettes smoked by 11 and then converting the result into hours.",
            ),
            _buildCalculationExplanation(
              "Money Saved:",
              "This is calculated based on the number of cigarettes you have avoided since quitting multiplied by the price per cigarette.",
            ),
            _buildCalculationExplanation(
              "Life Gained:",
              "This is calculated based on the assumption that avoiding each cigarette gains you 11 minutes of life. The total life gained is calculated by multiplying the number of cigarettes not smoked by 11 and then converting the result into hours.",
            ),
            SizedBox(height: 20),
            Text(
              "Privacy and Data Usage",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00BF63),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Your privacy is our top priority. NoCrave does not collect any of your personal data. The app operates entirely offline, so you don't need to worry about your data being transmitted over the internet. All your progress and statistics are stored locally on your device.",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "Because NoCrave does not require an internet connection, you can be assured that your data remains private and secure on your device. Enjoy the peace of mind that comes with using an app that respects your privacy.",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationExplanation(String title, String explanation) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            explanation,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
