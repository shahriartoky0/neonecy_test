import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../models/transaction_history.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MockTransaction> transactions = TransactionHistoryService.getAll();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, color: AppColors.textWhite, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Assets',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_drop_down, color: AppColors.textWhite, size: 22),
              ],
            ),
            Text(
              'Overall    ',
              style: TextStyle(
                color: AppColors.textGreyLight,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                height: 1.2,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(CupertinoIcons.arrow_down, color: AppColors.textWhite, size: 14),
          ),
          const SizedBox(width: AppSizes.md,)
        ],
      ),
      body: transactions.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHorizontal,
                vertical: AppSizes.sm,
              ),
              itemCount: transactions.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.iconBackground, height: 1, thickness: 0.5),
              itemBuilder: (BuildContext context, int index) {
                return _TransactionTile(tx: transactions[index]);
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

// ── Tile ──────────────────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final MockTransaction tx;

  const _TransactionTile({required this.tx});

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final Color amountColor = tx.isPositive == null
        ? AppColors.textWhite
        : tx.isPositive!
        ? AppColors.green
        : AppColors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Left: type / subtype / date ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  tx.type,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppSizes.fontSizeBodyM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tx.subType != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    tx.subType!,
                    style: const TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: AppSizes.fontSizeBodyS,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  _fmt.format(tx.date),
                  style: const TextStyle(color: AppColors.textGreyLight, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSizes.md),

          // ── Right: amount / subLine1 / subLine2 ──────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                tx.primaryAmount,
                style: TextStyle(
                  color: amountColor,
                  fontSize: AppSizes.fontSizeBodyM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (tx.subLine1 != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  tx.subLine1!,
                  style: const TextStyle(
                    color: AppColors.textGreyLight,
                    fontSize: AppSizes.fontSizeBodyS,
                  ),
                ),
              ],
              if (tx.subLine2 != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  tx.subLine2!,
                  style: const TextStyle(
                    color: AppColors.textGreyLight,
                    fontSize: AppSizes.fontSizeBodyS,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
