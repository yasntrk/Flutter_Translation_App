import 'dart:collection';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

const textStyle2 = const TextStyle(
  fontSize: 24.0,
  color: Colors.black87,
  fontWeight: FontWeight.w400,
);

Widget getCustomTextHighlight(String text, String language,
    LinkedHashMap<String, HighlightedWord> highlight) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Text(language),
          Divider(),
          text != null && text.isEmpty
              ? Container()
              : Flexible(
                  child: SingleChildScrollView(
                    child: TextHighlight(
                      text: text,
                      words: highlight,
                      textStyle: textStyle2,
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
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  GoogleTranslator translator = GoogleTranslator();
  FlutterTts FlutterTts_app = FlutterTts();
  final Map<String, HighlightedWord> _highlights = {};
  stt.SpeechToText _speech;
  String _translation;
  bool _isListening = false, _speechAvailable = false;
  String _text = 'Konuşmak İçin Butona Basınız';
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _translation = "";

    _speech.initialize(onStatus: (val) {
      setState(() {
        _isListening = val == 'listening';
      });
      print('onStatus: $val');
    }, onError: (val) {
      setState(() {
        _isListening = false;
      });
      print('onError: $val');
    }).then((value) => _speechAvailable = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Çeviri'),
        actions: [
          IconButton(
              onPressed: () => setState(() {
                    _text = 'Konuşmak İçin Butona Basınız';
                    _translation = '';
                  }),
              icon: Icon(Icons.refresh))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 40.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 10,
            child: getCustomTextHighlight(_text, 'English', _highlights)),
        Divider(
          thickness: 2.0,
        ),
        Expanded(
            flex: 10,
            child: getCustomTextHighlight(_translation, 'Türkçe', _highlights)),
        Container(
          child: IconButton(
            onPressed: _speak,
            icon: Icon(Icons.volume_up_rounded),
            iconSize: 50,
            color: Colors.black,
            tooltip: 'Listen',
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.fromLTRB(10, 0, 0, 30),
          ),
        )
      ]),
    );
  }

  void _listen() async {
    if (!_isListening) {
      if (_speechAvailable) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            var translatedText = await _translate(val.recognizedWords);
            setState(() {
              _text = val.recognizedWords;
              _translation = translatedText;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<String> _translate(String text) async {
    if (text != null && text.isNotEmpty) {
      var translated = await translator.translate(text, to: 'tr');
      return translated.text;
    }
    return "";
  }

  void _speak() async {
    await FlutterTts_app.setLanguage('tr-TR');
    await FlutterTts_app.setPitch(1);
    await FlutterTts_app.speak(_translation);
  }
}
