// trading_controller.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// trading_models.dart
class OrderBookEntry {
  final double price;
  final double amount;
  final double total;

  OrderBookEntry({
    required this.price,
    required this.amount,
    required this.total,
  });

  factory OrderBookEntry.fromJson(Map<String, dynamic> json) {
    return OrderBookEntry(
      price: double.parse(json['price'].toString()),
      amount: double.parse(json['amount'].toString()),
      total: double.parse(json['total'].toString()),
    );
  }
}

class TradingPair {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final double currentPrice;
  final double change24h;
  final double changePercent24h;

  TradingPair({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.currentPrice,
    required this.change24h,
    required this.changePercent24h,
  });
}



class TradingController extends GetxController {
  // Current trading pair
  var currentPair = TradingPair(
    symbol: 'BTCUSDT',
    baseAsset: 'BTC',
    quoteAsset: 'USDT',
    currentPrice: 104609.4,
    change24h: -1036.2,
    changePercent24h: -0.99,
  ).obs;

  // Order book data
  var sellOrders = <OrderBookEntry>[].obs;
  var buyOrders = <OrderBookEntry>[].obs;

  // Selected price and amount
  var selectedPrice = 0.0.obs;
  var selectedAmount = 0.0.obs;
  var selectedTotal = 0.0.obs;

  // Loading state
  var isLoading = false.obs;

  // Timer for price updates
  Timer? _priceUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    loadOrderBook();
    startPriceUpdates();
  }

  @override
  void onClose() {
    _priceUpdateTimer?.cancel();
    super.onClose();
  }

  void loadOrderBook() {
    isLoading.value = true;

    // Generate mock sell orders (higher prices)
    sellOrders.value = List.generate(10, (index) {
      double basePrice = currentPair.value.currentPrice + (index + 1) * 0.1;
      double amount = (Random().nextDouble() * 0.5) + 0.001;
      return OrderBookEntry(
        price: basePrice,
        amount: amount,
        total: basePrice * amount,
      );
    }).reversed.toList();

    // Generate mock buy orders (lower prices)
    buyOrders.value = List.generate(15, (index) {
      double basePrice = currentPair.value.currentPrice - (index + 1) * 0.1;
      double amount = (Random().nextDouble() * 0.5) + 0.001;
      return OrderBookEntry(
        price: basePrice,
        amount: amount,
        total: basePrice * amount,
      );
    });

    isLoading.value = false;
  }

  void startPriceUpdates() {
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updatePrices();
    });
  }

  void updatePrices() {
    // Simulate price fluctuations
    Random random = Random();
    double priceChange = (random.nextDouble() - 0.5) * 10; // -5 to +5

    var updatedPair = TradingPair(
      symbol: currentPair.value.symbol,
      baseAsset: currentPair.value.baseAsset,
      quoteAsset: currentPair.value.quoteAsset,
      currentPrice: currentPair.value.currentPrice + priceChange,
      change24h: currentPair.value.change24h + priceChange,
      changePercent24h: ((currentPair.value.currentPrice + priceChange - 105645.6) / 105645.6) * 100,
    );

    currentPair.value = updatedPair;

    // Update order book with new prices
    updateOrderBook();
  }

  void updateOrderBook() {
    // Update sell orders
    for (int i = 0; i < sellOrders.length; i++) {
      double newPrice = currentPair.value.currentPrice + (i + 1) * 0.1;
      sellOrders[i] = OrderBookEntry(
        price: newPrice,
        amount: sellOrders[i].amount,
        total: newPrice * sellOrders[i].amount,
      );
    }

    // Update buy orders
    for (int i = 0; i < buyOrders.length; i++) {
      double newPrice = currentPair.value.currentPrice - (i + 1) * 0.1;
      buyOrders[i] = OrderBookEntry(
        price: newPrice,
        amount: buyOrders[i].amount,
        total: newPrice * buyOrders[i].amount,
      );
    }
  }

  void selectOrderEntry(OrderBookEntry entry) {
    selectedPrice.value = entry.price;
    selectedAmount.value = entry.amount;
    selectedTotal.value = entry.total;
  }

  void clearSelection() {
    selectedPrice.value = 0.0;
    selectedAmount.value = 0.0;
    selectedTotal.value = 0.0;
  }

  String formatPrice(double price) {
    return price.toStringAsFixed(1);
  }

  String formatAmount(double amount) {
    return amount.toStringAsFixed(3);
  }

  Color getPriceColor(double price) {
    return price >= currentPair.value.currentPrice
        ? const Color(0xFFFF6B6B) // Red for sell orders
        : const Color(0xFF4ECDC4); // Green for buy orders
  }

  bool get isPositiveChange => currentPair.value.changePercent24h >= 0;
}



class TradingPanelWidget extends StatelessWidget {
  final TradingController controller = Get.put(TradingController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 600,
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildOrderBook();
            }),
          ),
          _buildSelectedOrder(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              Text(
                'Amount',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    controller.formatPrice(controller.currentPair.value.currentPrice),
                    style: TextStyle(
                      color: controller.isPositiveChange ? Colors.green : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${controller.currentPair.value.changePercent24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: controller.isPositiveChange ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildOrderBook() {
    return Column(
      children: [
        // Sell orders (red)
        Expanded(
          flex: 1,
          child: ListView.builder(
            reverse: true,
            itemCount: controller.sellOrders.length,
            itemBuilder: (context, index) {
              final order = controller.sellOrders[index];
              return _buildOrderRow(order, isAsk: true);
            },
          ),
        ),

        // Current price separator
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.formatPrice(controller.currentPair.value.currentPrice),
                style: TextStyle(
                  color: controller.isPositiveChange ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                controller.isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward,
                color: controller.isPositiveChange ? Colors.green : Colors.red,
                size: 16,
              ),
            ],
          ),
        )),

        // Buy orders (green)
        Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: controller.buyOrders.length,
            itemBuilder: (context, index) {
              final order = controller.buyOrders[index];
              return _buildOrderRow(order, isAsk: false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderRow(OrderBookEntry order, {required bool isAsk}) {
    return Obx(() => InkWell(
      onTap: () => controller.selectOrderEntry(order),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: controller.selectedPrice.value == order.price
              ? Colors.blue.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.formatPrice(order.price),
              style: TextStyle(
                color: isAsk ? Colors.red[400] : Colors.green[400],
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              controller.formatAmount(order.amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSelectedOrder() {
    return Obx(() {
      if (controller.selectedPrice.value == 0.0) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
            top: BorderSide(color: Colors.grey[700]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Order',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price: ${controller.formatPrice(controller.selectedPrice.value)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Amount: ${controller.formatAmount(controller.selectedAmount.value)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Total: ${controller.selectedTotal.value.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: controller.clearSelection,
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}


