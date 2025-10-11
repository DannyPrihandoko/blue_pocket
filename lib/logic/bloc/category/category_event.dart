part of 'category_bloc.dart';

abstract class CategoryEvent {}

// Event untuk memuat semua kategori dari database
class LoadCategories extends CategoryEvent {}

// Event untuk menambahkan kategori baru
class AddCategory extends CategoryEvent {
  final CategoryModel category;
  AddCategory(this.category);
}

// Event untuk menghapus kategori
class DeleteCategory extends CategoryEvent {
  final String categoryId;
  DeleteCategory(this.categoryId);
}