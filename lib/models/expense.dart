import 'package:hive/hive.dart';

part 'expense.g.dart'; // This line tells Flutter to look for a generated file

@HiveType(typeId: 0) // Assign a unique typeId to your model
class Expense extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String category;

  Expense({
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}