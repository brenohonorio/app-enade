import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/local_storage_service.dart';
 
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
 
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
 
class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentXP = 0;
  final int _xpNextLevel = 2000;
  int _streakDays = 0;
  final int _dailyXpGoal = 5000;
  int _dailyXpEarned = 0;
 
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
 
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _loadData();
  }
 
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
 
  Future<void> _loadData() async {
    final userData = await LocalStorageService.getUserData();
    setState(() {
      _currentXP = userData['totalXp'];
      _dailyXpEarned = userData['dailyXp'];
      _streakDays = userData['streak'];
    });
    _animController.forward(from: 0);
  }
 
  int get _level => (_currentXP / _xpNextLevel).floor() + 1;
  double get _levelProgress =>
      ((_currentXP % _xpNextLevel) / _xpNextLevel).clamp(0.0, 1.0);
  int get _xpIntoLevel => _currentXP % _xpNextLevel;
 
  @override
  Widget build(BuildContext context) {
    double dailyProgress = (_dailyXpEarned / _dailyXpGoal).clamp(0.0, 1.0);
    int dailyPercent = (dailyProgress * 100).toInt();
 
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.descendingBlue),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar + saudação
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greetingText(),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Estudante ENADE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Badge de nível
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.accent.withOpacity(0.4),
                                  width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.military_tech_rounded,
                                    color: AppTheme.accent, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Nível $_level',
                                  style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
 
                    const SizedBox(height: 28),
 
                    // ── XP HERO ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$_currentXP',
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.0,
                                    letterSpacing: -2,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 10, left: 8),
                                  child: Text(
                                    'XP total',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Barra nível
                            Row(
                              children: [
                                Text(
                                  'Nível $_level',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                                const Spacer(),
                                Text(
                                  '$_xpIntoLevel / $_xpNextLevel XP',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '→ Nível ${_level + 1}',
                                  style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _levelProgress,
                                minHeight: 8,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.accent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
 
                    const SizedBox(height: 16),
 
                    // ── STATS RÁPIDOS ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatChip(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: AppTheme.accent,
                              label: 'Ofensiva',
                              value: '$_streakDays dias',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatChip(
                              icon: Icons.today_rounded,
                              iconColor: const Color(0xFF4ADE80),
                              label: 'Meta diária',
                              value: '$dailyPercent%',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatChip(
                              icon: Icons.workspace_premium_rounded,
                              iconColor: const Color(0xFFFBBF24),
                              label: 'Nível',
                              value: '$_level',
                            ),
                          ),
                        ],
                      ),
                    ),
 
                    const SizedBox(height: 24),
 
                    // ── CARTÃO DE OFENSIVA ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildStreakCard(dailyProgress, dailyPercent),
                    ),
 
                    const SizedBox(height: 28),
 
                    // ── MÓDULOS ───────────────────────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Módulos de Estudo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
 
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildModuleBlock(
                            context,
                            title: 'Simulado ENADE',
                            subtitle: '20 questões • 60 minutos',
                            badge: '+100 XP',
                            icon: Icons.rocket_launch_rounded,
                            gradientColors: [
                              const Color(0xFF1C4ED8),
                              const Color(0xFF3B82F6)
                            ],
                            route: '/questions',
                          ),
                          const SizedBox(height: 14),
                          _buildModuleBlock(
                            context,
                            title: 'Revisão Rápida',
                            subtitle: 'Flashcards • +20 XP cada',
                            badge: 'Revisar',
                            icon: Icons.style_rounded,
                            gradientColors: [
                              AppTheme.accentDark,
                              AppTheme.accent
                            ],
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
          ),
        ),
      ),
    );
  }
 
  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia 👋';
    if (hour < 18) return 'Boa tarde 👋';
    return 'Boa noite 👋';
  }
 
  Widget _buildStatChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
 
  Widget _buildStreakCard(double dailyProgress, int dailyPercent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryDark.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho ofensiva
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: AppTheme.accent, size: 28),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OFENSIVA',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_streakDays',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.0),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 3, left: 4),
                        child: Text('DIAS',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.track_changes_rounded,
                  color: Colors.white24, size: 26),
            ],
          ),
 
          const SizedBox(height: 20),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 20),
 
          // Dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final labels = [
                'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'
              ];
              int dayNumber = index + 1;
              int currentWeekday = DateTime.now().weekday;
              int state = 0;
              if (dayNumber < currentWeekday) {
                state =
                    (currentWeekday - dayNumber) <= _streakDays ? 2 : 0;
              } else if (dayNumber == currentWeekday) {
                state = _dailyXpEarned >= _dailyXpGoal ? 2 : 1;
              }
              return _buildDayIndicator(labels[index], state);
            }),
          ),
 
          const SizedBox(height: 28),
 
          // Meta diária
          Row(
            children: [
              const Text('META DIÁRIA DE XP',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: dailyPercent >= 100
                      ? AppTheme.correctGreen.withOpacity(0.2)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$dailyPercent%',
                  style: TextStyle(
                    color: dailyPercent >= 100
                        ? AppTheme.correctGreen
                        : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_dailyXpEarned',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.0),
              ),
              Text(
                ' / $_dailyXpGoal XP',
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: dailyProgress,
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                dailyPercent >= 100
                    ? AppTheme.correctGreen
                    : const Color(0xFF4ADE80),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildDayIndicator(String dayLabel, int state) {
    Color ringColor;
    Widget innerContent;
 
    if (state == 2) {
      ringColor = AppTheme.correctGreen;
      innerContent = Container(
        decoration: const BoxDecoration(
            color: AppTheme.correctGreen, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    } else if (state == 1) {
      ringColor = AppTheme.accent;
      innerContent = Container(
          decoration: const BoxDecoration(
              color: Colors.transparent, shape: BoxShape.circle));
    } else {
      ringColor = Colors.transparent;
      innerContent = Container(
          decoration: const BoxDecoration(
              color: Colors.white10, shape: BoxShape.circle));
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
        const SizedBox(height: 6),
        Text(dayLabel,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
 
  Widget _buildModuleBlock(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required List<Color> gradientColors,
    required String route,
  }) {
    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(context, route);
        _loadData();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            // Ícone com gradiente
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark,
                        letterSpacing: -0.2),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            // Badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}