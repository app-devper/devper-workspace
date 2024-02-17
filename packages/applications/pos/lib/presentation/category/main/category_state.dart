// Project imports:
import 'package:pos/domain/model/category/category.dart';

abstract class CategoryState {
  CategoryState();
}

class LoadingState extends CategoryState {}

class ListCategoryState extends CategoryState {
  final List<Category> data;

  ListCategoryState({required this.data});
}

class UpdateCategoryState extends CategoryState {
  final Category data;

  UpdateCategoryState({required this.data});
}

class ErrorState extends CategoryState {
  final String message;

  ErrorState({required this.message});
}
