import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de Cores Base
  static const Color primaryDark = Color(0xFF0B132B); // Azul Meia-noite profundo
  static const Color primaryBlue = Color(0xFF1C4ED8); // Azul Royal
  static const Color accentDark = Color(0xFFC2410C);  // Laranja queimado
  static const Color accent = Color(0xFFF97316);      // Laranja vibrante
  static const Color background = Color(0xFFF1F5F9);  // Cinza gelo de fundo
  static const Color surface = Colors.white;

  // Cores de Feedback
  static const Color correctGreen = Color(0xFF059669);
  static const Color wrongRed = Color(0xFFDC2626);

  
  // Degradê Azul (Fundo Escuro -> Fundo Claro)
  static const LinearGradient descendingBlue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primaryBlue],
  );

  // Degradê Laranja (Para botões e destaques)
  static const LinearGradient descendingOrange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accent, accentDark],
  );
  
  // Degradê de Acerto
  static const LinearGradient descendingGreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF10B981), correctGreen],
  );

  // Degradê de Erro
  static const LinearGradient descendingRed = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEF4444), wrongRed],
  );

  // Efeitos: Sombras 
  static List<BoxShadow> cardShadow = [
    BoxShadow(color: primaryDark.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue, background: background),
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: background,
     
    );
  }
}