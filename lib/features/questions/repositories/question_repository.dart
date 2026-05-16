import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question_model.dart';

class QuestionRepository {
  // Agora a função é "Future" (assíncrona) porque buscar na internet leva alguns milissegundos
  static Future<List<EnadeQuestion>> getQuestions() async {
    final supabase = Supabase.instance.client;
    
    // Faz a consulta na tabela "questions" que acabamos de criar
    final List<dynamic> response = await supabase.from('questions').select();

    // Mapeia o JSON que vem da nuvem para o nosso modelo do Flutter
    return response.map((json) {
      return EnadeQuestion(
        id: json['id'].toString(),
        text: json['text'],
        options: List<String>.from(json['options']), // Converte o Array do Postgres para List do Dart
        correctOptionIndex: json['correct_option_index'],
        hints: List<String>.from(json['hints']),
      );
    }).toList();
  }
}