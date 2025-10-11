import 'package:hive/hive.dart';
part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
  });
}