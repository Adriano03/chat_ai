import 'package:chat_ai/models/chat_model.dart';
import 'package:chat_ai/repositories/chat_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:type_text/type_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final scrollCtrl = ScrollController();

  bool loading = false;
  final inputCtrl = TextEditingController();
  final repository = ChatRepository(Dio());
  final messages = <ChatModel>[];
  final scaffoldKey = GlobalKey<ScaffoldState>();

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

  borderRadiusCirc(double topR, double topL) {
    return BorderRadius.only(
      topRight: Radius.circular(topR),
      topLeft: Radius.circular(topL),
      bottomRight: const Radius.circular(12),
      bottomLeft: const Radius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
                    final myMessage = messages[i].messageFrom == MessageFrom.me;
                    final msgLength = messages[i].message.length ~/ 28;
                    return Row(
                      children: [
                        if (myMessage) const Spacer(),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          width: MediaQuery.of(context).size.width * 0.88,
                          padding: myMessage
                              ? const EdgeInsets.all(12)
                              : const EdgeInsets.only(
                                  top: 0,
                                  left: 12,
                                  right: 12,
                                  bottom: 12,
                                ),
                          decoration: BoxDecoration(
                            borderRadius: myMessage
                                ? borderRadiusCirc(0, 12)
                                : borderRadiusCirc(12, 0),
                            color: myMessage
                                ? Colors.blueGrey.shade800
                                : Colors.grey.shade700,
                          ),
                          child: InkWell(
                            onLongPress: () {
                              Clipboard.setData(
                                ClipboardData(text: messages[i].message),
                              );
                            },
                            child: TypeText(
                              duration: myMessage
                                  ? const Duration(seconds: 0)
                                  : Duration(seconds: msgLength),
                              messages[i].message,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
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
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          height: 56,
                          width: 56,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 5,
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
