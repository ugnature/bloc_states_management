import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:understanding_bloc/bloc/exchange.dart';
import 'package:understanding_bloc/bloc/exchanges_bloc.dart';

import 'dart:developer' as devtools show log;

import 'widgets/buttons.dart';
import 'bloc/bloc_action.dart';

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
                            url: nseStockExchangeUrl, loader: getExchanges));
                  },
                  width: 180,
                  child: const Text("Load NSE_ExchangeData")),
              FunctionTextButton(
                  onPressed: () {
                    context.read<ExchangesBloc>().add(
                        const LoadStockExchangeAction(
                            url: bseStockExchangeUrl, loader: getExchanges));
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

Future<Iterable<Exchange>> getExchanges(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then(
      (list) => list.map((foundElements) => Exchange.fromJson(foundElements)),
    );

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) {
    return length > index ? elementAt(index) : null;
  }
}
