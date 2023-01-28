import 'package:chat_ai/core/app_config.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository(Dio dio) : _dio = dio;

  Future<String> promptMessage(String prompt) async {
    try {
      const url = "https://api.openai.com/v1/completions";

      final response = await _dio.post(
        url,
        data: {
          'model': "text-davinci-003",
          'prompt': prompt,
          'temperature': 0.5,
          'max_tokens': 1000,
          'top_p': 1,
          'frequency_penalty': 0.2,
          'presence_penalty': 0.0,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.openApiKey}',
          },
        ),
      );

      return response.data['choices'][0]['text'];
    } on DioError catch (e) {
      return 'Ocorreu um erro! Tente novamente mais tarde.\n Cod-Erro: ${e.error}.\n Mensagem: ${e.message}';
    }
  }
}
