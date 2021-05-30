import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hangman/welcome_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Hangman extends StatefulWidget {
  static const String id = 'hangman_screen';
  @override
  _HangmanState createState() => _HangmanState();
}

class _HangmanState extends State<Hangman> {
  static final maxGuesses = 2;

  static String characters = 'abcdefghijklmnopqrstuvwxyz';

  int _lives = 6;
  int _gamesWon = 0;
  int _totalGames = 0;
  String _currentWord = 'hangman';
  int _guessesLeft = maxGuesses;
  List<int> _calledLetters = [];
  List<String> englishWords = [];

  _HangmanState() {
    englishWords = new List.from(nouns);
    englishWords.removeWhere((String noun) {
      return noun.length <= maxGuesses + 1 ? true : false;
    });
  }

  bool isLost() {
    return _lives == 0 && !isWon();
  }

  bool isWon() {
    for (int id in getRemainingLetters()) {
      if (_currentWord.codeUnits.contains(id)) return false;
    }
    return true;
  }

  List<int> getRemainingLetters() {
    List<int> units = new List.from(_currentWord.codeUnits);
    units.removeWhere((int unit) {
      return _calledLetters.contains(unit) ? true : false;
    });
    return units;
  }

  String getNewWord() {
    final word =
        englishWords[Random().nextInt(englishWords.length)].toLowerCase();
    print(word);
    return word;
  }

  reset() {
    setState(() {
      _lives = 6;
      _currentWord = getNewWord();
      _guessesLeft = maxGuesses;
      _calledLetters = [];
    });
  }

  newRound(bool wonGame) {
    reset();
    setState(() {
      if (wonGame) _gamesWon++;
      _totalGames++;
    });
  }

  guessLetter(int codeUnit) {
    if (!getRemainingLetters().contains(codeUnit)) _lives--;
    setState(() {
      _calledLetters.add(codeUnit);
    });
    if (isLost() || isWon()) {
      Alert(
        context: context,
        type: isLost() ? AlertType.error : AlertType.success,
        title: isLost() ? 'Incorrect!' : "Correct!",
        desc: isLost() ? "The word was: $_currentWord" : 'Continue?',
        closeFunction: () {
          newRound(isWon());
        },
        buttons: [
          DialogButton(
            radius: BorderRadius.circular(10),
            child: Icon(
              MdiIcons.arrowRightThick,
              size: 30.0,
            ),
            onPressed: () {
              newRound(isWon());
              Navigator.of(context).pop();
            },
            width: 127,
            color: Theme.of(context).primaryColor,
            height: 52,
          )
        ],
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          if (_guessesLeft > 0)
            IconButton(
              icon: Icon(
                Icons.help_outline,
                color: Colors.white,
              ),
              onPressed: () {
                List<int> units = getRemainingLetters();
                if (units.length > 0) {
                  int pos = Random().nextInt(units.length);
                  guessLetter(units[pos]);
                  _guessesLeft--;
                }
              },
            ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 20,
              children: <Widget>[
                Container(
                  width: 100,
                  child: Image.asset(
                    'images/${6 - _lives}.png',
                    alignment: Alignment.center,
                  ),
                ),
                Container(
                  child: Wrap(
                      children: _currentWord.codeUnits.map((int charInt) {
                    if (_calledLetters.contains(charInt))
                      return Text(
                        '${String.fromCharCode(charInt)}',
                        style: TextStyle(fontSize: 24),
                      );
                    else
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '_',
                          style: TextStyle(fontSize: 24),
                        ),
                      );
                  }).toList()),
                ),
              ],
            ),
            Container(
              child: Wrap(
                direction: Axis.horizontal,
                spacing: 20,
                runSpacing: 10,
                children: characters.codeUnits.map((int codeUnit) {
                  return FlatButton(
                    onPressed: () {
                      if (!_calledLetters.contains(codeUnit))
                        guessLetter(codeUnit);
                    },
                    child: Text(
                      '${String.fromCharCode(codeUnit).toUpperCase()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    color: _calledLetters.contains(codeUnit)
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    newRound(isWon() ? true : false);
                  },
                  padding: EdgeInsets.all(10),
                  color: Colors.black,
                  child: Text(
                    'New Game',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () async {
                    Alert(
                      context: context,
                      type: AlertType.error,
                      title: "Quit??",
                      desc: 'Are you sure that you want to quit?',
                      buttons: [
                        DialogButton(
                          radius: BorderRadius.circular(10),
                          child: Icon(
                            MdiIcons.arrowRightThick,
                            size: 30.0,
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushNamed(context, WelcomeScreen.id);
                          },
                          width: 127,
                          color: Theme.of(context).primaryColor,
                          height: 52,
                        ),
                        DialogButton(
                          radius: BorderRadius.circular(10),
                          child: Icon(
                            MdiIcons.cancel,
                            size: 30.0,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          width: 127,
                          color: Theme.of(context).primaryColor,
                          height: 52,
                        )
                      ],
                    ).show();
                  },
                  padding: EdgeInsets.all(10),
                  color: Colors.black,
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Text('$_gamesWon Won / ${_totalGames - _gamesWon} Lost',style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    ),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
