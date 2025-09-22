import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/futures_controller.dart';
import 'future_usd.dart';

class FuturesScreen extends GetView<FuturesController> {
  const FuturesScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Futures'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(child: Column(children: [
        TradingPanelWidget()
      ],),),
    );
  }
}
