import 'package:get_it/get_it.dart';
import 'package:llm_cpp_chat_app/features/chat/domain/usecases/update_chat_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/chat/data/datasources/local_chat_datasource.dart';
import '../../features/chat/data/datasources/remote_chat_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/data/services/local_model_service_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/services/local_model_service_interface.dart';
import '../../features/chat/domain/usecases/clear_chat_history.dart';
import '../../features/chat/domain/usecases/get_chat_history.dart';
import '../../features/chat/domain/usecases/send_message.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_model_type_preference.dart';
import '../../features/settings/domain/usecases/save_model_type_preference.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/model_picker/data/datasources/model_picker_local_datasource.dart';
import '../../features/model_picker/data/repositories/model_picker_repository_impl.dart';
import '../../features/model_picker/domain/repositories/model_picker_repository.dart';
import '../../features/model_picker/domain/usecases/get_model_path.dart';
import '../../features/model_picker/domain/usecases/save_model_path.dart';
import '../../features/model_picker/presentation/bloc/model_picker_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Chat
  // Services
  sl.registerLazySingleton<LocalModelServiceInterface>(
    () => LocalModelServiceImpl(),
  );

  // Bloc
  sl.registerFactory(
    () => ChatBloc(
      sendMessage: sl(),
      getChatHistory: sl(),
      clearChatHistory: sl(),
      updateChatHistory: sl(),
      modelService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetChatHistory(sl()));
  sl.registerLazySingleton(() => ClearChatHistory(sl()));
  sl.registerLazySingleton(() => UpdateChatHistory(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      localModelService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<LocalChatDataSource>(
    () => LocalChatDataSourceImpl(),
  );
  sl.registerLazySingleton<RemoteChatDataSource>(
    () => RemoteChatDataSourceImpl(),
  );

  //! Features - Settings
  // Bloc
  sl.registerFactory(
    () => SettingsBloc(
      getModelTypePreference: sl(),
      saveModelTypePreference: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetModelTypePreference(sl()));
  sl.registerLazySingleton(() => SaveModelTypePreference(sl()));

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Model Picker
  // Bloc
  sl.registerFactory(
    () => ModelPickerBloc(getModelPath: sl(), saveModelPath: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetModelPath(sl()));
  sl.registerLazySingleton(() => SaveModelPath(sl()));

  // Repository
  sl.registerLazySingleton<ModelPickerRepository>(
    () => ModelPickerRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ModelPickerLocalDataSource>(
    () => ModelPickerLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
