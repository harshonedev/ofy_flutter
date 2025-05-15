import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/features/chat/presentation/pages/chat_page.dart';
import 'package:llm_cpp_chat_app/features/download_manager/presentation/bloc/download_manager_bloc.dart';
import 'package:llm_cpp_chat_app/features/settings/presentation/bloc/settings_event.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/model_picker/presentation/bloc/model_picker_bloc.dart';
import 'features/model_picker/presentation/bloc/model_picker_event.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ChatBloc>()),
        BlocProvider<DownloadManagerBloc>(
          create: (_) => di.sl<DownloadManagerBloc>(),
        ),
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
      child: MaterialApp(
        title: 'OfflineAI',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        home: const ChatPage(),
      ),
    );
  }
}
