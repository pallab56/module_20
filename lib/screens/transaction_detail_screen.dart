import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/delete_confirm_dialog.dart';
import 'add_edit_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late TransactionModel _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<TransactionModel>(
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(transaction: _transaction),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _transaction = updated);
    }
  }

  Future<void> _delete() async {
    final confirmed =
        await showDeleteConfirmDialog(context, _transaction.title);
    if (!confirmed) return;

    await DatabaseHelper.instance.deleteTransaction(_transaction.id!);
    if (!mounted) return;
    Navigator.of(context).pop(true); // true = deleted
  }

  @override
  Widget build(BuildContext context) {
    final t = _transaction;
    final sign = t.isIncome ? '+' : '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------- Top summary card ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: t.isIncome
                      ? const [Color(0xFF2E7D32), Color(0xFF66BB6A)]
                      : const [Color(0xFFC62828), Color(0xFFEF5350)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      kCategoryIcons[t.category] ?? Icons.category,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$sign${formatMoney(t.amount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---------- Full details ----------
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _DetailRow(
                        icon: Icons.title, label: 'Title', value: t.title),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _DetailRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: t.category),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _DetailRow(
                        icon: Icons.swap_vert,
                        label: 'Transaction Type',
                        value: t.type),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: formatDate(t.date)),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _DetailRow(
                        icon: Icons.payments_outlined,
                        label: 'Amount',
                        value: formatMoney(t.amount)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---------- Edit / Delete ----------
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kExpenseColor,
                      side: const BorderSide(color: kExpenseColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _edit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFFE8EAF6),
        child: Icon(icon, size: 20, color: kPrimaryColor),
      ),
      title: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}