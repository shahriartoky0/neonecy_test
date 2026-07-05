import 'dart:convert';

import '../../../core/utils/get_storage.dart';

// ── Model (shared by HistoryScreen and TransactionHistoryService) ─────────────

class MockTransaction {
  final String type;
  final String? subType;
  final DateTime date;
  final String primaryAmount;
  // true=green, false=red, null=white (Transfer / neutral)
  final bool? isPositive;
  final String? subLine1;
  final String? subLine2;
  // Extra raw data used to rebuild slips (withdraw / convert details).
  final Map<String, dynamic>? details;

  const MockTransaction({
    required this.type,
    this.subType,
    required this.date,
    required this.primaryAmount,
    required this.isPositive,
    this.subLine1,
    this.subLine2,
    this.details,
  });

  Map<String, dynamic> _toMap() => <String, dynamic>{
        'type': type,
        'subType': subType,
        'date': date.toIso8601String(),
        'primaryAmount': primaryAmount,
        'isPositive': isPositive,
        'subLine1': subLine1,
        'subLine2': subLine2,
        'details': details,
      };

  factory MockTransaction._fromMap(Map<String, dynamic> m) => MockTransaction(
        type: m['type'] as String,
        subType: m['subType'] as String?,
        date: DateTime.parse(m['date'] as String),
        primaryAmount: m['primaryAmount'] as String,
        isPositive: m['isPositive'] as bool?,
        subLine1: m['subLine1'] as String?,
        subLine2: m['subLine2'] as String?,
        details: m['details'] is Map
            ? Map<String, dynamic>.from(m['details'] as Map)
            : null,
      );
}

// ── Service ───────────────────────────────────────────────────────────────────

class TransactionHistoryService {
  static const String _key = 'transaction_history';
  static final GetStorageModel _storage = GetStorageModel();

  /// Log a Convert (instant swap) trade — called from TradeController.
  static Future<void> logConvert({
    required String fromSymbol,
    required String toSymbol,
    required double fromAmount,
    required double toAmount,
  }) async {
    await _append(MockTransaction(
      type: 'Convert',
      subType: 'Instant',
      date: DateTime.now(),
      primaryAmount: '+${_fmt(toAmount)} $toSymbol',
      isPositive: true,
      subLine1: '-${_fmt(fromAmount)} $fromSymbol',
      subLine2: 'Success',
      details: <String, dynamic>{
        'fromSymbol': fromSymbol,
        'toSymbol': toSymbol,
        'fromAmount': _fmt(fromAmount),
        'toAmount': _fmt(toAmount),
      },
    ));
  }

  /// Log a Withdraw — called from WalletController.
  static Future<void> logWithdraw({
    required String symbol,
    required double amount,
    String? network,
    String? address,
    String? txid,
    double? fee,
    double? receiveAmount,
  }) async {
    await _append(MockTransaction(
      type: 'Withdraw',
      date: DateTime.now(),
      primaryAmount: '-${_fmt(receiveAmount ?? amount)} $symbol',
      isPositive: false,
      subLine1: 'Completed',
      details: <String, dynamic>{
        'symbol': symbol,
        'amount': amount,
        'network': network,
        'address': address,
        'txid': txid,
        'fee': fee,
        'receiveAmount': receiveAmount,
      },
    ));
  }

  /// Log a manual wallet balance increase/decrease (add funds / edit quantity).
  static Future<void> logWalletChange({
    required String symbol,
    required double amount,
    required bool increased,
  }) async {
    await _append(MockTransaction(
      type: increased ? 'Wallet Add' : 'Wallet Deduction',
      subType: increased ? 'Deposit' : 'Debit',
      date: DateTime.now(),
      primaryAmount: '${increased ? '+' : '-'}${_fmt(amount)} $symbol',
      isPositive: increased,
      subLine1: 'Success',
    ));
  }

  /// Read all recorded transactions, newest first.
  static List<MockTransaction> getAll() {
    final dynamic raw = _storage.read(_key);
    if (raw == null || raw is! List) return <MockTransaction>[];
    return raw
        .map((dynamic item) {
          try {
            return MockTransaction._fromMap(
              jsonDecode(item as String) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<MockTransaction>()
        .toList();
  }

  static Future<void> _append(MockTransaction tx) async {
    final dynamic existing = _storage.read(_key);
    final List<dynamic> list = existing is List
        ? List<dynamic>.from(existing)
        : <dynamic>[];
    list.insert(0, jsonEncode(tx._toMap())); // newest first
    await _storage.save(_key, list);
  }

  // Mirrors TradeController.formatCoinAmount() — keep in sync if that changes.
  static String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    if (v >= 0.0001) return v.toStringAsFixed(6);
    return v.toStringAsFixed(8);
  }
}
