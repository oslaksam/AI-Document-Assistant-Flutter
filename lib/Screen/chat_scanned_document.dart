import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icte21_gpt_ocr/Screen/chat_docs_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ChatScannedDocumentPage extends StatefulWidget {
  const ChatScannedDocumentPage({Key? key}) : super(key: key);

  @override
  _ChatScannedDocumentPageState createState() =>
      _ChatScannedDocumentPageState();
}

class _ChatScannedDocumentPageState extends State<ChatScannedDocumentPage> {
  late Future<List<Map<String, dynamic>>> _documentsFuture;

  //late Future<void> _documentsFuture;
  late TextEditingController _metadataController;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final _future = Supabase.instance.client
      .from('documents')
      .select<List<Map<String, dynamic>>>();

  @override
  void initState() {
    super.initState();
    _metadataController = TextEditingController();
    _documentsFuture = _fetchDocuments();
  }

  void _showErrorSnackBar(String errorMessage) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDocuments() async {
    debugPrint("Fetching documents.");

    try {
      final userId = supabase.auth.currentUser!.id;
      debugPrint(userId);
      if (userId == null) {
        debugPrint('User not found. Please log in again.');
        supabase.auth.refreshSession();
        _showErrorSnackBar('User not found. Please log in again.');
        return [];
      }

      final response =
          await supabase.from('documents').select().eq('user_id', userId);

      if (response == null) {
        debugPrint('Found no scanned documents.');
        _showErrorSnackBar('Found no scanned documents.');
        return [];
      }

      if (response.error != null) {
        debugPrint('Error fetching documents: ${response.error!.message}');
        _showErrorSnackBar(
            'Error fetching documents: ${response.error!.message}');
        return [];
      }

      debugPrint(response.data);
      return response.data as List<Map<String, dynamic>>;
    } catch (e) {
      _showErrorSnackBar('Exeption caught. Please log out and log in again.');
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat with Scanned Document'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (/*snapshot.connectionState != ConnectionState.done ||*/
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final documents = snapshot.data!;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: ((context, index) {
                final document = documents[index];
                return ListTile(
                  title: Text("DocId: " +
                      document['id'].toString() +
                      "Metadata: " +
                      document['metadata']),
                  onTap: () {
                    int docIdFromDatabase = document['id'];
                    _navigateToDocs(context, docIdFromDatabase);
                  },
                );
              }),
            );
          },
        ),
      ),
    );
  }

// Add docIdFromDatabase parameter to the _navigateToDocs method
  void _navigateToDocs(BuildContext context, int docIdFromDatabase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDocsWindow(
          builtPrompt: "",
          keyToLoad: "",
          documentId: docIdFromDatabase,
        ),
      ),
    );
  }
}
