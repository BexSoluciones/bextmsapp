import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//blocs
import '../../../../blocs/account/account_bloc.dart';

class ListViewQr extends StatelessWidget {
  const ListViewQr({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountLoadingState) {
          return const CircularProgressIndicator();
        } else if (state is AccountLoadedState) {
          final accounts = state.accounts;
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              var account = accounts[index];
              if (account.id != 0) {
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ExpansionTile(
                    title: Text(
                      account.name!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            account.codeQr != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: account.codeQr!,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 10),
                            Text(
                              'Código QR para ${account.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Escanea este código para realizar una transferencia',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          );
        } else if (state is AccountErrorState) {
          return Text('Error: ${state.error}');
        } else {
          return const Text('No se han cargado datos aún.');
        }
      },
    );
  }
}
