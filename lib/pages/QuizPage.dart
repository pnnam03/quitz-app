import 'package:flutter/material.dart';
import 'package:flutter_app/Question.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './ResultPage.dart';
import '../components/VisibilityButton.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswerSelected = false;
  bool isFinished = false;
  bool isLoadingQuestions = false;

  Map<int, Color> buttonColors = {}; // Map to store button colors
  List<Question> quizQuestions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    setState(() {
      isLoadingQuestions = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://the-trivia-api.com/v2/questions/'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        List<dynamic> results = jsonResponse;

        List<Question> questions = results.map((result) {
          String question = result['question']['text'];
          List<String> incorrectAnswers =
              List<String>.from(result['incorrectAnswers']);
          String correctAnswer = result['correctAnswer'];

          List<String> allAnswers = incorrectAnswers;
          allAnswers.add(correctAnswer);
          allAnswers.shuffle();

          print(correctAnswer);
          return Question(
            question: question,
            options: allAnswers,
            correctAnswerIndex: allAnswers.indexOf(correctAnswer),
          );
        }).toList();

        quizQuestions = questions;
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoadingQuestions = false;
      });
    }
  }

  void checkAnswer(int selectedAnswerIndex) {
    if (selectedAnswerIndex ==
        quizQuestions[currentQuestionIndex].correctAnswerIndex) {
      setState(() {
        score++;
      });
    }
  }

  void Function() selectAnswer(index) {
    return () {
      setState(() {
        isAnswerSelected = true;
        var correctAnswerIndex =
            quizQuestions[currentQuestionIndex].correctAnswerIndex;
        if (index == correctAnswerIndex) {
          buttonColors[index] = Colors.green;
        } else
          buttonColors[index] = Colors.red;
        buttonColors[correctAnswerIndex] = Colors.green;
      });
      checkAnswer(index);
    };
  }

  void nextQuestion() {
    setState(() {
      isAnswerSelected = false;
      buttonColors.clear();

      if (currentQuestionIndex < quizQuestions.length - 1) {
        currentQuestionIndex++;
      } else {
        isFinished = true;
        isAnswerSelected = true;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultPage(
                    score: score,
                    playAgain: playAgain,
                    totalQuestions: quizQuestions.length,
                  )),
        );
      }
    });
  }

  void playAgain() {
    quizQuestions.clear();
    fetchQuestions();
    currentQuestionIndex = 0;
    score = 0;
    isAnswerSelected = false;
    isFinished = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Center(
                child: isLoadingQuestions
                    ? CircularProgressIndicator()
                    : Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Text('Score: ',
                                          style: TextStyle(
                                            fontSize: 23,
                                          )),
                                      Text('$score',
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold))
                                    ])
                                  ],
                                ),
                                margin: EdgeInsets.fromLTRB(20, 20, 20, 10)),
                            Container(
                              height: 0.5,
                              color: Colors.white,
                              margin: EdgeInsets.fromLTRB(40, 0, 40, 10),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${currentQuestionIndex + 1}',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('/${quizQuestions.length}',
                                    style: TextStyle(fontSize: 20))
                              ],
                            ),
                            Container(
                                margin: EdgeInsets.fromLTRB(30, 30, 30, 50),
                                child: Text(
                                  quizQuestions[currentQuestionIndex].question,
                                  style: TextStyle(fontSize: 24.0),
                                )),
                            Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: quizQuestions[currentQuestionIndex]
                                    .options
                                    .length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                      // height: 50.0, // Set the desired height here
                                      margin:
                                          EdgeInsets.fromLTRB(20, 0, 20, 10),
                                      padding:
                                          EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      child: ElevatedButton(
                                          child: Text(
                                              quizQuestions[
                                                      currentQuestionIndex]
                                                  .options[index],
                                              style: TextStyle(fontSize: 18)),
                                          onPressed: isAnswerSelected
                                              ? null
                                              : selectAnswer(index),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                              (states) {
                                                return buttonColors[index] ??
                                                    Colors.blue;
                                              },
                                            ),
                                            padding: MaterialStateProperty.all<
                                                    EdgeInsetsGeometry>(
                                                EdgeInsets.symmetric(
                                              vertical: 20.0,
                                            ) // Adjust the padding as needed
                                                ),
                                          )));
                                },
                              ),
                            ),
                            Visibility(
                              visible: isAnswerSelected,
                              child: SizedBox(height: 40),
                            ),
                            VisibilityButton(
                              height: 30,
                              width: 100,
                              visible: isAnswerSelected && !isFinished,
                              onPressed: nextQuestion,
                              text: 'Next',
                              textStyle: TextStyle(fontSize: 18),
                              buttonStyle: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                          ]))));
  }
}
