import 'package:dio_complete/features/category/data/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<int> createCategory({required String name});
  Future<void> updateCategory({required int id, required String name});
  Future<void> deleteCategory(int id);
}