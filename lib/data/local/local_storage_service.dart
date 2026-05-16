import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _xpKey = 'user_xp';
  static const String _dailyXpKey = 'daily_xp';
  static const String _streakKey = 'streak_days';
  static const String _lastDateKey = 'last_date';

  // Busca todos os dados e já faz a verificação de datas
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final totalXp = prefs.getInt(_xpKey) ?? 0;
    final dailyXp = prefs.getInt(_dailyXpKey) ?? 0;
    final streak = prefs.getInt(_streakKey) ?? 0;
    final lastDateStr = prefs.getString(_lastDateKey) ?? '';

    // Pegando a data de hoje no formato "YYYY-MM-DD" para evitar problemas de fuso/hora
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
    
    int finalDailyXp = dailyXp;
    int finalStreak = streak;

    if (lastDateStr.isNotEmpty && lastDateStr != todayStr) {
       final lastDate = DateTime.parse(lastDateStr);
       final todayNorm = DateTime(now.year, now.month, now.day);
       final diff = todayNorm.difference(lastDate).inDays;

       // Se passou mais de 1 dia sem logar, a ofensiva é quebrada!
       if (diff > 1) {
         finalStreak = 0;
         await prefs.setInt(_streakKey, 0);
       }
       
       // Como virou o dia, o XP Diário volta para 0
       finalDailyXp = 0;
       await prefs.setInt(_dailyXpKey, 0);
       
       // Atualiza a data no banco para hoje
       await prefs.setString(_lastDateKey, todayStr);
    } else if (lastDateStr.isEmpty) {
       await prefs.setString(_lastDateKey, todayStr);
    }

    return {
      'totalXp': totalXp,
      'dailyXp': finalDailyXp,
      'streak': finalStreak,
    };
  }

  // Função otimizada para ganhar XP e calcular a meta
  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Soma no XP Total
    final currentTotal = prefs.getInt(_xpKey) ?? 0;
    await prefs.setInt(_xpKey, currentTotal + amount);

    // 2. Lógica do XP Diário
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
    final lastDate = prefs.getString(_lastDateKey) ?? '';
    
    int currentDaily = prefs.getInt(_dailyXpKey) ?? 0;
    
  
    if (lastDate != todayStr) {
      currentDaily = 0; 
      await prefs.setString(_lastDateKey, todayStr);
    }
    
    int newDaily = currentDaily + amount;
    await prefs.setInt(_dailyXpKey, newDaily);

    // 3. A MÁGICA DA OFENSIVA
    if (currentDaily < 500 && newDaily >= 500) {
       final currentStreak = prefs.getInt(_streakKey) ?? 0;
       await prefs.setInt(_streakKey, currentStreak + 1);
    }
  }
}