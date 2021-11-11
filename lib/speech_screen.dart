import 'dart:collection';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

const textStyle2 = const TextStyle(
  //Creating new text style and font
  fontSize: 24.0,
  color: Colors.black87,
  fontWeight: FontWeight.w400,
);

Widget getTextandHighlight(String text, String language,
    LinkedHashMap<String, HighlightedWord> highlight) {
  return Padding(
    padding: const EdgeInsets.all(12.0), //Distance between the widgets
    child: Container(
      child: Column(
        //Creating column to have many childrens
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language),
          Divider(),
          text != null &&
                  text.isEmpty //Ternary If to create a Flexible if text is empty
              ? Container()
              : Flexible(
                  child: SingleChildScrollView(
                    //You can scrool the pages using this Widget
                    child: TextHighlight(
                      text: text,
                      words: highlight,
                      textStyle: textStyle2, //Text style function
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
        ],
      ),
    ),
  );
}

class SpeechScreen extends StatefulWidget {
  //Creates a new page which containes state
  @override //Using override to create a new widget to use new state widget
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  var language1 = 'tr';
  var language2 = 'en';
  var text_lang1 = "Türkçe";
  var text_lang2 = "English";
  var speak_trans1 = 'tr-TR';
  var speak_trans2 = 'en-US';

  int paramater = 0;
  GoogleTranslator translator =
      GoogleTranslator(); //Creating variables to use in this classes
  FlutterTts FlutterTts_app = FlutterTts();
  final Map<String, HighlightedWord> _highlights = {};
  stt.SpeechToText _speech;
  String _translation;
  bool _isListening = false, _speechAvailable = false;
  String _text = 'Konuşmak İçin Butona Basınız'; //Empty box message
  @override
  void initState() {
    //Init state to use in stateful widget
    super.initState();
    _speech = stt.SpeechToText();

    //Defining speech to text
    _translation = ""; //Translation if it's empty
    _speech.initialize(onStatus: (val) {
      setState(() {
        _isListening = val ==
            'listening'; //Depending to listening or notListening situation
      });
      print('onStatus: $val');
    }, onError: (val) {
      setState(() {
        _isListening = false; //Set state
      });
      print('onError: $val');
    }).then((value) => _speechAvailable = value);
  }

  @override
  Widget build(BuildContext context) {
    //Creates 2 widget to write english and turkish parts
    return Scaffold(
      //Scaffold of the ship. Building the entire widget around this sacffold
      appBar: AppBar(
        title: Text('Google Çeviri'), //Appbar title and entire thing
        actions: [
          IconButton(
              onPressed: () => setState(() {
                    //Refresh button
                    _text = 'Konuşmak İçin Butona Basınız';
                    _translation = '';
                  }),
              icon: Icon(Icons.refresh))
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, //Locatin of the Mic button
      floatingActionButton: AvatarGlow(
        // Design of the action button
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 40.0,
        duration:
            const Duration(milliseconds: 2000), //Animate of the action button
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          //Creating the action button
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none), //Animate
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //Creating column to create many childrens in this widget
        Expanded(
            flex: 11, //Using flex to set the screen
            child: getTextandHighlight(_text, text_lang2, _highlights)),
        Divider(
          thickness: 2.0,
        ),
        Expanded(
            flex: 10,
            child: getTextandHighlight(_translation, text_lang1, _highlights)),
        Container(
          child: IconButton(
            //Creating Icon Button
            //Speak Button
            onPressed: _speak,
            icon: Icon(Icons.volume_up_rounded),
            iconSize: 35,
            color: Colors.black,
            tooltip: 'Listen',
            alignment: Alignment.centerLeft,
            //Giving some distances between edge of the screen and the widgets
          ),
        ),
        Container(
            child: IconButton(
          icon: Icon(Icons.swap_calls),
          iconSize: 35,
          color: Colors.black,
          onPressed: _swap,
        )),
      ]),
    );
  }

  void _listen() async {
    //Create async function to listen, speak and translate
    if (!_isListening) {
      if (_speechAvailable) {
        setState(() => _isListening = true); //Listen and translate
        _speech.listen(
          localeId: speak_trans2,
          onResult: (val) async {
            var translatedText =
                await _translate(val.recognizedWords); //Recognize words
            setState(() {
              _text = val.recognizedWords;
              _translation = translatedText; //Translate
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false); //Set listening state
      _speech.stop();
    }
  }

  Future<String> _translate(String text) async {
    //Translating function
    if (text != null && text.isNotEmpty) {
      //Text might be empty while talking
      var translated =
          await translator.translate(text, from: language2, to: language1);
      return translated.text;
    }
    return "";
  }

  void _speak() async {
    //Speking function
    //Choosing Language
    FlutterTts_app.setLanguage(speak_trans1);
    FlutterTts_app.setPitch(1); //Setting Pitch
    await FlutterTts_app.speak(_translation);
  }

  void _swap() async {
    setState(() {
      var temp = language1;
      language1 = language2;
      language2 = temp;

      var temp2 = text_lang1;
      text_lang1 = text_lang2;
      text_lang2 = temp2;

      var temp3 = speak_trans1;
      speak_trans1 = speak_trans2;
      speak_trans2 = temp3;
    });
  }
}
