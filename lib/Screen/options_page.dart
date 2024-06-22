import 'package:flutter/material.dart';
import 'package:icte21_gpt_ocr/Screen/chat_docs_page.dart';
import 'package:icte21_gpt_ocr/Screen/chat_page.dart';

class OptionsPage extends StatefulWidget {
  final String scannedText;

  const OptionsPage({Key? key, required this.scannedText}) : super(key: key);

  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  String selectedAction = 'Summarise';
  TextEditingController freePromptController = TextEditingController();
  TextEditingController toneController = TextEditingController();
  TextEditingController writingStyleController = TextEditingController();
  TextEditingController outputLanguageController = TextEditingController();
  String requestText = "";
  String? _selectedOption;

  // ...
  List<String> writingStyles = [
    'Academic',
    'Analytical',
    'Argumentative',
    'Conversational',
    'Creative',
    'Critical',
    'Descriptive',
    'Epigrammatic',
    'Epistolary',
    'Expository',
    'Informative',
    'Instructive',
    'Journalistic',
    'Metaphorical',
    'Narrative',
    'Persuasive',
    'Poetic',
    'Satirical',
    'Technical'
  ];

  List<String> tones = [
    'Authoritative',
    'Clinical',
    'Cold',
    'Confident',
    'Cynical',
    'Emotional',
    'Encouraging',
    'Friendly',
    'Humorous',
    'Informal',
    'Ironic',
    'Optimistic',
    'Pessimistic',
    'Playful',
    'Sarcastic',
    'Serious',
    'Sympathetic'
  ];
  List<String> languages = [
    'English',
    'Chinese',
    'Spanish',
    'Hindi',
    'Arabic',
    'Bengali',
    'Portuguese',
    'Russian',
    'Japanese',
    'Punjabi',
    'German',
    'Javanese',
    'Korean',
    'French',
    'Telugu',
    'Marathi',
    'Turkish',
    'Tamil',
    'Vietnamese',
    'Urdu',
  ];

  String? selectedOutputLanguage;
  String? selectedWritingStyle;
  String? selectedTone;

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChatWindow(builtPrompt: requestText, keyToLoad: "")),
    );
  }

  void _navigateToDocs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChatDocsWindow(builtPrompt: requestText, keyToLoad: "")),
    );
  }

  String _buildPrompt() {
    String prompt = '';
    String tone = toneController.text.isNotEmpty
        ? ' with a ${toneController.text} tone'
        : '';
    String writingStyle = writingStyleController.text.isNotEmpty
        ? ' in a ${writingStyleController.text} writing style'
        : '';
    String outputLanguage = outputLanguageController.text.isNotEmpty
        ? ' and translate it to ${outputLanguageController.text}'
        : '';
    switch (selectedAction) {
      case 'Summarise':
        prompt = 'Summarise the following text:"${widget.scannedText}"';
        break;
      case 'Answer questions':
        prompt =
            'Answer the questions in the following text:"${widget.scannedText}"';
        break;
      case 'Free prompt':
        prompt =
            '${freePromptController.text}$tone$writingStyle$outputLanguage:"${widget.scannedText}"';
        break;
      case 'Clarify':
        prompt = 'Clarify the following text:"${widget.scannedText}"';
        break;
      case 'Exemplify':
        prompt = 'Exemplify the following text:"${widget.scannedText}"';
        break;
      case 'Expand':
        prompt = 'Expand the following text:"${widget.scannedText}"';
        break;
      case 'Explain':
        prompt = 'Explain the following text:"${widget.scannedText}"';
        break;
      case 'Rewrite':
        prompt = 'Rewrite the following text:"${widget.scannedText}"';
        break;
      case 'Shorten':
        prompt = 'Shorten the following text:"${widget.scannedText}"';
        break;
    }
    return prompt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select an Action"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_selectedOption == null) ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 16),
                    _styledButton(
                      onPressed: () {
                        setState(() {
                          _onOptionSelected('Simple request');
                        });
                      },
                      text: 'Simple request',
                    ),
                    SizedBox(height: 16),
                    _styledButton(
                      onPressed: () {
                        setState(() {
                          _onOptionSelected('Chat with your docs');
                        });
                      },
                      text: 'Chat with your docs',
                    ),
                  ],
                ),
              )
            ] else if (_selectedOption == 'Simple request') ...[
              const Text(
                "What would you like to do with the text?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedAction,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAction = newValue!;
                  });
                },
                items: <String>[
                  'Summarise',
                  'Answer questions',
                  'Free prompt',
                  'Clarify',
                  'Exemplify',
                  'Expand',
                  'Explain',
                  'Rewrite',
                  'Shorten'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (selectedAction == 'Free prompt') ...[
                const Text(
                  "Enter your prompt:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: freePromptController,
                  decoration: InputDecoration(
                    labelText: "Prompt",
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: toneController,
                  decoration: InputDecoration(
                    labelText: "Tone",
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: selectedTone,
                  hint: const Text("Select a tone"),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTone = newValue;
                      toneController.text = newValue!;
                    });
                  },
                  items: tones.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: writingStyleController,
                  decoration: InputDecoration(
                    labelText: "Writing Style",
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: selectedWritingStyle,
                  hint: const Text("Select a writing style"),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWritingStyle = newValue;
                      writingStyleController.text = newValue!;
                    });
                  },
                  items: writingStyles
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: selectedOutputLanguage,
                  hint: const Text("Select an output language"),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOutputLanguage = newValue;
                      outputLanguageController.text = newValue!;
                    });
                  },
                  items:
                      languages.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    requestText = _buildPrompt();
                    _navigateToChat(context);
                  },
                  child: const Text("Send"),
                ),
              ),
            ] else if (_selectedOption == 'Chat with your docs') ...[
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    requestText = widget.scannedText;
                    _navigateToDocs(context);
                  },
                  child: const Text("Chat with your docs"),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  void _onOptionSelected(String option) {
    setState(() {
      _selectedOption = option;
    });
    if (option == 'Chat with your docs') {
      requestText = widget.scannedText;
      _navigateToDocs(context);
    }
  }

  Widget _styledButton(
      {required VoidCallback onPressed, required String text}) {
    return Container(
      width: 220,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          textStyle: TextStyle(fontSize: 18),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
