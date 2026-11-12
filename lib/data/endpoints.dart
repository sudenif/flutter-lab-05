abstract final class Endpoints {
  static const recipes = '/recipes';
  static String recipe(int id) => '$recipes/$id';
}
