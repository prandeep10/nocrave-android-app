import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late TextEditingController _quitDateController;
  late TextEditingController _cigarettesPerDayController;
  late TextEditingController _yearsOfSmokingController;
  late TextEditingController _pricePerCigaretteController;
  DateTime? _selectedDate;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _quitDateController = TextEditingController();
    _cigarettesPerDayController = TextEditingController();
    _yearsOfSmokingController = TextEditingController();
    _pricePerCigaretteController = TextEditingController();
    _loadOnboardingData();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleDailyNotifications() async {
    tz.initializeTimeZones();
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Congratulations!',
        'You have successfully completed another day!',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
            android: AndroidNotificationDetails('daily notification channel id',
                'daily notification channel name',
                channelDescription: 'daily notification description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _loadOnboardingData() async {
    try {
      final path = await _getFilePath();
      final file = File('$path/onboarding_data.txt');
      String contents = await file.readAsString();

      List<String> lines = contents.split('\n');
      _quitDateController.text = lines[0].split(': ')[1];
      _cigarettesPerDayController.text = lines[1].split(': ')[1];
      _yearsOfSmokingController.text = lines[2].split(': ')[1];
      _pricePerCigaretteController.text = lines[3].split(': ')[1];
    } catch (e) {
      print("Error reading file: $e");
    }
  }

  Future<void> _saveOnboardingData() async {
    final path = await _getFilePath();
    final file = File('$path/onboarding_data.txt');
    String data = "Quit Date: ${_quitDateController.text}\n"
        "Cigarettes Per Day: ${_cigarettesPerDayController.text}\n"
        "Years of Smoking: ${_yearsOfSmokingController.text}\n"
        "Price Per Cigarette: ${_pricePerCigaretteController.text}";
    await file.writeAsString(data);
    _scheduleDailyNotifications();
  }

  @override
  void dispose() {
    _quitDateController.dispose();
    _cigarettesPerDayController.dispose();
    _yearsOfSmokingController.dispose();
    _pricePerCigaretteController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _quitDateController.text = _selectedDate.toString();
        });
      }
    }
  }

  void _sendFeedback() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'prandeep.freelance@gmail.com',
      query: 'subject=App Feedback&body=Your feedback here',
    );
    final url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _shareApp() {
    Share.share(
        'Check out NoCrave app to help you quit smoking: https://drive.google.com/drive/folders/168rICzQhBP9XxeziwAnzkUTEjUFg0HyW?usp=sharing');
  }

  void _openMoreApps() async {
    const url = 'https://prandeep.site/apps';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _openPrivacyPolicy() async {
    const url = 'https://prandeep.site/nocrave-privacy-policy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account Details',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00BF63),
              ),
            ),
            TextField(
              controller: _quitDateController,
              decoration: InputDecoration(
                labelText: "Quit Date",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDateTime(context);
                  },
                ),
              ),
              readOnly: true,
            ),
            TextField(
              controller: _cigarettesPerDayController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Cigarettes Per Day"),
            ),
            TextField(
              controller: _yearsOfSmokingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Years of Smoking"),
            ),
            TextField(
              controller: _pricePerCigaretteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Price Per Cigarette",
                hintText: "10",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveOnboardingData();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Data updated successfully!'),
                ));
              },
              child: Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00BF63),
              ),
            ),
            Divider(height: 40),
            _buildOptionRow(
              Icons.feedback,
              "Send Feedback",
              _sendFeedback,
            ),
            _buildOptionRow(
              Icons.apps,
              "More Apps",
              _openMoreApps,
            ),
            _buildOptionRow(
              Icons.share,
              "Share App",
              _shareApp,
            ),
            _buildOptionRow(
              Icons.privacy_tip,
              "Privacy Policy",
              _openPrivacyPolicy,
            ),
            SizedBox(height: 20),
            _buildSupportDeveloperSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF00BF63)),
      title: Text(
        title,
        style: TextStyle(fontSize: 18),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSupportDeveloperSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support the Developer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00BF63),
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Image.asset(
                'assets/qr.jpg',
                height: 350,
                width: 350,
              ),
              SizedBox(height: 10),
              Text(
                'Your support can help us bring this app to the Play Store and make a positive impact on society. Thank you for your contribution! \n For any feedback contact at prandeep.freelance@gmail.com',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
