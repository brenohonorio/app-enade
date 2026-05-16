import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/local_storage_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  // Dados simulados para o MVP (depois podemos puxar do Supabase igual as questões!)
  final List<Map<String, String>> _flashcards = [
    {
      'front': 'O que é Overfitting em Machine Learning?',
      'back': 'Quando o modelo decora os dados de treino e perde a capacidade de generalizar para dados novos.',
    },
    {
      'front': 'O que significa a sigla ACID em Bancos de Dados?',
      'back': 'Atomicidade, Consistência, Isolamento e Durabilidade. Garantem transações seguras.',
    },
    {
      'front': 'Qual a diferença entre Listas e Tuplas em Python?',
      'back': 'Listas são mutáveis (podem ser alteradas). Tuplas são imutáveis (não podem ser alteradas após criadas).',
    },
  ];

  int _currentIndex = 0;
  bool _isFlipped = false;

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard(bool knewAnswer) async {
    // Se o usuário sabia a resposta, damos uma pequena recompensa de XP
    if (knewAnswer) {
      await LocalStorageService.addXP(20);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ótima memória! +20 XP', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.correctGreen,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }

    setState(() {
      _isFlipped = false;
      if (_currentIndex < _flashcards.length - 1) {
        _currentIndex++;
      } else {
        _flashcards.shuffle();
        _currentIndex = 0; // Recomeça o ciclo
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Cabeçalho Customizado
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text('REVISÃO RÁPIDA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(width: 48), // Espaçador para centralizar o título
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cartão ${_currentIndex + 1} de ${_flashcards.length}',
                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // O Cartão Animado
                  GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
                        return AnimatedBuilder(
                          animation: rotateAnim,
                          child: child,
                          builder: (context, widget) {
                            final isUnder = (ValueKey(_isFlipped) != widget!.key);
                            var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                            tilt *= isUnder ? -1.0 : 1.0;
                            final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
                            return Transform(
                              transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                              alignment: Alignment.center,
                              child: widget,
                            );
                          },
                        );
                      },
                      child: _isFlipped ? _buildBackCard() : _buildFrontCard(),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botões de Ação (Só aparecem se o cartão estiver virado)
                  AnimatedOpacity(
                    opacity: _isFlipped ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isFlipped ? () => _nextCard(false) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.wrongRed,
                              side: const BorderSide(color: AppTheme.wrongRed, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Errei', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isFlipped ? () => _nextCard(true) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.correctGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text('Acertei', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Lado da Pergunta
  Widget _buildFrontCard() {
    return Container(
      key: const ValueKey(false),
      height: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppTheme.descendingBlue,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.help_outline_rounded, color: Colors.white54, size: 48),
          const SizedBox(height: 24),
          Text(
            _flashcards[_currentIndex]['front']!,
            style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: const Text('Toque para virar', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Lado da Resposta
  Widget _buildBackCard() {
    return Container(
      key: const ValueKey(true),
      height: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 2),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppTheme.accent, size: 48),
          const SizedBox(height: 24),
          Text(
            _flashcards[_currentIndex]['back']!,
            style: const TextStyle(fontSize: 20, color: AppTheme.primaryDark, fontWeight: FontWeight.w500, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}