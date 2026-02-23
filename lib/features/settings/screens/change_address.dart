// lib/features/settings/views/change_address_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/features/assets/controllers/assets_controller.dart';
import 'package:neonecy_test/features/settings/controllers/change_address_controller.dart';
import 'package:neonecy_test/features/settings/model/crypto_address_model.dart';
import 'package:neonecy_test/features/wallet/controllers/wallet_controller.dart';
import '../../../core/common/widgets/custom_toast.dart';
import '../../../core/config/app_sizes.dart';
import '../../assets/model/coin_model.dart';

class ChangeAddressPage extends GetView<ChangeAddressController> {
  const ChangeAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
        centerTitle: true,
        title: Obx(() => Text(
          controller.selectedCoin.value != null
              ? 'Deposit Addresses · ${controller.selectedCoin.value!.symbol}'
              : 'Deposit Addresses',
          style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17),
        )),
        leading: Obx(() => controller.selectedCoin.value != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            controller.selectedCoin.value = null;
            controller.selectedCoinSymbol.value = '';
          },
        )
            : const BackButton(color: AppColors.white)),
        // ── "Manage Networks" action in app bar when coin is selected ──
        actions: [
          Obx(() {
            if (controller.selectedCoin.value == null) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.tune, color: AppColors.white),
              tooltip: 'Manage Networks',
              onPressed: () => _showManageNetworksSheet(
                context,
                controller.selectedCoin.value!,
                controller,
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        final coin = controller.selectedCoin.value;
        if (coin == null) return _CoinPickerView(controller: controller);
        return _AddressManagerView(coin: coin, controller: controller);
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Pick a coin
// ─────────────────────────────────────────────────────────────────────────────
class _CoinPickerView extends StatefulWidget {
  final ChangeAddressController controller;
  const _CoinPickerView({required this.controller});

  @override
  State<_CoinPickerView> createState() => _CoinPickerViewState();
}

class _CoinPickerViewState extends State<_CoinPickerView> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final wc = Get.find<WalletController>();
    final ac = Get.find<AssetsController>();

    return Column(
      children: [
        // Info banner
        Container(
          margin: const EdgeInsets.all(AppSizes.md),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            border: Border.all(color: AppColors.yellow.withOpacity(0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.yellow, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Select a coin and add one receiving address per network. '
                      'Users will scan this as a QR code when depositing.',
                  style: TextStyle(
                      color: AppColors.textGreyLight, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.sm),
          child: TextField(
            controller: _search,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
            onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
            decoration: InputDecoration(
              hintText: 'Search coins...',
              hintStyle: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: AppColors.textGreyLight, size: 20),
              filled: true, fillColor: AppColors.iconBackground,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.yellow, width: 1),
              ),
            ),
          ),
        ),

        // Coin list
        Expanded(
          child: Obx(() {
            final walletCoins = wc.walletCoins.map((w) => w.coinDetails).toList();
            final available = wc.availableCoins.isNotEmpty ? wc.availableCoins : ac.coinItems;
            final extras = available.where((c) => walletCoins.every((w) => w.symbol != c.symbol)).toList();
            final allCoins = [...walletCoins, ...extras];
            final filtered = _query.isEmpty
                ? allCoins
                : allCoins.where((c) =>
            c.symbol.toLowerCase().contains(_query) ||
                c.name.toLowerCase().contains(_query)).toList();

            if (filtered.isEmpty) {
              return const Center(child: Text('No coins found',
                  style: TextStyle(color: AppColors.textGreyLight)));
            }

            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final coin = filtered[i];
                return _CoinListTile(
                  coin: coin,
                  addressCount: widget.controller.addressCountForCoin(coin.symbol),
                  onTap: () => widget.controller.selectCoin(coin),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _CoinListTile extends StatelessWidget {
  final CoinItem coin;
  final int addressCount;
  final VoidCallback onTap;
  const _CoinListTile({required this.coin, required this.addressCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.iconBackgroundLight,
        backgroundImage: coin.thumb.isNotEmpty ? NetworkImage(coin.thumb) : null,
        child: coin.thumb.isEmpty
            ? Text(coin.symbol[0], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold))
            : null,
      ),
      title: Row(
        children: [
          Text(coin.symbol, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 8),
          if (addressCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.greenContainer, borderRadius: BorderRadius.circular(4)),
              child: Text('$addressCount set up',
                  style: const TextStyle(color: AppColors.green, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      subtitle: Text(coin.name, style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textGreyLight, size: 18),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Manage addresses for selected coin
// ─────────────────────────────────────────────────────────────────────────────
class _AddressManagerView extends StatelessWidget {
  final CoinItem coin;
  final ChangeAddressController controller;
  const _AddressManagerView({required this.coin, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Coin header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
          color: AppColors.primaryColor,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.iconBackground,
                backgroundImage: coin.thumb.isNotEmpty ? NetworkImage(coin.thumb) : null,
                child: coin.thumb.isEmpty
                    ? Text(coin.symbol[0], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: AppSizes.md),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(coin.name, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(coin.symbol, style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12)),
              ]),
              const Spacer(),
              // Networks pill — shows count + opens manage sheet
              Obx(() {
                final count = controller.networks.length;
                return GestureDetector(
                  onTap: () => _showManageNetworksSheet(context, coin, controller),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.iconBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.iconBackgroundLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune, color: AppColors.textGreyLight, size: 13),
                        const SizedBox(width: 4),
                        Text('$count networks',
                            style: const TextStyle(color: AppColors.textGreyLight, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Guidance strip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 10),
          color: AppColors.iconBackground,
          child: const Text(
            'One address per network. Tap ⊕ to add, or tap the tune icon to manage networks.',
            style: TextStyle(color: AppColors.textGreyLight, fontSize: 11, height: 1.4),
          ),
        ),

        // Add button
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd)),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: Text('Add ${coin.symbol} Address',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              onPressed: () => _showAddressSheet(context, coin, controller),
            ),
          ),
        ),

        // Address list
        Expanded(
          child: Obx(() {
            final addresses = controller.addresses;
            if (addresses.isEmpty) return _EmptyState(coin: coin);
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (ctx, i) => _AddressCard(
                address: addresses[i],
                onEdit: () => _showAddressSheet(ctx, coin, controller, existing: addresses[i]),
                onDelete: () => _confirmDelete(ctx, addresses[i], controller),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MANAGE NETWORKS SHEET
// Admin can: see all networks, add a custom one, remove existing, reset to defaults
// ─────────────────────────────────────────────────────────────────────────────
void _showManageNetworksSheet(
    BuildContext context,
    CoinItem coin,
    ChangeAddressController controller,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.primaryColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
    ),
    builder: (_) => _ManageNetworksSheet(coin: coin, controller: controller),
  );
}

class _ManageNetworksSheet extends StatefulWidget {
  final CoinItem coin;
  final ChangeAddressController controller;
  const _ManageNetworksSheet({required this.coin, required this.controller});

  @override
  State<_ManageNetworksSheet> createState() => _ManageNetworksSheetState();
}

class _ManageNetworksSheetState extends State<_ManageNetworksSheet> {
  final TextEditingController _networkCtrl = TextEditingController();

  @override
  void dispose() { _networkCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: AppSizes.sm),
              decoration: BoxDecoration(color: AppColors.iconBackgroundLight, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Manage Networks · ${widget.coin.symbol}',
                          style: const TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      const Text('Add or remove supported networks for this coin.',
                          style: TextStyle(color: AppColors.textGreyLight, fontSize: 12)),
                    ],
                  ),
                ),
                // Reset to defaults
                TextButton.icon(
                  onPressed: () {
                    widget.controller.resetNetworksToDefaults();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.restart_alt, size: 14, color: AppColors.textGreyLight),
                  label: const Text('Reset', style: TextStyle(color: AppColors.textGreyLight, fontSize: 12)),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.iconBackground, height: 24),

          // Current networks list (reactive)
          Obx(() {
            final nets = widget.controller.networks;
            if (nets.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                child: Text('No networks configured.',
                    style: TextStyle(color: AppColors.textGreyLight, fontSize: 13)),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: nets.length,
                itemBuilder: (_, i) {
                  final net = nets[i];
                  final hasAddr = widget.controller.addresses
                      .any((a) => a.network.toUpperCase() == net.toUpperCase());
                  return ListTile(
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.iconBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(net,
                          style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    title: hasAddr
                        ? Row(children: [
                      const Icon(Icons.circle, color: AppColors.green, size: 7),
                      const SizedBox(width: 5),
                      const Text('Address saved',
                          style: TextStyle(color: AppColors.green, fontSize: 12)),
                    ])
                        : const Text('No address yet',
                        style: TextStyle(color: AppColors.textGreyLight, fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 18),
                      tooltip: 'Remove network',
                      onPressed: () {
                        _confirmRemoveNetwork(context, net, widget.controller);
                      },
                    ),
                  );
                },
              ),
            );
          }),

          const Divider(color: AppColors.iconBackground),

          // Add new network
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add a network',
                    style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _networkCtrl,
                        style: const TextStyle(color: AppColors.white, fontSize: 14),
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'e.g. TRC20, ERC20, Solana...',
                          hintStyle: TextStyle(color: AppColors.textGreyLight.withOpacity(0.6), fontSize: 13),
                          filled: true,
                          fillColor: AppColors.iconBackground,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                            borderSide: const BorderSide(color: AppColors.yellow, width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd)),
                      ),
                      onPressed: () {
                        final val = _networkCtrl.text.trim();
                        if (val.isEmpty) return;
                        widget.controller.addNetwork(val);
                        _networkCtrl.clear();
                      },
                      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

void _confirmRemoveNetwork(
    BuildContext context,
    String network,
    ChangeAddressController controller,
    ) {
  final hasAddr = controller.addresses.any((a) => a.network.toUpperCase() == network.toUpperCase());
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.primaryColor,
      title: Text('Remove $network?', style: const TextStyle(color: AppColors.white)),
      content: Text(
        hasAddr
            ? 'This will also delete the saved address for $network. Continue?'
            : 'Remove $network from the supported networks list?',
        style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textGreyLight)),
        ),
        TextButton(
          onPressed: () {
            controller.removeNetwork(network);
            Navigator.pop(ctx);
          },
          child: const Text('Remove', style: TextStyle(color: AppColors.red)),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Address form sheet
// ─────────────────────────────────────────────────────────────────────────────
void _showAddressSheet(
    BuildContext context, CoinItem coin, ChangeAddressController controller, {CryptoAddressModel? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.primaryColor,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg))),
    builder: (_) => _AddressFormSheet(coin: coin, controller: controller, existing: existing),
  );
}

class _AddressFormSheet extends StatefulWidget {
  final CoinItem coin;
  final ChangeAddressController controller;
  final CryptoAddressModel? existing;
  const _AddressFormSheet({required this.coin, required this.controller, this.existing});
  @override State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  late TextEditingController _addressCtrl;
  late TextEditingController _labelCtrl;
  late String _selectedNetwork;
  late List<String> _networks;

  @override
  void initState() {
    super.initState();
    _networks = widget.controller.getAvailableNetworks(widget.coin.symbol);
    _selectedNetwork = widget.existing?.network ?? _networks.first;
    _addressCtrl = TextEditingController(text: widget.existing?.address ?? '');
    _labelCtrl   = TextEditingController(text: widget.existing?.label ?? '');
  }

  @override
  void dispose() { _addressCtrl.dispose(); _labelCtrl.dispose(); super.dispose(); }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label, hintText: hint,
    labelStyle: const TextStyle(color: AppColors.textGreyLight, fontSize: 13),
    hintStyle: TextStyle(color: AppColors.textGreyLight.withOpacity(0.5), fontSize: 13),
    filled: true, fillColor: AppColors.iconBackground,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.textGreyLight.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd)),
    focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd)),
  );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSizes.md, right: AppSizes.md, top: AppSizes.md),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.iconBackgroundLight, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: AppSizes.md),
          Text(isEdit ? 'Edit ${widget.coin.symbol} Address' : 'Add ${widget.coin.symbol} Address',
              style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSizes.xs),
          Text(isEdit ? 'Update the receiving address for this network.'
              : 'One address per network — adding the same network again will replace it.',
              style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12, height: 1.5)),
          const SizedBox(height: AppSizes.md),
          // Network dropdown — pulled from controller (includes admin-added ones)
          DropdownButtonFormField<String>(
            dropdownColor: AppColors.iconBackground,
            value: _selectedNetwork,
            decoration: _dec('Network'),
            style: const TextStyle(color: AppColors.white, fontSize: 14),
            iconEnabledColor: AppColors.textGreyLight,
            items: _networks.map((n) => DropdownMenuItem(
                value: n,
                child: Text(n, style: const TextStyle(color: AppColors.white)))).toList(),
            onChanged: (v) { if (v != null) setState(() => _selectedNetwork = v); },
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _addressCtrl,
            style: const TextStyle(color: AppColors.white, fontSize: 13),
            maxLines: 2, minLines: 1,
            decoration: _dec('Wallet Address', hint: 'Paste the receiving wallet address here'),
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _labelCtrl,
            style: const TextStyle(color: AppColors.white, fontSize: 13),
            decoration: _dec('Label (optional)', hint: 'e.g. Main Wallet, Cold Storage'),
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green, foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd)),
              ),
              onPressed: () {
                final addr = _addressCtrl.text.trim();
                if (addr.isEmpty) {
                  ToastManager.show(backgroundColor: AppColors.darkRed,
                      textColor: AppColors.white, message: 'Please enter a wallet address');
                  return;
                }
                Navigator.pop(context);
                if (isEdit) {
                  widget.controller.updateAddress(
                      addressId: widget.existing!.id, network: _selectedNetwork,
                      address: addr,
                      label: _labelCtrl.text.trim().isNotEmpty ? _labelCtrl.text.trim() : null);
                } else {
                  widget.controller.addOrReplaceAddress(
                      network: _selectedNetwork, address: addr,
                      label: _labelCtrl.text.trim().isNotEmpty ? _labelCtrl.text.trim() : null);
                }
              },
              child: Text(isEdit ? 'Update Address' : 'Save Address',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final CoinItem coin;
  const _EmptyState({required this.coin});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.qr_code_2, size: 72, color: AppColors.textGreyLight.withOpacity(0.3)),
        const SizedBox(height: AppSizes.md),
        Text('No ${coin.symbol} addresses yet',
            style: const TextStyle(color: AppColors.textGreyLight, fontSize: 16)),
        const SizedBox(height: AppSizes.sm),
        Text('Add a receiving address for each network.\nUsers will send ${coin.symbol} to this address.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGreyLight.withOpacity(0.6), fontSize: 12, height: 1.5)),
      ]),
    ),
  );
}

class _AddressCard extends StatelessWidget {
  final CryptoAddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _AddressCard({required this.address, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        border: Border.all(color: AppColors.iconBackgroundLight, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.iconBackgroundLight, borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm)),
            child: Text(address.network,
                style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          if (address.label != null) ...[
            const SizedBox(width: 8),
            Expanded(child: Text(address.label!,
                style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12), overflow: TextOverflow.ellipsis)),
          ] else const Spacer(),
          IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.textGreyLight, size: 18),
              onPressed: onEdit, tooltip: 'Edit', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: AppSizes.md),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 18),
              onPressed: onDelete, tooltip: 'Delete', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
        const SizedBox(height: AppSizes.sm),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(address.address,
              style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12, height: 1.5, letterSpacing: 0.3))),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: address.address));
              ToastManager.show(backgroundColor: AppColors.greenContainer,
                  textColor: AppColors.white, message: 'Address copied');
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.iconBackgroundLight,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm)),
              child: const Icon(Icons.copy_outlined, color: AppColors.textGreyLight, size: 14),
            ),
          ),
        ]),
      ]),
    );
  }
}

void _confirmDelete(BuildContext context, CryptoAddressModel address, ChangeAddressController controller) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    backgroundColor: AppColors.primaryColor,
    title: const Text('Delete Address', style: TextStyle(color: AppColors.white)),
    content: Text('Remove this ${address.network} address?\n\n${address.address}',
        style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13, height: 1.4)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textGreyLight))),
      TextButton(
          onPressed: () { controller.removeAddress(address.id); Navigator.pop(ctx); },
          child: const Text('Delete', style: TextStyle(color: AppColors.red))),
    ],
  ));
}