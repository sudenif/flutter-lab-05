import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_catalog/app/features/content/bloc/content_bloc.dart';
import 'package:recipe_catalog/app/lab_stage.dart';
import 'package:recipe_catalog/app/router/router.dart';
import 'package:recipe_catalog/data/models/content.dart';
import 'package:recipe_catalog/data/repositories/content_repository_interface.dart';
import 'package:recipe_catalog/di/di.dart';
import 'package:recipe_catalog/recipe_app.dart';

import 'repository_test.dart' show recipeJson;

class NumberedRepository implements ContentRepositoryInterface {
  @override
  Future<List<Content>> getContent() async => [];
  @override
  Future<Content> getContentById(int id) async =>
      Content.fromJson({...recipeJson, 'id': id, 'name': 'Recipe $id'});
}

void main() {
  testWidgets('changing detail route id loads the new recipe', (tester) async {
    await getIt.reset();
    getIt.registerFactory<ContentBloc>(() => ContentBloc(NumberedRepository()));
    final router = createRouter(LabStage.lab5)..go('/content/1');
    await tester.pumpWidget(RecipeApp(router: router));
    await tester.pumpAndSettle();
    expect(find.text('Recipe 1'), findsOneWidget);
    router.go('/content/2');
    await tester.pumpAndSettle();
    expect(find.text('Recipe 2'), findsOneWidget);
    expect(find.text('Recipe 1'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    await getIt.reset();
  });
}
