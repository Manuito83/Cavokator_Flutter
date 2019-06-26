import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cavokator_flutter/condition/condition_decode.dart';

class MetarColorize {

  BuildContext myContext;

  TextSpan _colorizedResult;
  get getResult => _colorizedResult;

  // Wind Intensity
  int _regularWindIntensity = 20;
  int _badWindIntensity = 30;

  // Gust Intensity
  int _regularGustIntensity = 30;
  int _badGustIntensity = 40;

  // Wind Meters Per Second Intensity
  int _regularMpsWindIntensity = 10;
  int _badMpsWindIntensity = 15;

  // Wind Meters Per Second Gust
  int _regularMpsGustIntensity = 15;
  int _badMpsGustIntensity = 20;

  // Visibility
  int _regularVisibility = 6000;
  int _badVisibility = 1000;

  // RVR
  int _regularRvr = 1000;
  int _badRvr = 1500;

  List<String> goodWeather = [
    r"CAVOK",
    r"NOSIG",
    r"NSC",
    r"00000KT"
  ];

  List<String> regularWeather = [
    r"(VC)(?!PO|DS|SS)([A-Z]+)",
    r"^(?!\+)(SH|-SH)([A-Z]+)?",
    r"^(?!\+)(MI|-MI)([A-Z]+)?",
    r"^(?!\+)(BC|-BC)([A-Z]+)?",
    r"^(?!\+)(PR|-PR)([A-Z]+)?",
    r"^(?!\+)(DR|-DR)([A-Z]+)?",
    r"^(?!\+)(BL|-BL)([A-Z]+)?",
    r"^(?!\+)(TS|-TS)([A-Z]+)?",
    r"^(?!\+)(FZ|-FZ)([A-Z]+)?",
    r"^(?!\+)(DZ|-DZ)([A-Z]+)?",
    r"^(?!\+)(RA|-RA)([A-Z]+)?",
    r"^(?!\+)(SN|-SN)([A-Z]+)?",
    r"^(?!\+)(SG|-SG)([A-Z]+)?",
    r"^(?!\+)(PL|-PL)([A-Z]+)?",
    r"^(?!\+)(GR|-GR)([A-Z]+)?",
    r"^(?!\+)(GS|-GS)([A-Z]+)?",
    r"^(?!\+)(UP|-UP)([A-Z]+)?",
    r"^(?!\+)(SG|-SG)([A-Z]+)?",
    r"^(?!\+)(BR|-BR)([A-Z]+)?",
    r"^(?!\+)(FG|-FG)([A-Z]+)?",
    r"^(?!\+)(FU|-FU)([A-Z]+)?",
    r"^(?!\+)(VA|-VA)([A-Z]+)?",
    r"^(?!\+)(DU|-DU)([A-Z]+)?",
    r"^(?!\+)(SA|-SA)([A-Z]+)?",
    r"^(?!\+)(HZ|-HZ)([A-Z]+)?",
    r"OVC003",
    r"OVC004",
    r"OVC005",
    r"OVC006",
    r"OVC007",
    r"OVC008",
    r"BKN003",
    r"BKN004",
    r"BKN005",
    r"BKN006",
    r"BKN007",
    r"BKN008",
  ];


  List<String> badWeather = [
    r"^(\+)([A-Z]+)?",               // ANYTHING WITH A "+"
    r"BLSN",
    r"OVC001", "OVC002",             // Cloud cover
    r"BKN001", "BKN002",
    r"(\+)?(PO)",
    r"(\+)?(SQ)",
    r"(\+)?(FC)",
    r"(\+)?(SS)",
    r"(\+)?(\-)?(DS)(?![DSNT])",     // Trying to avoid american "distant" (DSNT)
    r"VCPO", r"VCSS", r"VCDS",
  ];


  MetarColorize ({@required String metar, @required BuildContext context}) {

    myContext = context;
    List<TextSpan> spanList = List<TextSpan>();
    var splitMetar = metar.split(" ");
    TextSpan thisSpan;

    for (var word in splitMetar){

      // CONDITION
      var conditionRegex = new RegExp(
          r"((\b)(R)+(\d\d([LCR]?)+(\/)+([0-9]|\/){6})(\b))"
          r"|((\b)(([0-9]|\/){8})+(\b))"
          r"|((\b)+(R\/SNOCLO)+(\b))"
          r"|((\b)+(R\d\d([LCR]?))+(\/)+(CLRD)+(\/\/))");
      var conditionRegexSevere = new RegExp(
          r"((\b)+(R\/SNOCLO)+(\b))");
      if (conditionRegex.hasMatch(word)){
        thisSpan = TextSpan(
          text: word,
          style: TextStyle(
            color: conditionRegexSevere.hasMatch(word)
                ? Colors.red : Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () {
            _conditionDialog(word);
          }
        );
        var spanSpace = TextSpan(
          text: " ",
        );
        spanList.add(thisSpan);
        spanList.add(spanSpace);
        continue;
      }

      // GOOD WEATHER
      String goodString = goodWeather.join("|");
      var goodRegex = new RegExp(goodString);
      if (goodRegex.hasMatch(word)){
        thisSpan = TextSpan(
          text: word + " ",
          style: TextStyle(color: Colors.green),
        );
        spanList.add(thisSpan);
        continue;
      }

      // REGULAR WEATHER
      String regularString = regularWeather.join("|");
      var regularRegex = new RegExp(regularString);
      if (regularRegex.hasMatch(word)){
        thisSpan = TextSpan(
            text: word + " ",
            style: TextStyle(color: Colors.orange),
        );
        spanList.add(thisSpan);
        continue;
      }

      // BAD WEATHER // TODO: IMPORTANT!!!
      String badString = badWeather.join("|");
      var badRegex = new RegExp(badString);
      if (badRegex.hasMatch(word)){
        thisSpan = TextSpan(
          text: word + " ",
          style: TextStyle(color: Colors.red),
        );
        spanList.add(thisSpan);
        continue;
      }

      // WIND KNOTS - e.g.: 25015KT
      var windRegex = new RegExp(
          r"\b[0-9]+KT");
      if (windRegex.hasMatch(word)){
        try {
          Color thisColor = Colors.black;
          int knots = int.tryParse(word.substring(3,5));
          if (knots >= _regularWindIntensity && knots <= _badWindIntensity) {
            thisColor = Colors.orange;
          } else if (knots > _badWindIntensity) {
            thisColor = Colors.red;
          }
          thisSpan = TextSpan(
              text: word + " ",
              style: TextStyle(color: thisColor));
        } catch (Exception) {
          // pass
        }
        spanList.add(thisSpan);
        continue;
      }

      // WIND KNOTS 2 - e.g.: 25015G34KT
      var wind2Regex = new RegExp(
          r"[0-9]+G[0-9]+KT");
      if (wind2Regex.hasMatch(word)){
        try {
          Color thisColor = Colors.black;
          int knots = int.tryParse(word.substring(3,5));
          int gust = int.tryParse(word.substring(6,8));
          if ((knots >= _regularWindIntensity || gust >= _regularGustIntensity)
              && knots <= _badWindIntensity && gust <= _badGustIntensity) {
            thisColor = Colors.orange;
          } else if (knots > _badWindIntensity || gust > _badGustIntensity) {
            thisColor = Colors.red;
          }
          thisSpan = TextSpan(
              text: word + " ",
              style: TextStyle(color: thisColor));
        } catch (Exception) {
          // pass
        }
        spanList.add(thisSpan);
        continue;
      }







      // STANDARD (NOTHING FOUND)
      thisSpan = TextSpan(
        text: word + " ",
        // This has to be here even with themes
        style: TextStyle(color: Colors.black),
      );
      spanList.add(thisSpan);
    }

    _colorizedResult = TextSpan (
      children: spanList,
    );
  }


  Future<void> _conditionDialog(String input) async {

    var condition = ConditionDecode(conditionString: input);
    ConditionModel decodedCondition = condition.getDecodedCondition;
    Widget myDecodedContainer = _decodedContainer(decodedCondition);

    return showDialog<void>(
      context: myContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(15,25,15,25),
              child: Column (
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    input,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                 myDecodedContainer,
                  RaisedButton(
                    child: Text(
                      'Roger!',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _decodedContainer(ConditionModel decodedCondition) {
    if (decodedCondition.error) {
      return Container(
        padding: EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("ERROR!"
                "\n\n"
                "Invalid runway condition.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    } else if (decodedCondition.isSnoclo) {
     return Container(
       padding: EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Text(
                "SNOCLO",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            Text(
              decodedCondition.snocloDecoded,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else if (decodedCondition.isClrd) {
      return Container(
        padding: EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    decodedCondition.rwyError ?
                    "(runway error)"
                        : "Runway ${decodedCondition.rwyValue}",
                    style: TextStyle(
                      fontSize: decodedCondition.rwyError ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: decodedCondition.rwyError ?
                      Colors.red : null,
                    ),
                  ),
                  Text(
                    " CLEARED",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              decodedCondition.clrdDecoded,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Runway
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.rwyCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.rwyDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Deposit type
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.depositCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.depositDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Extent
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.extentCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.extentDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Depth
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.depthCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.depthDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Runway
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.frictionCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.frictionDecoded,
                        style: TextStyle(
                          fontSize: 16,
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
  }

}