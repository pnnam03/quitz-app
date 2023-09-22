import 'package:flutter/material.dart';
import '../components/VisibilityButton.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final Function? playAgain;
  final int totalQuestions;
  ResultPage(
      {this.playAgain, required this.score, required this.totalQuestions});

  Color? getColor() {
    if (score >= 3 * totalQuestions / 4) {
      return Colors.green;
    }
    if (score >= totalQuestions / 2) {
      return Colors.orange;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text('Quiz Complete!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 40),
              Text('$score/$totalQuestions',
                  style: TextStyle(
                    fontSize: 50,
                    color: getColor() ?? null, // ?? Colors.white,
                  )),
              SizedBox(height: 40),
              VisibilityButton(
                height: 30,
                onPressed: () {
                  Navigator.pop(context);
                  // if (playAgain != null)
                  playAgain!();
                },
                text: 'Play Again',
                width: 150,
                textStyle: TextStyle(fontSize: 18),
                buttonStyle: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                )),
              )
            ])));
  }
}
