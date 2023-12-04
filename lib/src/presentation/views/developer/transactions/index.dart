import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../../domain/models/transaction.dart';

//bloc
import '../../../cubits/transaction/transaction_cubit.dart';

//features
import 'features/item.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';
import '../../../../services/location.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocationService _locationService = locator<LocationService>();

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {

  late TransactionCubit transactionCubit;

  @override
  void initState() {
    // TODO: implement initState
    transactionCubit = BlocProvider.of<TransactionCubit>(context);
    transactionCubit.getAllTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => _navigationService.goBack(),
        ),
        title: const Text('Transactions'),
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (_, state) {
          switch (state.runtimeType) {
            case TransactionLoading:
              return const Center(child: CircularProgressIndicator());
            case TransactionSuccess:
              return _buildHome(
                state.transactions,
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildHome(
      List<Transaction> transactions,
      ) {
    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionCard(transaction: transaction);
      },
    );
  }
}
