import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import '../data/dio/set_up.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/content_repository_interface.dart';
import '../app/features/home/bloc/home_bloc.dart';
import '../app/features/content/bloc/content_bloc.dart';

final getIt = GetIt.instance;
final talker = TalkerFlutter.init();

Future<void> setupLocator() async {
  getIt.registerSingleton<Talker>(talker);
  final dio = setUpDio(talker);
  getIt.registerSingleton<Dio>(dio, dispose: (client) => client.close());
  getIt.registerLazySingleton<ContentRepositoryInterface>(
    () => ContentRepository(dio: dio),
  );
  // Factory: каждый экран получает новый BLoC, BlocProvider закрывает его.
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(getIt<ContentRepositoryInterface>()),
  );
  getIt.registerFactory<ContentBloc>(
    () => ContentBloc(getIt<ContentRepositoryInterface>()),
  );
  Bloc.observer = TalkerBlocObserver(talker: talker);
}
