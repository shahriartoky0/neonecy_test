// lib/features/assets/widgets/network_sheet_content.dart
import 'package:flutter/material.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/utils/address_storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Network metadata model
// ─────────────────────────────────────────────────────────────────────────────
class NetworkInfo {
  final String networkKey;
  final String code;
  final String fullName;
  final double fee;
  final double minWithdraw;
  final String arrivalTime;

  const NetworkInfo({
    required this.networkKey,
    required this.code,
    required this.fullName,
    required this.fee,
    required this.minWithdraw,
    required this.arrivalTime,
  });
}

class NetworkMeta {
  static const Map<String, NetworkInfo> _data = <String, NetworkInfo>{
    'BEP20': NetworkInfo(networkKey: 'BEP20', code: 'BSC', fullName: 'BNB Smart Chain (BEP20)', fee: 0.01, minWithdraw: 2.5, arrivalTime: '≈ 1 min'),
    'ERC20': NetworkInfo(networkKey: 'ERC20', code: 'ETH', fullName: 'Ethereum (ERC20)', fee: 5.0, minWithdraw: 10.0, arrivalTime: '≈ 3 mins'),
    'TRC20': NetworkInfo(networkKey: 'TRC20', code: 'TRX', fullName: 'Tron (TRC20)', fee: 1.0, minWithdraw: 10.0, arrivalTime: '≈ 1 min'),
    'Polygon': NetworkInfo(networkKey: 'Polygon', code: 'MATIC', fullName: 'Polygon Network', fee: 0.1, minWithdraw: 2.0, arrivalTime: '≈ 2 mins'),
    'Arbitrum': NetworkInfo(networkKey: 'Arbitrum', code: 'ARB', fullName: 'Arbitrum One', fee: 0.5, minWithdraw: 5.0, arrivalTime: '≈ 2 mins'),
    'Optimism': NetworkInfo(networkKey: 'Optimism', code: 'OP', fullName: 'Optimism', fee: 0.5, minWithdraw: 5.0, arrivalTime: '≈ 2 mins'),
    'Bitcoin': NetworkInfo(networkKey: 'Bitcoin', code: 'BTC', fullName: 'Bitcoin Network', fee: 0.0005, minWithdraw: 0.001, arrivalTime: '≈ 30 mins'),
    'SegWit': NetworkInfo(networkKey: 'SegWit', code: 'BTC', fullName: 'Bitcoin (SegWit)', fee: 0.0003, minWithdraw: 0.001, arrivalTime: '≈ 30 mins'),
    'Ethereum': NetworkInfo(networkKey: 'Ethereum', code: 'ETH', fullName: 'Ethereum Network', fee: 0.002, minWithdraw: 0.01, arrivalTime: '≈ 5 mins'),
    'Solana': NetworkInfo(networkKey: 'Solana', code: 'SOL', fullName: 'Solana Network', fee: 0.00001, minWithdraw: 0.01, arrivalTime: '≈ 1 min'),
    'BEP2': NetworkInfo(networkKey: 'BEP2', code: 'BNB', fullName: 'BNB Beacon Chain (BEP2)', fee: 0.01, minWithdraw: 0.1, arrivalTime: '≈ 1 min'),
    'Ripple': NetworkInfo(networkKey: 'Ripple', code: 'XRP', fullName: 'Ripple Network', fee: 0.25, minWithdraw: 5.0, arrivalTime: '≈ 1 min'),
    'Cardano': NetworkInfo(networkKey: 'Cardano', code: 'ADA', fullName: 'Cardano Network', fee: 0.17, minWithdraw: 5.0, arrivalTime: '≈ 5 mins'),
    'Dogecoin': NetworkInfo(networkKey: 'Dogecoin', code: 'DOGE', fullName: 'Dogecoin Network', fee: 5.0, minWithdraw: 50.0, arrivalTime: '≈ 5 mins'),
    'TON': NetworkInfo(networkKey: 'TON', code: 'TON', fullName: 'TON Network', fee: 0.01, minWithdraw: 1.0, arrivalTime: '≈ 2 mins'),
  };

  static NetworkInfo forNetwork(String key) => _data[key] ??
      NetworkInfo(networkKey: key, code: key.toUpperCase(), fullName: key, fee: 1.0, minWithdraw: 10.0, arrivalTime: '≈ 5 mins');
}

// ─────────────────────────────────────────────────────────────────────────────
// StatefulWidget — tracks selection internally so card highlights immediately
// ─────────────────────────────────────────────────────────────────────────────
class NetworkSheetContent extends StatefulWidget {
  final List<String> networks;
  final String? initialNetwork;   // currently selected network (can be null)
  final String coinSymbol;
  final double coinPrice;         // for fee → local currency conversion
  final AddressStorageService addressService;
  final bool isWithdraw;          // true = show fee/min/arrival; false = show address saved
  final void Function(String networkKey) onSelect;

  const NetworkSheetContent({
    super.key,
    required this.networks,
    required this.initialNetwork,
    required this.coinSymbol,
    required this.coinPrice,
    required this.addressService,
    required this.isWithdraw,
    required this.onSelect,
  });

  @override
  State<NetworkSheetContent> createState() => _NetworkSheetContentState();
}

class _NetworkSheetContentState extends State<NetworkSheetContent> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialNetwork;
  }

  void _onTap(BuildContext context, String net) {
    // 1. Update highlight immediately
    setState(() => _selected = net);

    // 2. Brief pause so user sees the selection flash, then close + notify
    Future.delayed(const Duration(milliseconds: 180), () {
      if (context.mounted) Navigator.of(context).pop();
      widget.onSelect(net);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.iconBackgroundLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Title
        const Padding(
          padding: EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
          child: Text(
            'Choose Network',
            style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Cards
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
            itemCount: widget.networks.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (BuildContext ctx, int i) {
              final String net = widget.networks[i];
              final NetworkInfo info = NetworkMeta.forNetwork(net);
              final bool isSelected = net == _selected;
              final bool hasAddr = widget.addressService
                  .getAddressesForCoinAndNetwork(widget.coinSymbol, net)
                  .isNotEmpty;

              return _NetworkCard(
                info: info,
                coinSymbol: widget.coinSymbol,
                coinPrice: widget.coinPrice,
                isSelected: isSelected,
                hasAddr: hasAddr,
                isWithdraw: widget.isWithdraw,
                onTap: () => _onTap(ctx, net),
              );
            },
          ),
        ),

        // Warning banner
        Container(
          margin: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.sm),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.info_outline, size: 16, color: AppColors.textGreyLight),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ensure the network matches the withdrawal address '
                      'and the deposit platform supports it, or assets may be lost.',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Network card — matches screenshot pixel-perfect
// ─────────────────────────────────────────────────────────────────────────────
class _NetworkCard extends StatelessWidget {
  final NetworkInfo info;
  final String coinSymbol;
  final double coinPrice;
  final bool isSelected;
  final bool hasAddr;
  final bool isWithdraw;
  final VoidCallback onTap;

  const _NetworkCard({
    required this.info,
    required this.coinSymbol,
    required this.coinPrice,
    required this.isSelected,
    required this.hasAddr,
    required this.isWithdraw,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String localFee = (info.fee * coinPrice).toStringAsFixed(2);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          // color: AppColors.iconBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          border: Border.all(
            // ✅ White border when selected — exactly like the screenshot
            color: isSelected ? AppColors.white : AppColors.iconBackgroundLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: '${info.code} ',
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: info.fullName,
                            style: const TextStyle(
                                color: AppColors.textGreyLight,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Show check only on deposit sheet
                  if (!isWithdraw && isSelected)
                    const Icon(Icons.check_circle, color: AppColors.yellow, size: 20)
                  else if (!isWithdraw && hasAddr)
                    const Icon(Icons.check_circle_outline, color: AppColors.green, size: 18),
                ],
              ),
            ),

            const Divider(color: AppColors.iconBackgroundLight, height: 1),

            // ── Details ────────────────────────────────────────────
            if (isWithdraw) ...<Widget>[
              _Row(label: 'Fee', value: '${info.fee} $coinSymbol ( ≈ \$$localFee)'),
              _Row(label: 'Minimum withdrawal', value: '${info.minWithdraw} $coinSymbol'),
              _Row(label: 'Arrival time', value: info.arrivalTime, isLast: true),
            ] else ...<Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.md),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: hasAddr ? AppColors.green : AppColors.textGreyLight.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasAddr ? 'Deposit address saved' : 'No deposit address saved',
                      style: TextStyle(
                        color: hasAddr ? AppColors.green : AppColors.textGreyLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _Row({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, isLast ? AppSizes.md : 0),
    child: RichText(
      text: TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: '$label ',
            style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}