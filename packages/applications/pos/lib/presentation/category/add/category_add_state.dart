// Project imports:
import 'package:pos/domain/model/category/category.dart';

abstract class CategoryAddState {
  CategoryAddState();
}

class LoadingState extends CategoryAddState {}

class CreateCategoryState extends CategoryAddState {
  final Category data;

  CreateCategoryState({required this.data});
}

class ErrorState extends CategoryAddState {
  final String message;

  ErrorState({required this.message});
}
