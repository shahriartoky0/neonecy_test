// lib/features/wallet/views/wallet_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import '../../../core/common/widgets/app_button.dart';
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
        child: const Icon(Icons.add, color: AppColors.yellow),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        foregroundColor: AppColors.white,
        leading: const SizedBox.shrink(),
        title: const Text('My Wallet'),
        actions: <Widget>[
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
                // return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
                return const Center(child:CustomLoading());
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
        ],
      ),
    );
  }

  Widget _buildEmptyWalletState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomSvgImage(
              height: 30,
              assetName: AppIcons.navAsset),
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
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm, horizontal: AppSizes.md),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: AppColors.iconBackgroundLight,
                  backgroundImage: NetworkImage(walletCoin.coinDetails.thumb),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${walletCoin.coinDetails.symbol} - ${walletCoin.quantity} coins',
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildCoinDetailsRow(walletCoin),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Text(
                      'Total Value',
                      style: TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyS,
                      ),
                    ),
                    Text(
                      '\$${(walletCoin.quantity * walletCoin.coinDetails.price).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
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

  Widget _buildCoinDetailsRow(WalletCoinModel walletCoin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.textGreyLight),
            children: <InlineSpan>[
              const TextSpan(text: 'Price: '),
              TextSpan(
                text: '\$${walletCoin.coinDetails.price.toStringAsFixed(2)}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.textGreyLight),
            children: <InlineSpan>[
              const TextSpan(text: 'Price in BTC: '),
              TextSpan(
                text: walletCoin.coinDetails.priceBtc.toStringAsFixed(8),
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
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
          height: MediaQuery.of(context).size.height * 0.75, // Limit to 75% of screen height
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
        title: Text(coin.symbol, style: const TextStyle(color: AppColors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textGreyLight),
                children: <InlineSpan>[
                  const TextSpan(text: 'Price: '),
                  TextSpan(
                    text: '\$${coin.price.toStringAsFixed(2)} (in USD)',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textGreyLight),
                children: <InlineSpan>[
                  const TextSpan(text: 'Price in Bitcoin : '),
                  TextSpan(
                    text: '\$${coin.priceBtc.toStringAsFixed(2)} ',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textGreyLight),
                children: <InlineSpan>[
                  const TextSpan(text: 'Market Cap Rank: '),
                  TextSpan(
                    text: coin.marketCapRank.toString(),
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
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
          style: const TextStyle(color: AppColors.white, fontSize: 14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter number of coins',
                labelStyle: TextStyle(color: AppColors.textGreyLight),
                hintStyle: TextStyle(color: AppColors.textGreyLight),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGreyLight),
                ),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.yellow)),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Purchase Price',
                hintText: 'Enter average purchase price',
                labelStyle: TextStyle(color: AppColors.textGreyLight),
                hintStyle: TextStyle(color: AppColors.textGreyLight),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGreyLight),
                ),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.yellow)),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGreyLight)),
          ),
          AppButton(
            labelText: 'Add',
            onTap: () {
              final double quantity = double.tryParse(quantityController.text) ?? 0.0;
              final double price = double.tryParse(priceController.text) ?? coin.price;

              if (quantity > 0) {
                _walletController.addCoinToWallet(
                  coin: coin,
                  quantity: quantity,
                  averagePurchasePrice: price,
                );
                Navigator.of(dialogContext).pop();
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
    showModalBottomSheet(
      backgroundColor: AppColors.bgColor,
      context: context,
      builder: (BuildContext bottomSheetContext) => Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${walletCoin.coinDetails.name} (${walletCoin.coinDetails.symbol}) Details',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.fontSizeH2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _buildDetailRow('Market Cap', walletCoin.coinDetails.marketCap),
            _buildDetailRow('Total Volume', walletCoin.coinDetails.totalVolume),
            _buildDetailRow('Market Cap Rank', walletCoin.coinDetails.marketCapRank.toString()),
            _buildDetailRow(
              'Current Price',
              '\$${walletCoin.coinDetails.price.toStringAsFixed(2)}',
            ),
            _buildDetailRow('Price in BTC', walletCoin.coinDetails.priceBtc.toStringAsFixed(8)),
            const SizedBox(height: AppSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    labelText: 'Edit Coin',
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _showEditCoinBottomSheet(context, walletCoin);
                    },
                    bgColor: AppColors.yellow,
                    textColor: AppColors.black,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: AppButton(
                    labelText: 'Remove Coin',
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textGreyLight)),
          Text(value, style: const TextStyle(color: AppColors.white)),
        ],
      ),
    );
  }

  void _showEditCoinBottomSheet(BuildContext context, WalletCoinModel walletCoin) {
    final TextEditingController quantityController = TextEditingController(
      text: walletCoin.quantity.toString(),
    );
    final TextEditingController priceController = TextEditingController(
      text: walletCoin.coinDetails.price.toStringAsFixed(2),
    );

    showModalBottomSheet(
      backgroundColor: AppColors.bgColor,
      context: context,
      builder: (BuildContext bottomSheetContext) => Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Edit ${walletCoin.coinDetails.symbol}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.fontSizeH2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter number of coins',
                labelStyle: TextStyle(color: AppColors.textGreyLight),
                hintStyle: TextStyle(color: AppColors.textGreyLight),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGreyLight),
                ),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.yellow)),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Average Purchase Price',
                hintText: 'Enter average purchase price',
                labelStyle: TextStyle(color: AppColors.textGreyLight),
                hintStyle: TextStyle(color: AppColors.textGreyLight),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGreyLight),
                ),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.yellow)),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              labelText: 'Update',
              onTap: () {
                final double quantity = double.tryParse(quantityController.text) ?? 0.0;
                final double price =
                    double.tryParse(priceController.text) ?? walletCoin.coinDetails.price;

                _walletController.updateWalletCoin(
                  symbol: walletCoin.coinDetails.symbol,
                  newQuantity: quantity,
                  newAveragePurchasePrice: price,
                );

                Navigator.of(bottomSheetContext).pop();
              },
              bgColor: AppColors.yellow,
              textColor: AppColors.black,
            ),
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
            onTap: () {
              _walletController.removeCoinFromWallet(symbol);
              Navigator.of(dialogContext).pop();
            },
            bgColor: AppColors.textRed,
            textColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
