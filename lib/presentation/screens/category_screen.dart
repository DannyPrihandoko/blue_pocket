import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue_pocket/data/models/category_model.dart';
import 'package:blue_pocket/logic/bloc/category/category_bloc.dart';
import 'package:uuid/uuid.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading || state is CategoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return const Center(
                child: Text('Belum ada kategori. Tambahkan satu!'),
              );
            }
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(category.colorValue),
                      child: const Icon(Icons.category, color: Colors.white),
                    ),
                    title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        // Kirim event untuk menghapus kategori
                        context.read<CategoryBloc>().add(DeleteCategory(category.id));
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Terjadi kesalahan'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final uuid = const Uuid(); // Can be const if you import 'package:uuid/uuid.dart';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori',
              hintText: 'Contoh: Makanan',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Check if the input is not empty
                if (nameController.text.isNotEmpty) {
                  // CORRECTED BLOCK STARTS HERE
                  final newCategory = CategoryModel(
                    id: uuid.v4(),
                    name: nameController.text, // Fix 1: Added 'name' parameter
                    colorValue: Colors.primaries[nameController.text.length % Colors.primaries.length].value, // Fix 2: Added 'colorValue'
                  );

                  // Fix 3: Use the 'newCategory' variable by dispatching the event
                  context.read<CategoryBloc>().add(AddCategory(newCategory));
                  
                  // Close the dialog after saving
                  Navigator.pop(dialogContext);
                  // CORRECTED BLOCK ENDS HERE
                }
              }, // Fix 4: Ensure all braces are correctly closed
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}