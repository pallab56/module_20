import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Large white card showing the current balance (used inside the header).
class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final isNegative = balance < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatMoney(balance),
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: isNegative ? kExpenseColor : kIncomeColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isNegative
                ? 'You are spending more than you earn'
                : 'Total income minus total expenses',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}