import 'package:flutter/material.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:understanding_bloc/bloc/bloc_action.dart';
import 'package:understanding_bloc/bloc/exchange.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

@immutable
class FetchResult {
  final Iterable<Exchange> exchanges;
  final bool isRetrievedFromCache;

  const FetchResult(
      {required this.exchanges, required this.isRetrievedFromCache});

  @override
  String toString() =>
      "Fetched Exchanges Result (isRetrievedFromCache = $isRetrievedFromCache, Exchanges = $exchanges)";

  @override
  bool operator ==(covariant FetchResult other) =>
      exchanges.isEqualToIgnoringOrdering(other.exchanges) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashCode => Object.hash(exchanges, isRetrievedFromCache);
}

class ExchangesBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Exchange>> _cache = {};
  ExchangesBloc() : super(null) {
    on<LoadStockExchangeAction>((event, emit) async {
      final url = event.url;
      if (_cache.containsKey(url)) {
        // then we know that we have the value in cache
        final cachedExchanges = _cache[url]!;
        final result = FetchResult(
          exchanges: cachedExchanges,
          isRetrievedFromCache: true,
        );
        emit(result);
      } else {
        final loader = event.loader;
        final exchanges = await loader(url);
        _cache[url] = exchanges;
        final result = FetchResult(
          exchanges: exchanges,
          isRetrievedFromCache: false,
        );
        emit(result);
      }
    });
  }
}
