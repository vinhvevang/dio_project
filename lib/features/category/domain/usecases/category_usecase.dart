import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/category/domain/repositories/category_repository.dart';

class CategoryUseCase {
  final CategoryRepository _repository;

  CategoryUseCase(this._repository);

  Future<List<Category>> loadCategories() => _repository.getCategories();

  Future<int> createCategory({required String name}) =>
      _repository.createCategory(name: name);

  Future<void> updateCategory({required int id, required String name}) =>
      _repository.updateCategory(id: id, name: name);

  Future<void> deleteCategory(int id) => _repository.deleteCategory(id);
}