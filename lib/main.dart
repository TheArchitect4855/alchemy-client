import 'package:alchemy/firebase_options.dart';
import 'package:alchemy/pages/init.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

const baseTextTheme = Typography.englishLike2021;
const primaryColor = Color(0xff7cff66);
final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: const Color(0xff00d2fc),
    error: Colors.red);
final textTheme = baseTextTheme
    .copyWith(
      displayLarge: baseTextTheme.displayLarge!.copyWith(
        fontWeight: FontWeight.bold,
      ),
      displayMedium: baseTextTheme.displayMedium!.copyWith(
        fontWeight: FontWeight.bold,
      ),
      displaySmall: baseTextTheme.displaySmall!.copyWith(
        fontWeight: FontWeight.bold,
      ),
    )
    .apply(
      fontFamily: 'Lexend',
      displayColor: Colors.black,
      bodyColor: Colors.black,
    );

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final platform = ImagePickerPlatform.instance;
  if (platform is ImagePickerAndroid) {
    platform.useAndroidPhotoPicker = true;
  }

  runApp(const AlchemyApp());
}

class AlchemyApp extends StatelessWidget {
  const AlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alchemy',
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: textTheme,
        useMaterial3: true,
        filledButtonTheme: FilledButtonThemeData(
            style: ButtonStyle(
          textStyle: MaterialStatePropertyAll(textTheme.labelLarge),
          foregroundColor: const MaterialStatePropertyAll(Colors.black),
        )),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(colorScheme.secondary),
        )),
      ),
      home: const InitPage(),
    );
  }
}
