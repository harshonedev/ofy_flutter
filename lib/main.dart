import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/model_type.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/model_picker/presentation/pages/model_picker_page.dart';
import 'features/settings/data/repositories/settings_repository.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings repository
  final settingsRepository = SettingsRepository();

  // Get model type preference at app start
  final modelType = await settingsRepository.getModelTypePreference();

  runApp(MainApp(initialModelType: modelType));
}

class MainApp extends StatelessWidget {
  final ModelType initialModelType;

  const MainApp({super.key, this.initialModelType = ModelType.local});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ChatProvider())],
      child: MaterialApp(
        title: 'LLM Chat App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        home: const ModelPickerPage(),
      ),
    );
  }
}
