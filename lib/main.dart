import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: BlocProvider(
          create: (_) => ExchangesBloc(),
          child: const MyHomePage(title: 'Flutter Hooks')),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        toolbarHeight: 30,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              FunctionTextButton(
                  onPressed: () {
                    context.read<ExchangesBloc>().add(
                        const LoadStockExchangeAction(
                            url: ExchangeUrl.nseStockExchange));
                  },
                  width: 180,
                  child: const Text("Load NSE_ExchangeData")),
              FunctionTextButton(
                  onPressed: () {
                    context.read<ExchangesBloc>().add(
                        const LoadStockExchangeAction(
                            url: ExchangeUrl.bseStockExchange));
                  },
                  width: 180,
                  child: const Text("Load BSE_ExchangeData")),
            ],
          ),
          BlocBuilder<ExchangesBloc, FetchResult?>(
            buildWhen: (previousResult, currentResult) {
              return previousResult?.exchanges != currentResult?.exchanges;
            },
            builder: (context, fetchResult) {
              fetchResult?.log();
              final exchanges = fetchResult?.exchanges;
              if (exchanges == null) {
                return const SizedBox();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: exchanges.length,
                  itemBuilder: (context, index) {
                    final exchange = exchanges[index]!;
                    return ListTile(
                      title: Text(exchange.stock),
                      subtitle: Row(
                        children: [
                          Text("Today's Open: ${exchange.todaysOpen} , "),
                          Text("Current Close: ${exchange.currentPrice}"),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

enum ExchangeUrl {
  nseStockExchange,
  bseStockExchange,
}

extension UrlString on ExchangeUrl {
  String get urlString {
    switch (this) {
      case ExchangeUrl.nseStockExchange:
        return "http://127.0.0.1:5500/api/nse_stocks.json";
      case ExchangeUrl.bseStockExchange:
        return "http://127.0.0.1:5500/api/bse_stocks.json";
    }
  }
}

@immutable
class LoadStockExchangeAction implements LoadAction {
  final ExchangeUrl url;

  const LoadStockExchangeAction({required this.url}) : super();
}

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

Future<Iterable<Exchange>> getExchanges(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then(
      (list) => list.map((foundElements) => Exchange.fromJson(foundElements)),
    );

@immutable
class FetchResult {
  final Iterable<Exchange> exchanges;
  final bool isRetrievedFromCache;

  const FetchResult(
      {required this.exchanges, required this.isRetrievedFromCache});

  @override
  String toString() =>
      "Fetched Exchanges Result (isRetrievedFromCache = $isRetrievedFromCache, Exchanges = $exchanges)";
}

class ExchangesBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<ExchangeUrl, Iterable<Exchange>> _cache = {};
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
        final exchanges = await getExchanges(url.urlString);
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

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) {
    return length > index ? elementAt(index) : null;
  }
}

// Button Design

class FunctionTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final bool baseColor;
  final double? height;
  final Color? onhoverColor;
  const FunctionTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.onhoverColor = Colors.amberAccent,
    this.baseColor = true,
    this.width = 50,
    this.height = 22,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: onhoverColor,
        splashColor: Colors.black26,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black12),
            color: Colors.white12,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          height: height,
          width: width,
          child: Center(child: child),
        ));
  }
}
