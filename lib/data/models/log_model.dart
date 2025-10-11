import 'package:hive/hive.dart';

part 'log_model.g.dart';

@HiveType(typeId: 3)
class LogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String action;

  @HiveField(2)
  final String details;

  @HiveField(3)
  final DateTime timestamp;

  LogModel({
    required this.id,
    required this.action,
    required this.details,
    required this.timestamp,
  });
}