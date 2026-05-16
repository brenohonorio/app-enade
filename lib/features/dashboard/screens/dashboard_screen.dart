import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/local_storage_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentXP = 0;
  final int _xpNextLevel = 2000;
  
  int _streakDays = 0; 
  final int _dailyXpGoal = 500;
  int _dailyXpEarned = 0; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userData = await LocalStorageService.getUserData();
    setState(() {
      _currentXP = userData['totalXp'];
      _dailyXpEarned = userData['dailyXp'];
      _streakDays = userData['streak'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _currentXP / _xpNextLevel;
    if (progress > 1.0) progress = 1.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Fundo Gradiente "Fade-Out"
          Container(
            height: MediaQuery.of(context).size.height * 0.70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryBlue,
                  Color(0x991C4ED8), // AppTheme.primaryBlue com 60% de opacidade
                  AppTheme.background,
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Conteúdo Principal
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Menu Superior Translúcido
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 64),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(30)),
                            alignment: Alignment.center,
                            child: const Text('Visão Geral', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Text('Conquistas', style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Texto Herói Central
                  Text(
                    '$_currentXP',
                    style: const TextStyle(fontSize: 84, fontWeight: FontWeight.w700, color: Colors.white, height: 1.0, letterSpacing: -2.0),
                  ),
                  const Text(
                    'Experiência (XP)',
                    style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 40),

                  // --- CARTÃO DE OFENSIVA ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildStreakCard(),
                  ),
                  const SizedBox(height: 32),

                  // Módulos de Estudo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Módulos de Estudo',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                        ),
                        const SizedBox(height: 16),

                        _buildModuleBlock(
                          context,
                          title: 'Simulado ENADE',
                          subtitle: 'Questões adaptativas',
                          value: '+100 XP',
                          icon: Icons.rocket_launch_rounded,
                          color: AppTheme.primaryBlue,
                          route: '/questions',
                        ),
                        const SizedBox(height: 16),

                        _buildModuleBlock(
                          context,
                          title: 'Revisão Rápida',
                          subtitle: 'Flashcards',
                          value: 'Revisar',
                          icon: Icons.style_rounded,
                          color: AppTheme.accent,
                          route: '/flashcards',
                        ),
                        const SizedBox(height: 40),
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

  // --- COMPONENTE DO STREAK INTEGRADO AO APPTHEME ---
  Widget _buildStreakCard() {
    double dailyProgress = _dailyXpEarned / _dailyXpGoal;
    if (dailyProgress > 1.0) dailyProgress = 1.0;
    int dailyPercent = (dailyProgress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark, // Azul Meia-Noite (Combinando perfeitamente com o app)
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryDark.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho: Fogo e Dias
          Row(
            children: [
              // Fogo com Glow Laranja do AppTheme
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.accent.withOpacity(0.5), blurRadius: 15, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: AppTheme.accent, size: 40),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OFENSIVA', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$_streakDays', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1)),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2.0),
                        child: Text('DIAS', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.track_changes_rounded, color: Colors.white54, size: 28),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 24),

          // Dias da Semana Dinâmicos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              int dayNumber = index + 1; // 1 = Seg, ..., 7 = Dom
              int currentWeekday = DateTime.now().weekday;
              
              int state = 0;
              if (dayNumber < currentWeekday) {
                state = (currentWeekday - dayNumber) <= _streakDays ? 2 : 0;
              } else if (dayNumber == currentWeekday) {
                state = _dailyXpEarned >= _dailyXpGoal ? 2 : 1;
              } else {
                state = 0; 
              }

              List<String> labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
              return _buildDayIndicator(labels[index], state);
            }),
          ),

          const SizedBox(height: 32),

          // Meta Diária
          const Text('META DIÁRIA DE XP', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$_dailyXpEarned', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.0)),
              Text(' / $_dailyXpGoal', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('$dailyPercent%', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          
          // Barra de Progresso com o Verde do nosso Tema
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: dailyProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.correctGreen,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: AppTheme.correctGreen.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 2))],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Construtor das bolinhas dos dias usando cores do AppTheme
  Widget _buildDayIndicator(String dayLabel, int state) {
    Color ringColor;
    Widget innerContent;

    if (state == 2) { // Concluído
      ringColor = AppTheme.correctGreen;
      innerContent = Container(
        decoration: const BoxDecoration(color: AppTheme.correctGreen, shape: BoxShape.circle),
       
        child: const Icon(Icons.check, color: Colors.white, size: 16), 
      );
    } else if (state == 1) { // Dia Atual (Marcado com laranja para destacar)
      ringColor = AppTheme.accent; 
      innerContent = Container(
        decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
      );
    } else { 
      ringColor = Colors.transparent;
      innerContent = Container(
        decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
      );
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: 2),
          ),
          child: innerContent,
        ),
        const SizedBox(height: 8),
        Text(dayLabel, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildModuleBlock(BuildContext context, {required String title, required String subtitle, required String value, required IconData icon, required Color color, required String route}) {
    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(context, route);
        _loadData();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.cardShadow),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 20, color: AppTheme.primaryDark.withOpacity(0.8), fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}