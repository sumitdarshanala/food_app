import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:meal_1/providers/meals_provider.dart';

enum Filter {
  glutenFree,
  lactoseFree,
  vegetarian,
  vegan,
}


Future<Database> _getDataBase() async {
  final dbpath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(path.join(dbpath, 'filters.db'),
      onCreate: (db, version) {
    return db.execute(
        'CREATE TABLE user_filters(glutenFree BOOLEAN,lactoseFree BOOLEAN,vegetarian BOOLEAN,vegan BOOLEAN)');
  }, version: 1);
  return db;
}

class FiltersNotifier extends StateNotifier<Map<Filter, bool>> {
  FiltersNotifier()
      : super({
          Filter.glutenFree: false,
          Filter.lactoseFree: false,
          Filter.vegetarian: false,
          Filter.vegan: false,
        });

  Future<void> load_filters() async {
    final db = await _getDataBase();
    final data = await db.query('user_filters');
    final filter = data.map((row) => {
          Filter.glutenFree: row['glutenFree'] as bool,
          Filter.lactoseFree: row['lactoseFree'] as bool,
          Filter.vegetarian: row['vegetarian'] as bool,
          Filter.vegan: row['vegan'] as bool,
        });
    state = filter.elementAt(0);
  }

  void setFilters(Map<Filter, bool> chosenFilters) async {
    final db = await _getDataBase();
    db.insert('user_filters', {
      'glutenFree': chosenFilters['Filter.glutenFree'] as bool,
      'lactoseFree': chosenFilters['Filter.lactoseFree'] as bool,
      'vegetarian': chosenFilters['Filter.vegetarian'] as bool,
      'vegan': chosenFilters['Filter.vegan'] as bool,
    });
    state = chosenFilters;
  }

  void setFilter(Filter filter, bool isActive) async {
    // state[filter] = isActive; // not allowed! => mutating state
    state = {
      ...state,
      filter: isActive,
    };
  }
}

final filtersProvider =
    StateNotifierProvider<FiltersNotifier, Map<Filter, bool>>(
  (ref) => FiltersNotifier(),
);

final filteredMealsProvider = Provider((ref) {
  final meals = ref.watch(mealsProvider);
  final activeFilters = ref.watch(filtersProvider);

  return meals.where((meal) {
    if (activeFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
      return false;
    }
    if (activeFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
      return false;
    }
    if (activeFilters[Filter.vegetarian]! && !meal.isVegetarian) {
      return false;
    }
    if (activeFilters[Filter.vegan]! && !meal.isVegan) {
      return false;
    }
    return true;
  }).toList();
});
