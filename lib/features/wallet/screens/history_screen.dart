import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';

class MockTransaction {
  final String type;
  final String coinSymbol;
  final String coinName;
  final double amount;
  final double usdValue;
  final DateTime date;
  final String status;
  final String? networkName;

  const MockTransaction({
    required this.type,
    required this.coinSymbol,
    required this.coinName,
    required this.amount,
    required this.usdValue,
    required this.date,
    required this.status,
    this.networkName,
  });

  bool get isCredit => type == 'Buy' || type == 'Receive';
  bool get isCompleted => status == 'Completed';
}

final List<MockTransaction> _kMockTransactions = <MockTransaction>[
  MockTransaction(
    type: 'Buy',
    coinSymbol: 'BTC',
    coinName: 'Bitcoin',
    amount: 0.00215,
    usdValue: 140.28,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    status: 'Completed',
    networkName: 'Bitcoin',
  ),
  MockTransaction(
    type: 'Send',
    coinSymbol: 'ETH',
    coinName: 'Ethereum',
    amount: 0.5,
    usdValue: 1650.00,
    date: DateTime.now().subtract(const Duration(hours: 8)),
    status: 'Completed',
    networkName: 'ERC-20',
  ),
  MockTransaction(
    type: 'Receive',
    coinSymbol: 'USDT',
    coinName: 'Tether',
    amount: 500.0,
    usdValue: 500.0,
    date: DateTime.now().subtract(const Duration(days: 1)),
    status: 'Completed',
    networkName: 'TRC-20',
  ),
  MockTransaction(
    type: 'Sell',
    coinSymbol: 'BNB',
    coinName: 'BNB',
    amount: 1.2,
    usdValue: 710.40,
    date: DateTime.now().subtract(const Duration(days: 2)),
    status: 'Completed',
    networkName: 'BEP-20',
  ),
  MockTransaction(
    type: 'Buy',
    coinSymbol: 'SOL',
    coinName: 'Solana',
    amount: 3.5,
    usdValue: 560.70,
    date: DateTime.now().subtract(const Duration(days: 3)),
    status: 'Completed',
    networkName: 'Solana',
  ),
  MockTransaction(
    type: 'Receive',
    coinSymbol: 'BTC',
    coinName: 'Bitcoin',
    amount: 0.001,
    usdValue: 65.13,
    date: DateTime.now().subtract(const Duration(days: 4)),
    status: 'Completed',
    networkName: 'Bitcoin',
  ),
  MockTransaction(
    type: 'Send',
    coinSymbol: 'USDT',
    coinName: 'Tether',
    amount: 200.0,
    usdValue: 200.0,
    date: DateTime.now().subtract(const Duration(days: 5)),
    status: 'Pending',
    networkName: 'ERC-20',
  ),
  MockTransaction(
    type: 'Sell',
    coinSymbol: 'ADA',
    coinName: 'Cardano',
    amount: 150.0,
    usdValue: 67.50,
    date: DateTime.now().subtract(const Duration(days: 6)),
    status: 'Completed',
    networkName: 'Cardano',
  ),
  MockTransaction(
    type: 'Buy',
    coinSymbol: 'DOGE',
    coinName: 'Dogecoin',
    amount: 2000.0,
    usdValue: 320.00,
    date: DateTime.now().subtract(const Duration(days: 7)),
    status: 'Completed',
    networkName: 'Dogecoin',
  ),
  MockTransaction(
    type: 'Receive',
    coinSymbol: 'ETH',
    coinName: 'Ethereum',
    amount: 0.25,
    usdValue: 825.00,
    date: DateTime.now().subtract(const Duration(days: 10)),
    status: 'Completed',
    networkName: 'ERC-20',
  ),
];

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: AppSizes.fontSizeH3,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textWhite, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: _kMockTransactions.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHorizontal,
                vertical: AppSizes.md,
              ),
              itemCount: _kMockTransactions.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.iconBackground,
                height: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _TransactionTile(tx: _kMockTransactions[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppColors.textGreyLight.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: AppColors.textGreyLight.withValues(alpha: 0.7),
              fontSize: AppSizes.fontSizeBodyM,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final MockTransaction tx;

  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final Color typeColor = _typeColor(tx.type);
    final Color statusColor = tx.isCompleted ? AppColors.green : AppColors.orange;
    final String sign = tx.isCredit ? '+' : '-';
    final String formattedDate = DateFormat('MMM dd, yyyy · HH:mm').format(tx.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(_typeIcon(tx.type), color: typeColor, size: 20),
            ),
          ),

          const SizedBox(width: AppSizes.md),

          // Middle info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      tx.type,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: AppSizes.fontSizeBodyM,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      tx.coinSymbol,
                      style: const TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyM,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: AppColors.textGreyLight,
                    fontSize: AppSizes.fontSizeBodyS,
                  ),
                ),
                if (tx.networkName != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    tx.networkName!,
                    style: const TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Right: amount + USD + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '$sign${_formatAmount(tx.amount)} ${tx.coinSymbol}',
                style: TextStyle(
                  color: tx.isCredit ? AppColors.green : AppColors.red,
                  fontSize: AppSizes.fontSizeBodyM,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '\$${tx.usdValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.textGreyLight,
                  fontSize: AppSizes.fontSizeBodyS,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Buy':
        return Icons.shopping_cart_outlined;
      case 'Sell':
        return Icons.sell_outlined;
      case 'Receive':
        return Icons.call_received_rounded;
      case 'Send':
        return Icons.call_made_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Buy':
      case 'Receive':
        return AppColors.green;
      case 'Sell':
      case 'Send':
        return AppColors.red;
      default:
        return AppColors.textGreyLight;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) return amount.toStringAsFixed(2);
    if (amount >= 1) return amount.toStringAsFixed(4);
    if (amount >= 0.0001) return amount.toStringAsFixed(6);
    return amount.toStringAsFixed(8);
  }
}