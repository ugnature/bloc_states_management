import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:understanding_bloc/bloc/bloc_action.dart';
import 'package:understanding_bloc/bloc/exchange.dart';
import 'package:understanding_bloc/bloc/exchanges_bloc.dart';

const mockedNseStockExchange = [
  Exchange(
    stock: 'BANK_NIFTY',
    currentPrice: 45875.25,
    todaysOpen: 45781.02,
  ),
  Exchange(
    stock: 'NIFTY_50',
    currentPrice: 18425.95,
    todaysOpen: 18754.25,
  ),
];

const mockedBseStockExchange = [
  Exchange(
    stock: 'BANK_NIFTY',
    currentPrice: 45975.57,
    todaysOpen: 45847.24,
  ),
  Exchange(
    stock: 'NIFTY_50',
    currentPrice: 18472.10,
    todaysOpen: 18254.87,
  ),
];

Future<Iterable<Exchange>> mockGetNseExchange(String _) =>
    Future.value(mockedNseStockExchange);

Future<Iterable<Exchange>> mockGetBseExchange(String _) =>
    Future.value(mockedBseStockExchange);

void main() {
  group(
    'Testing Bloc',
    () {
      // Write tests
      late ExchangesBloc bloc;
      setUp(() {
        bloc = ExchangesBloc();
      });
      blocTest<ExchangesBloc, FetchResult?>(
        'Test Intial State',
        build: () => bloc,
        verify: (bloc) => expect(bloc.state, null),
      );

      // fetch some nseExchange data and compare it with FetchResult
      blocTest<ExchangesBloc, FetchResult?>(
        'Mock retrieving Nse Exchange Iterable',
        build: () => bloc,
        act: (bloc) => {
          bloc.add(const LoadStockExchangeAction(
            url: 'dummy_NseExchangeUrl',
            loader: mockGetNseExchange,
          )),
          bloc.add(const LoadStockExchangeAction(
            url: 'dummy_NseExchangeUrl',
            loader: mockGetNseExchange,
          )),
        },
        expect: () => [
          // this one was not cached
          const FetchResult(
            exchanges: mockedNseStockExchange,
            isRetrievedFromCache: false,
          ),
          // this one is cached now
          const FetchResult(
            exchanges: mockedNseStockExchange,
            isRetrievedFromCache: true,
          ),
        ],
      );
      // fetch some bseExchange data and compare it with FetchResult
      blocTest<ExchangesBloc, FetchResult?>(
        'Mock retrieving Bse Exchange Iterable',
        build: () => bloc,
        act: (bloc) => {
          bloc.add(const LoadStockExchangeAction(
            url: 'dummy_BseExchangeUrl',
            loader: mockGetBseExchange,
          )),
          bloc.add(const LoadStockExchangeAction(
            url: 'dummy_BseExchangeUrl',
            loader: mockGetBseExchange,
          )),
        },
        expect: () => [
          // this one was not cached
          const FetchResult(
            exchanges: mockedBseStockExchange,
            isRetrievedFromCache: false,
          ),
          // this one is cached now
          const FetchResult(
            exchanges: mockedBseStockExchange,
            isRetrievedFromCache: true,
          ),
        ],
      );
    },
  );
}
