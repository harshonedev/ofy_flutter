import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/features/chat/presentation/pages/chat_page.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_bloc.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/models_bloc.dart';
import 'package:llm_cpp_chat_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/model_picker/presentation/bloc/model_picker_bloc.dart';
import 'features/model_picker/presentation/bloc/model_picker_event.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> _isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ChatBloc>()),
        BlocProvider<DownloadManagerBloc>(
          create: (_) => di.sl<DownloadManagerBloc>(),
        ),
        BlocProvider<ModelsBloc>(create: (_) => di.sl<ModelsBloc>()),
        BlocProvider(
          create: (context) => di.sl<SettingsBloc>()..add(GetSettingsEvent()),
        ),
        BlocProvider(
          create: (context) {
            final bloc = di.sl<ModelPickerBloc>();
            // Fetch model path at startup
            bloc.add(GetModelPathEvent());
            return bloc;
          },
        ),
      ],
      child: FutureBuilder<bool>(
        future: _isOnboardingComplete(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }
          final onboardingComplete = snapshot.data!;
          return MaterialApp(
            title: 'OfflineAI',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            home:
                onboardingComplete ? const ChatPage() : const OnboardingPage(),
          );
        },
      ),
    );
  }
}
