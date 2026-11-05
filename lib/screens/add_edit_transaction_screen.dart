import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';

/// Used for both adding a new transaction and editing an existing one.
/// Pops with the saved [TransactionModel] on success.
class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  String? _type;
  String? _category;
  late DateTime _date;
  bool _typeError = false;
  bool _saving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _titleController = TextEditingController(text: t?.title ?? '');
    _amountController = TextEditingController(
      text: t == null
          ? ''
          : (t.amount % 1 == 0 ? t.amount.toInt().toString() : t.amount.toString()),
    );
    _type = t?.type;
    _category = t?.category;
    _date = t?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectType(String type) {
    setState(() {
      _type = type;
      _typeError = false;
      // Reset category if it does not belong to the new type.
      if (!categoriesFor(type).contains(_category)) {
        _category = null;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    setState(() => _typeError = _type == null);
    if (!formValid || _type == null) return;

    setState(() => _saving = true);

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: double.tryParse(_amountController.text.trim())!,
      category: _category!,
      type: _type!,
      date: _date,
    );

    TransactionModel saved;
    if (_isEditing) {
      await DatabaseHelper.instance.updateTransaction(transaction);
      saved = transaction;
    } else {
      final id = await DatabaseHelper.instance.insertTransaction(transaction);
      saved = transaction.copyWith(id: id);
    }

    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  InputDecoration _decoration(String label, IconData icon) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
    );
  }

  Widget _typeOption(String type, IconData icon, Color color) {
    final selected = _type == type;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _selectType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? color
                  : (_typeError ? kExpenseColor : Colors.grey.shade300),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : color),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoriesFor(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Transaction type ----------
              Text(
                'Transaction Type',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _typeOption(kIncome, Icons.arrow_downward, kIncomeColor),
                  const SizedBox(width: 12),
                  _typeOption(kExpense, Icons.arrow_upward, kExpenseColor),
                ],
              ),
              if (_typeError)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    'Please select a transaction type',
                    style: TextStyle(color: kExpenseColor, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              // ---------- Title ----------
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration('Title', Icons.title),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---------- Amount ----------
              TextFormField(
                controller: _amountController,
                textInputAction: TextInputAction.done,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: _decoration('Amount', Icons.payments_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value.trim());
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---------- Category (DropdownButton) ----------
              FormField<String>(
                key: ValueKey('category-$_type'),
                initialValue: _category,
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
                builder: (state) {
                  return InputDecorator(
                    isEmpty: false,
                    decoration: _decoration('Category', Icons.category_outlined)
                        .copyWith(
                      errorText: state.errorText,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.value,
                        isExpanded: true,
                        isDense: true,
                        hint: Text(
                          _type == null
                              ? 'Select transaction type first'
                              : 'Select category',
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem<String>(
                                  value: c,
                                  child: Row(
                                    children: [
                                      Icon(kCategoryIcons[c] ?? Icons.category,
                                          size: 20, color: Colors.grey.shade700),
                                      const SizedBox(width: 10),
                                      Text(c),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: _type == null
                            ? null
                            : (value) {
                                state.didChange(value);
                                setState(() => _category = value);
                              },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // ---------- Date picker ----------
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration:
                      _decoration('Date', Icons.calendar_today_outlined).copyWith(
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(
                    formatDate(_date),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ---------- Save button ----------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: Text(
                    _isEditing ? 'Update Transaction' : 'Save Transaction',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}