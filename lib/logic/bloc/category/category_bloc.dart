// lib/logic/bloc/category/category_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue_pocket/data/models/category_model.dart';
import 'package:blue_pocket/data/repository/financial_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

//               👇 TAMBAHKAN BAGIAN INI 👇
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final FinancialRepository repository;

  // Pastikan super(initialState) dipanggil di constructor
  CategoryBloc({required this.repository}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  void _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) {
    try {
      emit(CategoryLoading());
      final categories = repository.getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await repository.addCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onDeleteCategory(DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await repository.deleteCategory(event.categoryId);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}