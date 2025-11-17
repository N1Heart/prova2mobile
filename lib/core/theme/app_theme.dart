import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- NOVAS CORES (Bege, Vermelho, Branco, Preto) ---
  static const Color primaryColor = Color(
    0xFFC62828,
  ); // Vermelho (para botões, headers)
  static const Color secondaryColor = Color(
    0xFFD32F2F,
  ); // Vermelho (para ícones, destaques)
  static const Color errorColor = Color(
    0xFFB71C1C,
  ); // Vermelho Escuro (para erros)
  static const Color surfaceColor = Color(
    0xFFFFFFFF,
  ); // Branco (para Cards e campos de texto)
  static const Color backgroundColor = Color(
    0xFFFFF9F0,
  ); // Bege (Fundo principal)
  static const Color darkTextColor = Color(
    0xFF1a1a1a,
  ); // Preto (para texto principal)
  static const Color lightTextColor = Color(
    0xFF5a5a5a,
  ); // Cinza escuro (para texto secundário)

  // --- O TEMA CLARO (Light Theme) ---
  static ThemeData get lightTheme {
    // 1. Começamos com um tema base (light)
    final base = ThemeData.light(useMaterial3: true);

    // 2. Aplicamos o GoogleFonts ao TextTheme INTEIRO do tema base
    final textTheme = GoogleFonts.robotoTextTheme(
      base.textTheme,
    ).apply(bodyColor: darkTextColor, displayColor: darkTextColor);

    // 3. Usamos 'copyWith' para aplicar nossas customizações
    return base.copyWith(
      // Esquema de cores principal
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor, // Fundo bege
        surface: surfaceColor, // Superfície branca
        brightness: Brightness.light,
        onPrimary: Colors.white, // Texto em botões vermelhos
        onSecondary: Colors.white,
        onError: Colors.white,
        onBackground: darkTextColor, // Texto no fundo bege
        onSurface: darkTextColor, // Texto em cima dos cards brancos
      ),

      // Fundo principal do Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // Tipografia (com as cores corretas)
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: darkTextColor,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: darkTextColor,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: darkTextColor),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: lightTextColor, // cor específica para bodyMedium
        ),
      ),

      // Estilo dos Inputs (TextFormField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor, // Fundo branco
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ), // Borda cinza claro
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ), // Borda vermelha ao focar
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIconColor: lightTextColor,
      ),

      // Estilo dos Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Botão vermelho
          foregroundColor: Colors.white, // Texto branco
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Estilo da AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor, // AppBar branca
        foregroundColor: darkTextColor, // Ícones e Título (preto)
        centerTitle: true,
        elevation: 1,
        scrolledUnderElevation: 2.0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: primaryColor,
        ), // Título vermelho
      ),

      // Estilo do Card
      cardTheme: CardThemeData(
        elevation: 1,
        color: surfaceColor, // Card branco
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
