import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Change this to your own currency symbol if you like.
const String kCurrencySymbol = '\$';

const String kIncome = 'Income';
const String kExpense = 'Expense';

const Color kPrimaryColor = Color(0xFF3F51B5);
const Color kIncomeColor = Color(0xFF2E7D32);
const Color kExpenseColor = Color(0xFFD32F2F);

const List<String> kIncomeCategories = [
  'Salary',
  'Freelance',
  'Business',
  'Investment',
  'Gift',
  'Other',
];

const List<String> kExpenseCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Health',
  'Entertainment',
  'Education',
  'Other',
];

const Map<String, IconData> kCategoryIcons = {
  'Salary': Icons.payments,
  'Freelance': Icons.laptop_mac,
  'Business': Icons.storefront,
  'Investment': Icons.trending_up,
  'Gift': Icons.card_giftcard,
  'Food': Icons.restaurant,
  'Transport': Icons.directions_car,
  'Shopping': Icons.shopping_bag,
  'Bills': Icons.receipt_long,
  'Health': Icons.favorite,
  'Entertainment': Icons.movie,
  'Education': Icons.school,
  'Other': Icons.category,
};

/// Returns the category list that matches the selected transaction type.
List<String> categoriesFor(String? type) {
  if (type == kIncome) return kIncomeCategories;
  if (type == kExpense) return kExpenseCategories;
  return const [];
}

/// 1234.5 -> "$1,234.50", -20 -> "-$20.00"
String formatMoney(double value) {
  final sign = value < 0 ? '-' : '';
  return '$sign$kCurrencySymbol${NumberFormat('#,##0.00').format(value.abs())}';
}

/// DateTime -> "05 Nov 2026"
String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);