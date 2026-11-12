import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_catalog/app/features/home/bloc/home_bloc.dart';
import 'package:recipe_catalog/app/features/content/bloc/content_bloc.dart';
import 'package:recipe_catalog/data/models/content.dart';
import 'package:recipe_catalog/data/repositories/content_repository_interface.dart';
import 'package:recipe_catalog/data/repositories/content_repository.dart';

import 'repository_test.dart' show recipeJson;

class ControlledRepository implements ContentRepositoryInterface {
  bool fail = false;
  bool empty = false;
  final recipe = Content.fromJson(recipeJson);
  @override
  Future<List<Content>> getContent() async {
    if (fail) throw const ContentException('Нет соединения');
    return empty ? [] : [recipe];
  }

  @override
  Future<Content> getContentById(int id) async {
    if (fail) throw const ContentException('Рецепт не найден');
    return recipe;
  }
}

void main() {
  late ControlledRepository repo;
  setUp(() => repo = ControlledRepository());

  blocTest<HomeBloc, HomeState>(
    'home emits loading then success',
    build: () => HomeBloc(repo),
    act: (bloc) => bloc.add(const HomeLoad()),
    expect: () => [
      isA<HomeLoadInProgress>(),
      isA<HomeLoadSuccess>().having((s) => s.content.single.id, 'id', 3),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'home preserves successful empty response',
    build: () {
      repo.empty = true;
      return HomeBloc(repo);
    },
    act: (bloc) => bloc.add(const HomeLoad()),
    expect: () => [
      isA<HomeLoadInProgress>(),
      isA<HomeLoadSuccess>().having((s) => s.content, 'content', isEmpty),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'home emits failure and can recover on retry',
    build: () {
      repo.fail = true;
      return HomeBloc(repo);
    },
    act: (bloc) async {
      bloc.add(const HomeLoad());
      await bloc.stream.firstWhere((s) => s is HomeLoadFailure);
      repo.fail = false;
      bloc.add(const HomeLoad());
    },
    expect: () => [
      isA<HomeLoadInProgress>(),
      isA<HomeLoadFailure>(),
      isA<HomeLoadInProgress>(),
      isA<HomeLoadSuccess>(),
    ],
  );

  blocTest<ContentBloc, ContentState>(
    'detail emits loading then selected recipe',
    build: () => ContentBloc(repo),
    act: (bloc) => bloc.add(const ContentLoad(3)),
    expect: () => [
      isA<ContentLoadInProgress>(),
      isA<ContentLoadSuccess>().having((s) => s.content.id, 'id', 3),
    ],
  );

  blocTest<ContentBloc, ContentState>(
    'detail emits failure',
    build: () {
      repo.fail = true;
      return ContentBloc(repo);
    },
    act: (bloc) => bloc.add(const ContentLoad(9999)),
    expect: () => [isA<ContentLoadInProgress>(), isA<ContentLoadFailure>()],
  );

  blocTest<ContentBloc, ContentState>(
    'detail retries successfully after failure',
    build: () {
      repo.fail = true;
      return ContentBloc(repo);
    },
    act: (bloc) async {
      bloc.add(const ContentLoad(3));
      await bloc.stream.firstWhere((s) => s is ContentLoadFailure);
      repo.fail = false;
      bloc.add(const ContentLoad(3));
    },
    expect: () => [
      isA<ContentLoadInProgress>(),
      isA<ContentLoadFailure>(),
      isA<ContentLoadInProgress>(),
      isA<ContentLoadSuccess>(),
    ],
  );
}
