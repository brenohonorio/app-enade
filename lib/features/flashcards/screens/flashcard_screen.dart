import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/local_storage_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _flashcards = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _correctCount = 0;
  int _wrongCount = 0;

  late AnimationController _progressAnimController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnim =
        Tween<double>(begin: 0, end: 0).animate(_progressAnimController);
    _loadFlashcards();
  }

  @override
  void dispose() {
    _progressAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    try {
      final response =
          await Supabase.instance.client.from('flashcards').select();
      setState(() {
        if (response != null && (response as List).isNotEmpty) {
          _flashcards = List<dynamic>.from(response);
          _flashcards.shuffle();
          _currentIndex = 0;
        }
        _isLoading = false;
      });
      _animateProgress(0);
    } catch (e) {
      debugPrint('Erro ao buscar flashcards: $e');
      setState(() => _isLoading = false);
    }
  }

  void _animateProgress(double target) {
    final oldValue = _progressAnim.value;
    _progressAnim =
        Tween<double>(begin: oldValue, end: target).animate(
      CurvedAnimation(
          parent: _progressAnimController, curve: Curves.easeInOut),
    );
    _progressAnimController.forward(from: 0);
  }

  void _flipCard() {
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard(bool knewAnswer) async {
    if (knewAnswer) {
      await LocalStorageService.addXP(20);
      setState(() => _correctCount++);
    } else {
      setState(() => _wrongCount++);
    }

    setState(() {
      _isFlipped = false;
      if (_flashcards.isNotEmpty &&
          _currentIndex < _flashcards.length - 1) {
        _currentIndex++;
      } else if (_flashcards.isNotEmpty) {
        _currentIndex = 0;
        _flashcards.shuffle();
        _correctCount = 0;
        _wrongCount = 0;
      }
    });

    final progress =
        _flashcards.isNotEmpty ? (_currentIndex + 1) / _flashcards.length : 0.0;
    _animateProgress(progress);
  }

  String get _currentCategory {
    if (_flashcards.isEmpty) return '';
    return _flashcards[_currentIndex]['category'] ?? 'Geral';
  }

  Color _categoryColor(String category) {
    final map = {
      'Algoritmos': const Color(0xFF6C63FF),
      'Banco de Dados': const Color(0xFF00B4D8),
      'Redes': const Color(0xFF06D6A0),
      'SO': const Color(0xFFFFB703),
      'Engenharia': const Color(0xFFEF476F),
      'IA/ML': const Color(0xFF8338EC),
      'Programação': const Color(0xFF3A86FF),
      'Segurança': const Color(0xFFFF6B35),
    };
    return map[category] ?? AppTheme.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    if (_flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sentiment_dissatisfied_rounded,
                  size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Nenhum flashcard disponível.',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar')),
            ],
          ),
        ),
      );
    }

    final total = _flashcards.length;
    final current = _currentIndex + 1;
    final catColor = _categoryColor(_currentCategory);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),
            decoration:
                const BoxDecoration(gradient: AppTheme.descendingBlue),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'REVISÃO RÁPIDA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // Placar
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Color(0xFF4ADE80), size: 16),
                        const SizedBox(width: 4),
                        Text('$_correctCount',
                            style: const TextStyle(
                                color: Color(0xFF4ADE80),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        const Icon(Icons.cancel_outlined,
                            color: Color(0xFFFF6B6B), size: 16),
                        const SizedBox(width: 4),
                        Text('$_wrongCount',
                            style: const TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Barra de progresso
                Row(
                  children: [
                    Text(
                      'Cartão $current de $total',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${((current / total) * 100).round()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _progressAnim.value,
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4ADE80)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Badge de categoria
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: catColor.withOpacity(0.5), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.label_outline,
                                size: 14, color: catColor),
                            const SizedBox(width: 6),
                            Text(
                              _currentCategory,
                              style: TextStyle(
                                color: catColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card com flip
                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        transitionBuilder: (child, anim) {
                          final rotateAnim =
                              Tween(begin: pi, end: 0.0).animate(anim);
                          return AnimatedBuilder(
                            animation: rotateAnim,
                            child: child,
                            builder: (context, widget) {
                              final isUnder =
                                  (ValueKey(_isFlipped) != widget!.key);
                              var tilt =
                                  ((anim.value - 0.5).abs() - 0.5) * 0.003;
                              tilt *= isUnder ? -1.0 : 1.0;
                              final value = isUnder
                                  ? min(rotateAnim.value, pi / 2)
                                  : rotateAnim.value;
                              return Transform(
                                transform: Matrix4.rotationY(value)
                                  ..setEntry(3, 0, tilt),
                                alignment: Alignment.center,
                                child: widget,
                              );
                            },
                          );
                        },
                        child:
                            _isFlipped ? _buildBackCard() : _buildFrontCard(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dica de toque (visível antes de virar)
                  AnimatedOpacity(
                    opacity: _isFlipped ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.touch_app_outlined,
                            size: 16, color: Colors.black38),
                        SizedBox(width: 6),
                        Text(
                          'Toque no cartão para revelar',
                          style: TextStyle(
                              color: Colors.black38,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botões de resposta
                  AnimatedOpacity(
                    opacity: _isFlipped ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'Errei',
                            const Color(0xFFFF6B6B),
                            Icons.close_rounded,
                            () => _nextCard(false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            'Acertei',
                            const Color(0xFF4ADE80),
                            Icons.check_rounded,
                            () => _nextCard(true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: _isFlipped ? onPressed : null,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.descendingBlue,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            _flashcards[_currentIndex]['front_text'],
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Toque para virar',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: Color(0xFFFF9800), size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            _flashcards[_currentIndex]['back_text'],
            style: const TextStyle(
              fontSize: 17,
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.thumb_up_alt_outlined,
                  size: 14, color: Colors.black38),
              SizedBox(width: 6),
              Text(
                'Sabia a resposta?',
                style: TextStyle(color: Colors.black38, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}