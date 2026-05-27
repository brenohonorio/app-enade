import 'dart:async'; // Necessário para o Timer
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/local_storage_service.dart';
import '../models/question_model.dart';
import '../repositories/question_repository.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<EnadeQuestion> _questions = [];
  bool _isLoading = true; 
  
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  int _failedAttempts = 0;
  bool _isAnswerCorrect = false;
  bool _isQuestionLocked = false;
  int _currentXP = 0;

  // --- VARIÁVEIS DO CRONÔMETRO ---
  Timer? _timer;
  int _secondsRemaining = 3600; // 3600 segundos = 60 minutos

  @override
  void initState() {
    super.initState();
    _loadUserXP();
    _loadQuestionsFromCloud(); 
  }

  @override
  void dispose() {
    _timer?.cancel(); // Limpa o timer ao fechar a tela para não gastar memória
    super.dispose();
  }

  // --- LÓGICA DO TEMPORIZADOR ---
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _finishSimulation(); // Tempo esgotado
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadUserXP() async {
    final userData = await LocalStorageService.getUserData();
    setState(() { _currentXP = userData['totalXp']; });
  }

  Future<void> _loadQuestionsFromCloud() async {
    try {
      final questions = await QuestionRepository.getQuestions();
      questions.shuffle(); 
      
      setState(() {
        // PEGA APENAS AS 20 PRIMEIRAS APÓS EMBARALHAR
        _questions = questions.take(20).toList(); 
        _isLoading = false; 
      });

      // Inicia o tempo logo após carregar as questões
      _startTimer();

    } catch (e) {
      debugPrint('Erro ao buscar questões: $e');
    }
  }

  void _finishSimulation() {
    // Para o cronômetro se ainda estiver rodando
    _timer?.cancel(); 
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: AppTheme.accent, size: 32),
            SizedBox(width: 8),
            Text('Simulado Concluído!', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          _secondsRemaining <= 0 
            ? 'O tempo se esgotou! Excelente esforço. Volte amanhã para manter sua ofensiva.'
            : 'Você finalizou todas as 20 questões do simulado de hoje. Excelente esforço!',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o dialog
              Navigator.of(context).pop(); // Volta para o Dashboard
            },
            child: const Text('Voltar ao Início', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }

  void _nextQuestion() {
    setState(() {
      _selectedOptionIndex = null;
      _failedAttempts = 0;
      _isAnswerCorrect = false;
      _isQuestionLocked = false;
      
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        // Ao invés de zerar, finaliza o simulado
        _finishSimulation();
      }
    });
  }

  void _submitAnswer(int index) {
    if (_isQuestionLocked) return;

    setState(() {
      _selectedOptionIndex = index;
      final currentQ = _questions[_currentQuestionIndex];
      
      if (index == currentQ.correctOptionIndex) {
        _isAnswerCorrect = true;
        _isQuestionLocked = true;
        _currentXP += 100;
        
        LocalStorageService.addXP(100); 

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.all(8),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text('Brilhante! +100 XP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            backgroundColor: AppTheme.correctGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            padding: EdgeInsets.zero,
            duration: const Duration(seconds: 2),
            elevation: 10,
          ),
        );
      } else {
        _isAnswerCorrect = false;
        _failedAttempts++;
        if (_failedAttempts >= currentQ.hints.length) {
          _isQuestionLocked = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryBlue),
              const SizedBox(height: 16),
              Text('Baixando questões da nuvem...', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    final currentQ = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            decoration: const BoxDecoration(gradient: AppTheme.descendingBlue),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                // --- RELÓGIO ADICIONADO AQUI ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Text('SIMULADO  •  ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      Icon(Icons.timer_rounded, size: 16, color: _secondsRemaining <= 300 ? Colors.redAccent : Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_secondsRemaining), 
                        style: TextStyle(
                          color: _secondsRemaining <= 300 ? Colors.redAccent : Colors.white, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1.2
                        )
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(gradient: AppTheme.descendingOrange, borderRadius: BorderRadius.circular(12), boxShadow: AppTheme.cardShadow),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('$_currentXP', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
                    ],
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: AppTheme.primaryDark, borderRadius: BorderRadius.circular(10)),
                        child: Text('Questão ${_currentQuestionIndex + 1} de ${_questions.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.cardShadow),
                    child: Text(currentQ.text, style: const TextStyle(fontSize: 17, height: 1.6, color: AppTheme.primaryDark, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 32),
                  
                  ...List.generate(currentQ.options.length, (index) {
                    return _buildSolidOptionBlock(index, currentQ.options[index], currentQ);
                  }),

                  const SizedBox(height: 24),

                  if (_failedAttempts > 0 && !_isAnswerCorrect) _buildStructuredHints(currentQ),
                    
                  if (_isQuestionLocked) _buildFullFeedbackBlock(currentQ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolidOptionBlock(int index, String text, EnadeQuestion currentQ) {
    bool isSelected = _selectedOptionIndex == index;
    bool isCorrectOption = index == currentQ.correctOptionIndex;
    
    Color textColor = AppTheme.primaryDark;
    LinearGradient? blockGradient;
    Color blockColor = AppTheme.surface;
    Color letterBoxColor = AppTheme.background;
    Color letterColor = AppTheme.primaryDark;
    
    if (_isQuestionLocked) {
      if (isCorrectOption) {
        blockGradient = AppTheme.descendingGreen;
        textColor = Colors.white;
        letterBoxColor = Colors.white.withOpacity(0.2);
        letterColor = Colors.white;
      } else if (isSelected) {
        blockGradient = AppTheme.descendingRed;
        textColor = Colors.white;
        letterBoxColor = Colors.white.withOpacity(0.2);
        letterColor = Colors.white;
      }
    } else if (isSelected) {
      blockGradient = AppTheme.descendingBlue;
      textColor = Colors.white;
      letterBoxColor = Colors.white.withOpacity(0.2);
      letterColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _submitAnswer(index),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: blockGradient == null ? blockColor : null,
            gradient: blockGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? AppTheme.cardShadow : [],
            border: blockGradient == null ? Border.all(color: Colors.grey.shade300) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: letterBoxColor, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  String.fromCharCode(65 + index), 
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: letterColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(text, style: TextStyle(fontSize: 16, color: textColor, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStructuredHints(EnadeQuestion currentQ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(gradient: AppTheme.descendingOrange, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tips_and_updates_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('DICAS DESBLOQUEADAS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white, letterSpacing: 1.0)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _failedAttempts && i < currentQ.hints.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(currentQ.hints[i], style: const TextStyle(fontSize: 14, color: AppTheme.primaryDark, fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildFullFeedbackBlock(EnadeQuestion currentQ) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: _isAnswerCorrect ? AppTheme.correctGreen : AppTheme.primaryDark, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _isAnswerCorrect ? AppTheme.descendingGreen : AppTheme.descendingBlue,
              shape: BoxShape.circle
            ),
            child: Icon(
              _isAnswerCorrect ? Icons.verified_rounded : Icons.school_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
            child: Text(
              _isAnswerCorrect ? 'RESPOSTA EXATA' : 'TENTATIVAS ESGOTADAS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: _isAnswerCorrect ? AppTheme.correctGreen : AppTheme.primaryDark),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isAnswerCorrect ? 'Você dominou este conceito.' : 'A resposta correta era a ${String.fromCharCode(65 + currentQ.correctOptionIndex)}.',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: _nextQuestion,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(gradient: AppTheme.descendingBlue, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadow),
              alignment: Alignment.center,
              child: Text(
                _currentQuestionIndex < _questions.length - 1 ? 'AVANÇAR PARA A PRÓXIMA' : 'FINALIZAR SIMULADO', 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)
              ),
            ),
          )
        ],
      ),
    );
  }
}