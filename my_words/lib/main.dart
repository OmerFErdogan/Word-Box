import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:my_words/models/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/daily_task_model.dart';
import 'screens/home_screen.dart';
import 'models/words_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      final wordsModel = WordsModel();
      await wordsModel.init();
      await wordsModel.loadStreak();

      final themeModel = ThemeModel();
      await themeModel.loadTheme();

      final dailyTaskModel = DailyTaskModel();

      FlutterNativeSplash.removeAfter(initialization);

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => dailyTaskModel),
            ChangeNotifierProxyProvider<DailyTaskModel, WordsModel>(
              create: (_) => wordsModel,
              update: (_, dailyTaskModel, wordsModel) {
                wordsModel!.setDailyTaskModel(dailyTaskModel);
                return wordsModel;
              },
            ),
            ChangeNotifierProvider<ThemeModel>.value(value: themeModel),
          ],
          child: const MyApp(),
        ),
      );
    } catch (e, stackTrace) {
      print('Error during initialization: $e');
      print('Stack trace: $stackTrace');
      // Burada bir hata raporlama servisi çağrılabilir
    }
  }, (error, stack) {
    print('Unhandled error: $error');
    print('Stack trace: $stack');
    // Burada bir hata raporlama servisi çağrılabilir
  });
}

Future<void> initialization(BuildContext? context) async {
  try {
    await Future.delayed(const Duration(seconds: 3));
  } catch (e) {
    print('Error during initialization: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const KelimeKumbarasiApp();
  }
}

class KelimeKumbarasiApp extends StatelessWidget {
  const KelimeKumbarasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'Kelime Kumbarası',
          supportedLocales: const [
            Locale('en', ''), // İngilizce
            Locale('tr', ''), // Türkçe
            Locale('fr', ''), // Fransızca
            Locale('de', ''), // Almanca
            Locale('it', ''), // İtalyanca
            Locale('ru', ''), // Rusça
            Locale('es', ''), // İspanyolca
            Locale('pt', ''), // Portekizce
            Locale('el', ''), // Yunanca
            Locale('ko', ''), // Korece
            Locale('hu', ''), // Macarca
            Locale('pl', ''), // Lehçe
            Locale('da', ''), // Danca
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: themeModel.currentTheme,
          home: const HomeScreen(),
          builder: (context, widget) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return Scaffold(
                body: Center(
                  child: Text('An error occurred: ${errorDetails.exception}'),
                ),
              );
            };
            return widget ??
                const Scaffold(body: Center(child: Text('Loading...')));
          },
        );
      },
    );
  }
}
