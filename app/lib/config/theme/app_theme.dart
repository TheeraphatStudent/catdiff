import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();

// Gradient color
  static const LinearGradient gradientStatus1 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFEE3), white],
  );
  
  static const LinearGradient gradientStatus2 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE3F9FF), white],
  );
  
  static const LinearGradient gradientStatus3 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9E3FF), white],
  );
  
  static const LinearGradient gradientStatus4 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE9FFE3), white],
  );

  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment(0.50, -0.00),
      end: Alignment(0.50, 0.85),
    colors: [Color(0x00D3ECA5), Color(0xC6D3ECA5), Color(0xFFD3ECA5)],
  );
  
  static const LinearGradient gradientSender = LinearGradient(
      begin: Alignment(1.00, 0.00),
      end: Alignment(0.00, 1.00),
      colors: [Color(0xFF8AD9BD), Color(0x7F8AD9BD), Color(0x00BFE6D2), Color(0x7FEDF2E5), Color(0xFF8AD9BD)]
    );

static const LinearGradient gradientRecever = LinearGradient(
      begin: Alignment(1.00, 0.00),
      end: Alignment(0.00, 1.00),
      colors: [Color(0xFF8A90D9), Color(0x7F8A91D9), Color(0x008A91D9), Color(0x7FEDF2E5), Color(0xFF8A91D9)],
    );

// Solid color
  static const Color white = Color(0xFFFAFFF1);
  static const Color black = Color(0xFF011F02);

  static const Color primary1 = Color(0xFF0A400C);
  static const Color primary2 = Color(0xFF819067);
  static const Color primary3 = Color(0xFFB5D57D);
  static const Color primary4 = Color(0xFFD3EDA6);
  static const Color primary5 = Color(0xFFEDFFCD);

  static const Color grayInsight = Color(0xFFF2F8E9);
  static const Color grayLight = Color(0xFFEDF2E5);
  static const Color grayMedium = Color(0xFFC2C6BB);

  static const Color lightDanger = Color(0xFFFFB7AB);
  static const Color lightWarning = Color(0xFFFFE9A7);
  static const Color lightTilip = Color(0xFFEDA6D4);
  static const Color lightOcean = Color(0xFFA6DFED);

  static const Color darkDanger = Color(0xFFBD3A26);
  static const Color darkWarning = Color(0xFF97781A);
  static const Color darkTilip = Color(0xFFD95FAE);
  static const Color darkOcean = Color(0xFF4BB3CC);
}

// class AppTheme {
//   AppTheme._();

//   // Common border radius
//   static const double borderRadiusSmall = 4.0;
//   static const double borderRadiusMedium = 8.0;
//   static const double borderRadiusLarge = 12.0;
//   static const double borderRadiusXLarge = 16.0;

//   // Common spacing
//   static const double spacingXSmall = 4.0;
//   static const double spacingSmall = 8.0;
//   static const double spacingMedium = 16.0;
//   static const double spacingLarge = 24.0;
//   static const double spacingXLarge = 32.0;

//   static final ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     fontFamily: 'Mali',

//     // Color Scheme
//     // colorScheme: const ColorScheme.light(
//     //   primary: AppColors.primary,
//     //   onPrimary: AppColors.onPrimary,
//     //   primaryContainer: AppColors.primaryLight,
//     //   onPrimaryContainer: AppColors.primaryDark,

//     //   secondary: AppColors.secondary,
//     //   onSecondary: AppColors.onSecondary,
//     //   secondaryContainer: AppColors.secondaryLight,
//     //   onSecondaryContainer: AppColors.secondaryDark,

//     //   tertiary: AppColors.info,
//     //   onTertiary: Colors.white,

//     //   error: AppColors.error,
//     //   onError: Colors.white,
//     //   errorContainer: Color(0xFFFFEBEE),
//     //   onErrorContainer: AppColors.error,

//     //   surface: AppColors.surface,
//     //   onSurface: AppColors.onSurface,
//     //   surfaceContainerHighest: AppColors.surfaceVariant,
//     //   onSurfaceVariant: AppColors.textSecondary,

//     //   outline: AppColors.outline,
//     //   outlineVariant: AppColors.divider,
//     //   shadow: AppColors.shadow,
//     //   scrim: Colors.black54,

//     //   inverseSurface: AppColors.textPrimary,
//     //   onInverseSurface: AppColors.surface,
//     //   inversePrimary: AppColors.primaryLight,
//     // ),

//     // Scaffold Theme
//     // scaffoldBackgroundColor: AppColors.scaffold,

//     // App Bar Theme
//     // appBarTheme: const AppBarTheme(
//     //   backgroundColor: AppColors.primary,
//     //   foregroundColor: AppColors.onPrimary,
//     //   surfaceTintColor: Colors.transparent,
//     //   elevation: 2.0,
//     //   shadowColor: AppColors.shadow,
//     //   centerTitle: false,
//     //   titleTextStyle: TextStyle(
//     //     fontFamily: 'Kanit',
//     //     fontSize: 20.0,
//     //     fontWeight: FontWeight.w600,
//     //     color: AppColors.onPrimary,
//     //   ),
//     //   iconTheme: IconThemeData(color: AppColors.onPrimary, size: 24.0),
//     //   actionsIconTheme: IconThemeData(color: AppColors.onPrimary, size: 24.0),
//     //   systemOverlayStyle: SystemUiOverlayStyle(
//     //     statusBarColor: Colors.transparent,
//     //     statusBarIconBrightness: Brightness.light,
//     //     statusBarBrightness: Brightness.dark,
//     //   ),
//     // ),

//     // Text Theme
//     // textTheme: const TextTheme(
//     //   displayLarge: TextStyle(
//     //     fontSize: 57.0,
//     //     fontWeight: FontWeight.bold,
//     //     color: AppColors.textPrimary,
//     //     letterSpacing: -0.25,
//     //     height: 1.12,
//     //   ),
//     //   displayMedium: TextStyle(
//     //     fontSize: 45.0,
//     //     fontWeight: FontWeight.bold,
//     //     color: AppColors.textPrimary,
//     //     letterSpacing: 0.0,
//     //     height: 1.16,
//     //   ),
//     //   displaySmall: TextStyle(
//     //     fontSize: 16,
//     //     fontWeight: FontWeight.w600,
//     //     color: AppColors.primary_1,
//     //     letterSpacing: 0.0,
//     //     height: 1.22,
//     //   ),

//       // Headline styles
//       headlineLarge: TextStyle(
//         fontSize: 32.0,
//         fontWeight: FontWeight.bold,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.0,
//         height: 1.25,
//       ),
//       headlineMedium: TextStyle(
//         fontSize: 28.0,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.0,
//         height: 1.29,
//       ),
//       headlineSmall: TextStyle(
//         fontSize: 24.0,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.0,
//         height: 1.33,
//       ),

//       // Title styles
//       titleLarge: TextStyle(
//         fontSize: 22.0,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.0,
//         height: 1.27,
//       ),
//       titleMedium: TextStyle(
//         fontSize: 16.0,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.15,
//         height: 1.5,
//       ),
//       titleSmall: TextStyle(
//         fontSize: 14.0,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.1,
//         height: 1.43,
//       ),

//       // Body styles
//       bodyLarge: TextStyle(
//         fontSize: 16.0,
//         fontWeight: FontWeight.normal,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.5,
//         height: 1.5,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: 14.0,
//         fontWeight: FontWeight.normal,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.25,
//         height: 1.43,
//       ),
//       bodySmall: TextStyle(
//         fontSize: 12.0,
//         fontWeight: FontWeight.normal,
//         color: AppColors.textSecondary,
//         letterSpacing: 0.4,
//         height: 1.33,
//       ),

//       // Label styles
//       labelLarge: TextStyle(
//         fontSize: 14.0,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.1,
//         height: 1.43,
//       ),
//       labelMedium: TextStyle(
//         fontSize: 12.0,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//         letterSpacing: 0.5,
//         height: 1.33,
//       ),
//       labelSmall: TextStyle(
//         fontSize: 11.0,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textSecondary,
//         letterSpacing: 0.5,
//         height: 1.45,
//       ),
//     ),

//     // Button Themes
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.onPrimary,
//         disabledBackgroundColor: AppColors.disabled,
//         disabledForegroundColor: AppColors.textDisabled,
//         shadowColor: AppColors.shadow,
//         elevation: 2.0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(borderRadiusMedium),
//         ),
//         padding: const EdgeInsets.symmetric(
//           horizontal: spacingMedium,
//           vertical: spacingSmall + 4,
//         ),
//         minimumSize: const Size(64, 40),
//         textStyle: const TextStyle(
//           fontFamily: 'Kanit',
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           letterSpacing: 0.1,
//         ),
//       ),
//     ),

//     filledButtonTheme: FilledButtonThemeData(
//       style: FilledButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.onPrimary,
//         disabledBackgroundColor: AppColors.disabled,
//         disabledForegroundColor: AppColors.textDisabled,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(borderRadiusMedium),
//         ),
//         padding: const EdgeInsets.symmetric(
//           horizontal: spacingMedium,
//           vertical: spacingSmall + 4,
//         ),
//       ),
//     ),

//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         disabledForegroundColor: AppColors.textDisabled,
//         side: const BorderSide(color: AppColors.primary, width: 1),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(borderRadiusMedium),
//         ),
//         padding: const EdgeInsets.symmetric(
//           horizontal: spacingMedium,
//           vertical: spacingSmall + 4,
//         ),
//       ),
//     ),

//     textButtonTheme: TextButtonThemeData(
//       style: TextButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         disabledForegroundColor: AppColors.textDisabled,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(borderRadiusMedium),
//         ),
//         padding: const EdgeInsets.symmetric(
//           horizontal: spacingMedium,
//           vertical: spacingSmall,
//         ),
//       ),
//     ),

//     // Input Theme
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: AppColors.surface,
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: spacingMedium,
//         vertical: spacingSmall + 4,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(borderRadiusMedium),
//         borderSide: const BorderSide(color: AppColors.outline),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(borderRadiusMedium),
//         borderSide: const BorderSide(color: AppColors.outline),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(borderRadiusMedium),
//         borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(borderRadiusMedium),
//         borderSide: const BorderSide(color: AppColors.error),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(borderRadiusMedium),
//         borderSide: const BorderSide(color: AppColors.error, width: 2.0),
//       ),
//       disabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(borderRadiusMedium),
//         borderSide: const BorderSide(color: AppColors.disabled),
//       ),
//       labelStyle: const TextStyle(
//         color: AppColors.textSecondary,
//         fontSize: 16.0,
//       ),
//       floatingLabelStyle: const TextStyle(
//         color: AppColors.primary,
//         fontSize: 12.0,
//         fontWeight: FontWeight.w600,
//       ),
//       hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 16.0),
//       errorStyle: const TextStyle(color: AppColors.error, fontSize: 12.0),
//       helperStyle: const TextStyle(
//         color: AppColors.textSecondary,
//         fontSize: 12.0,
//       ),
//     ),

//     // Card Theme
//     cardTheme: CardThemeData(
//       color: AppColors.surface,
//       shadowColor: AppColors.shadow,
//       elevation: 1.0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(borderRadiusLarge),
//       ),
//       margin: const EdgeInsets.all(spacingSmall),
//     ),

//     // Dialog Theme
//     dialogTheme: DialogThemeData(
//       backgroundColor: AppColors.surface,
//       elevation: 8.0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(borderRadiusXLarge),
//       ),
//       titleTextStyle: const TextStyle(
//         fontFamily: 'Kanit',
//         fontSize: 24.0,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//       ),
//       contentTextStyle: const TextStyle(
//         fontFamily: 'Kanit',
//         fontSize: 16.0,
//         color: AppColors.textPrimary,
//       ),
//     ),

//     // Bottom Sheet Theme
//     bottomSheetTheme: const BottomSheetThemeData(
//       backgroundColor: AppColors.surface,
//       elevation: 8.0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(borderRadiusXLarge),
//         ),
//       ),
//     ),

//     // Chip Theme
//     chipTheme: ChipThemeData(
//       backgroundColor: AppColors.surfaceVariant,
//       disabledColor: AppColors.disabled,
//       selectedColor: AppColors.primaryLight,
//       secondarySelectedColor: AppColors.secondaryLight,
//       padding: const EdgeInsets.symmetric(
//         horizontal: spacingSmall,
//         vertical: spacingXSmall,
//       ),
//       labelStyle: const TextStyle(
//         color: AppColors.textPrimary,
//         fontSize: 14.0,
//         fontWeight: FontWeight.w500,
//       ),
//       secondaryLabelStyle: const TextStyle(
//         color: AppColors.onSecondary,
//         fontSize: 14.0,
//         fontWeight: FontWeight.w500,
//       ),
//       brightness: Brightness.light,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(borderRadiusMedium),
//       ),
//     ),

//     // Floating Action Button Theme
//     floatingActionButtonTheme: const FloatingActionButtonThemeData(
//       backgroundColor: AppColors.primary,
//       foregroundColor: AppColors.onPrimary,
//       elevation: 6.0,
//       focusElevation: 8.0,
//       hoverElevation: 8.0,
//       highlightElevation: 12.0,
//       shape: CircleBorder(),
//     ),

//     // Navigation Bar Theme
//     navigationBarTheme: NavigationBarThemeData(
//       backgroundColor: AppColors.surface,
//       elevation: 3.0,
//       height: 80.0,
//       labelTextStyle: WidgetStateProperty.resolveWith((states) {
//         if (states.contains(WidgetState.selected)) {
//           return const TextStyle(
//             fontSize: 12.0,
//             fontWeight: FontWeight.w600,
//             color: AppColors.primary,
//           );
//         }
//         return const TextStyle(
//           fontSize: 12.0,
//           fontWeight: FontWeight.w500,
//           color: AppColors.textSecondary,
//         );
//       }),
//       iconTheme: WidgetStateProperty.resolveWith((states) {
//         if (states.contains(WidgetState.selected)) {
//           return const IconThemeData(color: AppColors.primary, size: 24.0);
//         }
//         return const IconThemeData(color: AppColors.textSecondary, size: 24.0);
//       }),
//     ),

//     // Divider Theme
//     dividerTheme: const DividerThemeData(
//       color: AppColors.divider,
//       thickness: 1.0,
//       space: 1.0,
//     ),

//     // Icon Theme
//     iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24.0),
//     primaryIconTheme: const IconThemeData(
//       color: AppColors.onPrimary,
//       size: 24.0,
//     ),

//     // Progress Indicator Theme
//     progressIndicatorTheme: const ProgressIndicatorThemeData(
//       color: AppColors.primary,
//       linearTrackColor: AppColors.surfaceVariant,
//       circularTrackColor: AppColors.surfaceVariant,
//     ),

//     // Slider Theme
//     sliderTheme: SliderThemeData(
//       activeTrackColor: AppColors.primary,
//       inactiveTrackColor: AppColors.outline,
//       thumbColor: AppColors.primary,
//       overlayColor: AppColors.primary.withOpacity(0.12),
//       valueIndicatorColor: AppColors.primary,
//       valueIndicatorTextStyle: const TextStyle(
//         color: AppColors.onPrimary,
//         fontSize: 14.0,
//         fontWeight: FontWeight.w600,
//       ),
//     ),

//     // Switch Theme
//     switchTheme: SwitchThemeData(
//       thumbColor: WidgetStateProperty.resolveWith((states) {
//         if (states.contains(WidgetState.selected)) {
//           return AppColors.primary;
//         }
//         return AppColors.outline;
//       }),
//       trackColor: WidgetStateProperty.resolveWith((states) {
//         if (states.contains(WidgetState.selected)) {
//           return AppColors.primary.withOpacity(0.5);
//         }
//         return AppColors.surfaceVariant;
//       }),
//     ),

//     // Checkbox Theme
//     checkboxTheme: CheckboxThemeData(
//       fillColor: WidgetStateProperty.resolveWith((states) {
//         if (states.contains(WidgetState.selected)) {
//           return AppColors.primary;
//         }
//         return Colors.transparent;
//       }),
//       checkColor: WidgetStateProperty.all(AppColors.onPrimary),
//       side: const BorderSide(color: AppColors.outline, width: 2.0),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(borderRadiusSmall),
//       ),
//     ),

//     // Radio Theme
//     radioTheme: RadioThemeData(
//       fillColor: WidgetStateProperty.resolveWith((states) {
//         if (states.contains(WidgetState.selected)) {
//           return AppColors.primary;
//         }
//         return AppColors.outline;
//       }),
//     ),

//     // Snack Bar Theme
//     snackBarTheme: SnackBarThemeData(
//       backgroundColor: AppColors.textPrimary,
//       contentTextStyle: const TextStyle(
//         color: AppColors.surface,
//         fontSize: 14.0,
//       ),
//       actionTextColor: AppColors.secondary,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(borderRadiusMedium),
//       ),
//     ),

//     // Tooltip Theme
//     tooltipTheme: TooltipThemeData(
//       decoration: BoxDecoration(
//         color: AppColors.textPrimary.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(borderRadiusSmall),
//       ),
//       textStyle: const TextStyle(color: AppColors.surface, fontSize: 12.0),
//       padding: const EdgeInsets.symmetric(
//         horizontal: spacingSmall,
//         vertical: spacingXSmall,
//       ),
//     ),
//   );
// }
