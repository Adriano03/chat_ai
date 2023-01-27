import 'package:chat_ai/models/chat_model.dart';
import 'package:chat_ai/repositories/chat_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final inputCtrl = TextEditingController();
  final repository = ChatRepository(Dio());
  final messages = <ChatModel>[];
  final scrollCtrl = ScrollController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    void scrollDown() {
      Future.delayed(
        const Duration(milliseconds: 200),
        () {
          scrollCtrl.animateTo(
            scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
      );
    }

    Future<void> submit() async {
      if (inputCtrl.text.isNotEmpty) {
        final prompt = inputCtrl.text;

        // Mensagem que eu mandei para a api;
        setState(() {
          messages.add(ChatModel(
            message: prompt,
            messageFrom: MessageFrom.me,
          ));
          inputCtrl.text = '';

          scrollDown();
          loading = true;
        });

        // Mensagem que eu recebi da api;
        final chatResponse = await repository.promptMessage(prompt);
        setState(() {
          messages.add(
            ChatModel(
              message: chatResponse,
              messageFrom: MessageFrom.bot,
            ),
          );
          scrollDown();
          loading = false;
        });
      }
    }

    var outlineBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.blueGrey,
      ),
      borderRadius: BorderRadius.circular(12),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox.expand(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    return Row(
                      children: [
                        if (messages[i].messageFrom == MessageFrom.me)
                          const Spacer(),
                        Container(
                          margin: const EdgeInsets.all(12),
                          width: MediaQuery.of(context).size.width * 0.7,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade700,
                          ),
                          child: Text(
                            messages[i].message,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                maxLines: 4,
                minLines: 1,
                controller: inputCtrl,
                decoration: InputDecoration(
                  hintText: 'Digite Aqui...',
                  enabledBorder: outlineBorder,
                  focusedBorder: outlineBorder,
                  suffixIcon: loading
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: submit,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
