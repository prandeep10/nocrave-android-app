import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  String _quitDateTime = DateTime.now().toString();
  String _cigarettesPerDay = "0";
  String _yearsOfSmoking = "0";
  String _pricePerCigarette = "10";

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  _saveOnboardingData() async {
    final path = await _getFilePath();
    final file = File('$path/onboarding_data.txt');
    String data = "Quit Date: $_quitDateTime\n"
        "Cigarettes Per Day: $_cigarettesPerDay\n"
        "Years of Smoking: $_yearsOfSmoking\n"
        "Price Per Cigarette: $_pricePerCigarette";
    file.writeAsString(data);
  }

  _onNext() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _saveOnboardingData();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: Text("Quit Date"),
        content: Column(
          children: [
            Text("When did you quit smoking?"),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: _quitDateTime),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _quitDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      ).toString();
                    });
                  }
                }
              },
              decoration: InputDecoration(
                labelText: "Quit Date",
                hintText: _quitDateTime,
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: Text("Cigarettes Per Day"),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _cigarettesPerDay = value;
          },
          decoration: InputDecoration(labelText: "Cigarettes Smoked Per Day"),
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: Text("Years of Smoking"),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _yearsOfSmoking = value;
          },
          decoration: InputDecoration(labelText: "Years of Smoking"),
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: Text("Price Per Cigarette"),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _pricePerCigarette = value;
          },
          decoration: InputDecoration(
            labelText: "Price Per Cigarette",
            hintText: "10",
          ),
        ),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onNext,
        steps: _getSteps(),
      ),
    );
  }
}
