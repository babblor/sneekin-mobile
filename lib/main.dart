import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/auth/auth_screen.dart';
import 'package:sneekin/models/organization.dart';
import 'package:sneekin/models/user.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/services/helper_services.dart';
import 'package:sneekin/services/theme_services.dart';
import 'package:toastification/toastification.dart';
import 'services/router_services.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF1F293F), // Primary color
  secondaryHeaderColor: const Color(0xFF1F2937),
  scaffoldBackgroundColor: const Color(0xFF1F293F), // Background color
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F2937),
    titleTextStyle:
        TextStyle(color: Color(0xFFFF6500), fontSize: 20, fontWeight: FontWeight.bold), // AppBar title color
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white),
    headlineLarge: TextStyle(
      color: Color(0xFFFF6500), // Title color
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF1F2937), // Button color
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1F2937), // Elevated button color
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontSize: 16),
    ),
  ),
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF1F293F), // Primary color
  secondaryHeaderColor: const Color(0xFFFFFFFF), // Secondary header color (white)
  scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Light background color
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F2937), // AppBar background color
    titleTextStyle:
        TextStyle(color: Color(0xFFFF6500), fontSize: 20, fontWeight: FontWeight.bold), // Title color
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF1F293F)),
    bodyMedium: TextStyle(color: Color(0xFF1F2937)),
    bodySmall: TextStyle(color: Color(0xFF1F293F)),
    headlineLarge: TextStyle(
      color: Color(0xFFFF6500), // Title color
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF1F2937), // Button color
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1F2937), // Elevated button color
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontSize: 16),
    ),
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env.local");
    log("Loaded .env.local file");
  } catch (e) {
    log("Error loading .env file: $e");
  }

  if (!kIsWeb) {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
  }

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(OrganizationAdapter());
  AuthServices authServices = AuthServices();
  AppStore appStore = AppStore();

  await authServices.initialize();

  await appStore.initializeUserData();
  await appStore.initializeOrgData();

  log("Current logged in user status: ${appStore.isSignedIn}");
  log("Current logged in org status: ${appStore.isOrgSignedIn}");

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeServices()),
      ChangeNotifierProvider(create: (context) => HelperServices()),
      ChangeNotifierProvider.value(value: authServices),
      ChangeNotifierProvider.value(value: appStore),
      ChangeNotifierProvider(create: (context) => RouterServices()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    log("MyApp built"); // For debugging rebuilds

    return Consumer2<ThemeServices, RouterServices>(
      builder: (context, theme, routerServices, child) {
        log("Current themeMode: ${theme.themeMode}");

        return ToastificationWrapper(
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: theme.themeMode,
            routerConfig: routerServices.getRouter(context),
          ),
        );
        // return MaterialApp(
        //   debugShowCheckedModeBanner: false,
        //   home: AuthScreen(),
        // );
      },
    );
  }
}
