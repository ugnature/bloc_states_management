import 'package:flutter/material.dart' show immutable;

@immutable
class Exchange {
  final String stock;
  final double todaysOpen;
  final double currentPrice;

  const Exchange({
    required this.stock,
    required this.todaysOpen,
    required this.currentPrice,
  });

  Exchange.fromJson(Map<String, dynamic> json)
      : stock = json["stock"] as String,
        todaysOpen = json["Today's_open"] as double,
        currentPrice = json["Current_Price"] as double;
}
