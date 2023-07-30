import 'package:flutter/material.dart' show immutable;
import 'package:understanding_bloc/bloc/exchange.dart';

const nseStockExchangeUrl = "http://127.0.0.1:5500/api/nse_stocks.json";
const bseStockExchangeUrl = "http://127.0.0.1:5500/api/bse_stocks.json";

// creating a dependency injection for loadStockExchangeAction in bloc Action
typedef ExchangesLoader = Future<Iterable<Exchange>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadStockExchangeAction implements LoadAction {
  final String url;
  final ExchangesLoader loader;

  const LoadStockExchangeAction({
    required this.url,
    required this.loader,
  }) : super();
}
