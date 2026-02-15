// lib/features/wallet/views/wallet_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import '../../../core/common/widgets/app_button.dart';
import '../../../core/common/widgets/custom_toast.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
 import '../../assets/model/coin_model.dart';
import '../controllers/wallet_controller.dart';
import '../models/coin_wallet_model.dart';

class WalletView extends StatelessWidget {
  final WalletController _walletController = Get.put(WalletController());

  WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCoinBottomSheet(context);
        },
        backgroundColor: AppColors.yellow,
        child: const Icon(Icons.add, color: AppColors.black),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        foregroundColor: AppColors.white,
        leading: const SizedBox.shrink(),
        title: const Text('My Wallet'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.yellow),
            onPressed: () => _walletController.fetchWalletCoins(),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.yellow),
            onPressed: () => _showAddCoinBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Total Valuation Header
          Obx(() => _buildTotalValuationHeader()),

          // Wallet Coins List
          Expanded(
            child: Obx(() {
              if (_walletController.isLoading.value) {
                return const Center(child: CustomLoading());
              }

              if (_walletController.walletCoins.isEmpty) {
                return _buildEmptyWalletState(context);
              }

              return _buildWalletCoinsList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalValuationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      color: AppColors.bgColor,
      child: Column(
        children: <Widget>[
          const Text(
            'Total Wallet Value',
            style: TextStyle(color: AppColors.textWhite, fontSize: AppSizes.fontSizeBodyM),
          ),
          Text(
            '\$${_walletController.totalValuation.value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.fontSizeH1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            final double totalPnL = _walletController.totalProfitLoss.value;
            final double totalPnLPercent = _walletController.totalProfitLossPercent.value;
            final bool isProfit = totalPnL >= 0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isProfit ? AppColors.green : AppColors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isProfit ? '+' : ''}\$${totalPnL.toStringAsFixed(2)} (${isProfit ? '+' : ''}${totalPnLPercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: isProfit ? AppColors.green : AppColors.red,
                    fontSize: AppSizes.fontSizeBodyS,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyWalletState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomSvgImage(height: 30, assetName: AppIcons.navAsset),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Your wallet is empty',
            style: TextStyle(color: AppColors.textWhite, fontSize: AppSizes.fontSizeBodyL),
          ),
          const SizedBox(height: AppSizes.md),
          AppButton(
            width: context.screenWidth * 0.7,
            labelText: 'Add First Coin',
            onTap: () => _showAddCoinBottomSheet(context),
            bgColor: AppColors.yellow,
            textColor: AppColors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCoinsList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _walletController.walletCoins.length,
      itemBuilder: (BuildContext context, int index) {
        final WalletCoinModel walletCoin = _walletController.walletCoins[index];
        return _buildWalletCoinTile(context, walletCoin);
      },
    );
  }

  Widget _buildWalletCoinTile(BuildContext context, WalletCoinModel walletCoin) {
    final double currentValue = walletCoin.quantity * walletCoin.coinDetails.price;
    final double investedValue = walletCoin.quantity * walletCoin.averagePurchasePrice;
    final double profitLoss = currentValue - investedValue;
    final double profitLossPercent = investedValue > 0 ? ((profitLoss / investedValue) * 100) : 0.0;
    final bool isProfit = profitLoss >= 0;
    final double priceChange24h = walletCoin.coinDetails.percentChange24h;
    final bool isPriceUp = priceChange24h >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Material(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          splashColor: AppColors.yellow.withOpacity(0.3),
          highlightColor: AppColors.yellow.withOpacity(0.2),
          onTap: () => _showCoinDetailsBottomSheet(context, walletCoin),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: <Widget>[
                // Coin Image
                CircleAvatar(
                  backgroundColor: AppColors.iconBackgroundLight,
                  backgroundImage: NetworkImage(walletCoin.coinDetails.thumb),
                  radius: 20,
                ),
                const SizedBox(width: AppSizes.md),

                // Coin Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            walletCoin.coinDetails.symbol,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPriceUp
                                  ? AppColors.greenContainer
                                  : AppColors.redContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  isPriceUp ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 10,
                                  color: isPriceUp ? AppColors.green : AppColors.red,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${isPriceUp ? '+' : ''}${priceChange24h.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: isPriceUp ? AppColors.green : AppColors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${walletCoin.quantity.toStringAsFixed(4)} ${walletCoin.coinDetails.symbol}',
                        style: const TextStyle(
                          color: AppColors.textGreyLight,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current: \$${walletCoin.coinDetails.price.toStringAsFixed(2)} | Avg: \$${walletCoin.averagePurchasePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textGreyLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Value and P&L
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '\$${currentValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isProfit ? AppColors.green : AppColors.red,
                          size: 12,
                        ),
                        Text(
                          '${isProfit ? '+' : ''}\$${profitLoss.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isProfit ? AppColors.green : AppColors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${isProfit ? '+' : ''}${profitLossPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isProfit ? AppColors.green : AppColors.red,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCoinBottomSheet(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final RxString searchQuery = ''.obs;

    showModalBottomSheet(
      backgroundColor: AppColors.bgColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
          ),
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Text(
                  'Add Coin to Wallet',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppSizes.fontSizeH2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Search coins...',
                    hintStyle: const TextStyle(color: AppColors.textGreyLight),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textGreyLight),
                    filled: true,
                    fillColor: AppColors.iconBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String value) {
                    searchQuery.value = value.toLowerCase();
                  },
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Expanded(
                child: Obx(() {
                  final List<CoinItem> filteredCoins = _walletController.availableCoins
                      .where(
                        (CoinItem coin) =>
                    coin.symbol.toLowerCase().contains(searchQuery.value) ||
                        coin.name.toLowerCase().contains(searchQuery.value),
                  )
                      .toList();

                  if (filteredCoins.isEmpty) {
                    return const Center(
                      child: Text(
                        'No coins found',
                        style: TextStyle(color: AppColors.textGreyLight),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredCoins.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CoinItem coin = filteredCoins[index];
                      return _buildCoinSelectionTile(context, coin);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoinSelectionTile(BuildContext context, CoinItem coin) {
    final double priceChange24h = coin.percentChange24h;
    final bool isPriceUp = priceChange24h >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.iconBackgroundLight,
          backgroundImage: NetworkImage(coin.thumb),
        ),
        title: Row(
          children: <Widget>[
            Text(
              coin.symbol,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPriceUp ? AppColors.greenContainer : AppColors.redContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    isPriceUp ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 10,
                    color: isPriceUp ? AppColors.green : AppColors.red,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${isPriceUp ? '+' : ''}${priceChange24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPriceUp ? AppColors.green : AppColors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4),
            Text(
              coin.name,
              style: const TextStyle(
                color: AppColors.textGreyLight,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$${coin.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Rank #${coin.marketCapRank} • ${coin.marketCap}',
              style: const TextStyle(
                color: AppColors.textGreyLight,
                fontSize: 11,
              ),
            ),
          ],
        ),
        onTap: () => _showAddCoinDialog(context, coin),
      ),
    );
  }

  void _showAddCoinDialog(BuildContext context, CoinItem coin) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController(
      text: coin.price.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgColor,
        title: Text(
          'Add ${coin.symbol}',
          style: const TextStyle(color: AppColors.white, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter number of coins',
                  labelStyle: TextStyle(color: AppColors.textGreyLight),
                  hintStyle: TextStyle(color: AppColors.textGreyLight),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textGreyLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.yellow),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  labelText: 'Purchase Price (USD)',
                  hintText: 'Enter average purchase price',
                  labelStyle: TextStyle(color: AppColors.textGreyLight),
                  hintStyle: TextStyle(color: AppColors.textGreyLight),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textGreyLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.yellow),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGreyLight)),
          ),
          AppButton(
            labelText: 'Add',
            onTap: () async {
              final double quantity = double.tryParse(quantityController.text) ?? 0.0;
              final double price = double.tryParse(priceController.text) ?? coin.price;

              if (quantity > 0) {
                // Close dialog first
                Navigator.of(dialogContext).pop();

                // Save the coin
                final bool success = await _walletController.addCoinToWallet(
                  coin: coin,
                  quantity: quantity,
                  averagePurchasePrice: price,
                );

                // Now close the bottom sheet after save completes
                Navigator.of(context).pop();

                // Show toast
                if (success) {
                  ToastManager.show(
                    backgroundColor: AppColors.greenContainer,
                    textColor: AppColors.white,
                    message: '${coin.symbol} added to wallet successfully',
                    icon: const Icon(Icons.check_circle, color: AppColors.green),
                  );
                } else {
                  ToastManager.show(
                    backgroundColor: AppColors.darkRed,
                    textColor: AppColors.white,
                    message: 'Failed to add ${coin.symbol} to wallet',
                    icon: const Icon(Icons.error_outline, color: AppColors.white),
                  );
                }
              } else {
                ToastManager.show(
                  backgroundColor: AppColors.darkRed,
                  textColor: AppColors.white,
                  message: 'Please enter a valid quantity',
                  icon: const Icon(Icons.error_outline, color: AppColors.white),
                );
              }
            },
            bgColor: AppColors.yellow,
            textColor: AppColors.black,
          ),
        ],
      ),
    );
  }

  void _showCoinDetailsBottomSheet(BuildContext context, WalletCoinModel walletCoin) {
    final double currentValue = walletCoin.quantity * walletCoin.coinDetails.price;
    final double investedValue = walletCoin.quantity * walletCoin.averagePurchasePrice;
    final double profitLoss = currentValue - investedValue;
    final double profitLossPercent = investedValue > 0 ? ((profitLoss / investedValue) * 100) : 0.0;
    final bool isProfit = profitLoss >= 0;

    showModalBottomSheet(
      backgroundColor: AppColors.bgColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
      ),
      builder: (BuildContext bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: AppColors.iconBackgroundLight,
                      backgroundImage: NetworkImage(walletCoin.coinDetails.thumb),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${walletCoin.coinDetails.name} (${walletCoin.coinDetails.symbol})',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rank #${walletCoin.coinDetails.marketCapRank}',
                            style: const TextStyle(
                              color: AppColors.textGreyLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                // Holdings Summary
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildDetailRow('Holdings', '${walletCoin.quantity.toStringAsFixed(4)} ${walletCoin.coinDetails.symbol}'),
                      const Divider(color: AppColors.textGreyLight),
                      _buildDetailRow('Current Value', '\$${currentValue.toStringAsFixed(2)}'),
                      _buildDetailRow('Invested Value', '\$${investedValue.toStringAsFixed(2)}'),
                      const Divider(color: AppColors.textGreyLight),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            'Profit/Loss',
                            style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${isProfit ? '+' : ''}\$${profitLoss.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isProfit ? AppColors.green : AppColors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${isProfit ? '+' : ''}${profitLossPercent.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: isProfit ? AppColors.green : AppColors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Market Data
                const Text(
                  'Market Data',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildDetailRow('Current Price', '\$${walletCoin.coinDetails.price.toStringAsFixed(2)}'),
                      _buildDetailRow('24h Change', '${walletCoin.coinDetails.percentChange24h >= 0 ? '+' : ''}${walletCoin.coinDetails.percentChange24h.toStringAsFixed(2)}%',
                          valueColor: walletCoin.coinDetails.percentChange24h >= 0 ? AppColors.green : AppColors.red),
                      _buildDetailRow('Market Cap', walletCoin.coinDetails.marketCap),
                      _buildDetailRow('24h Volume', walletCoin.coinDetails.totalVolume),
                      _buildDetailRow('Price in BTC', walletCoin.coinDetails.priceBtc.toStringAsFixed(8)),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Your Investment
                const Text(
                  'Your Investment',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildDetailRow('Avg Purchase Price', '\$${walletCoin.averagePurchasePrice.toStringAsFixed(2)}'),
                      _buildDetailRow('Total Invested', '\$${investedValue.toStringAsFixed(2)}'),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: AppButton(
                        labelText: 'Edit',
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _showEditCoinBottomSheet(Get.context!, walletCoin);
                        },
                        bgColor: AppColors.yellow,
                        textColor: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: AppButton(
                        labelText: 'Remove',
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _confirmRemoveCoin(context, walletCoin.coinDetails.symbol);
                        },
                        bgColor: AppColors.red,
                        textColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCoinBottomSheet(BuildContext context, WalletCoinModel walletCoin) {
    final TextEditingController quantityController = TextEditingController(
      text: walletCoin.quantity.toString(),
    );
    final TextEditingController priceController = TextEditingController(
      text: walletCoin.averagePurchasePrice.toStringAsFixed(2),
    );

    showModalBottomSheet(

      backgroundColor: AppColors.bgColor,
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
      ),
      builder: (BuildContext bottomSheetContext) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom ,
          left: AppSizes.md,
          right: AppSizes.md,
          top: AppSizes.md,
        ),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: AppSizes.md,),
            Text(
              'Edit ${walletCoin.coinDetails.name}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.fontSizeH2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter number of coins',
                labelStyle: TextStyle(color: AppColors.textGreyLight),
                hintStyle: TextStyle(color: AppColors.textGreyLight),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGreyLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.yellow),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Average Purchase Price (USD)',
                hintText: 'Enter average purchase price',
                labelStyle: TextStyle(color: AppColors.textGreyLight),
                hintStyle: TextStyle(color: AppColors.textGreyLight),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGreyLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.yellow),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
              labelText: 'Update',
              onTap: () async {
                final double quantity = double.tryParse(quantityController.text) ?? 0.0;
                final double price = double.tryParse(priceController.text) ??
                    walletCoin.averagePurchasePrice;

                if (quantity > 0) {
                  Navigator.of(bottomSheetContext).pop();

                  final bool success = await _walletController.updateWalletCoin(
                    symbol: walletCoin.coinDetails.symbol,
                    newQuantity: quantity,
                    newAveragePurchasePrice: price,
                  );

                  if (success) {
                    ToastManager.show(
                      backgroundColor: AppColors.greenContainer,
                      textColor: AppColors.white,
                      message: '${walletCoin.coinDetails.symbol} updated successfully',
                      icon: const Icon(Icons.check_circle, color: AppColors.green),
                    );
                  } else {
                    ToastManager.show(
                      backgroundColor: AppColors.darkRed,
                      textColor: AppColors.white,
                      message: 'Failed to update ${walletCoin.coinDetails.symbol}',
                      icon: const Icon(Icons.error_outline, color: AppColors.white),
                    );
                  }
                } else {
                  ToastManager.show(
                    backgroundColor: AppColors.darkRed,
                    textColor: AppColors.white,
                    message: 'Please enter a valid quantity',
                    icon: const Icon(Icons.error_outline, color: AppColors.white),
                  );
                }
              },
              bgColor: AppColors.yellow,
              textColor: AppColors.black,
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveCoin(BuildContext context, String symbol) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgColor,
        title: const Text('Remove Coin', style: TextStyle(color: AppColors.white)),
        content: const Text(
          'Are you sure you want to remove this coin from your wallet?',
          style: TextStyle(color: AppColors.textGreyLight),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGreyLight)),
          ),
          AppButton(
            labelText: 'Remove',
            onTap: () async {
              Navigator.of(dialogContext).pop();

              final bool success = await _walletController.removeCoinFromWallet(symbol);

              if (success) {
                ToastManager.show(
                  backgroundColor: AppColors.greenContainer,
                  textColor: AppColors.white,
                  message: 'Coin removed from wallet successfully',
                  icon: const Icon(Icons.check_circle, color: AppColors.green),
                );
              } else {
                ToastManager.show(
                  backgroundColor: AppColors.darkRed,
                  textColor: AppColors.white,
                  message: 'Failed to remove coin from wallet',
                  icon: const Icon(Icons.error_outline, color: AppColors.white),
                );
              }
            },
            bgColor: AppColors.textRed,
            textColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}