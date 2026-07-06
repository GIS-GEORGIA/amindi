import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ka'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ka'),
      child: const ProviderScope(child: AmindiApp()),
    ),
  );
}
