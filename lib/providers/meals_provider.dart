import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meal_1/data/dummy_data.dart';

final mealsProvider = Provider((ref) {
  return dummyMeals;
});
