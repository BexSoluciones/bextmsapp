import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/download/download_cubit.dart';
import '../../../../cubits/general/general_cubit.dart';

class StoreSelector extends StatefulWidget {
  const StoreSelector({super.key});

  @override
  State<StoreSelector> createState() => _StoreSelectorState();
}

class _StoreSelectorState extends State<StoreSelector> {
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CHOOSE A STORE'),
          BlocBuilder<DownloadCubit, DownloadState>(
              builder: (context, downloadState) {
            return BlocBuilder<GeneralCubit, GeneralState>(
                builder: (context, generalState) =>
                    FutureBuilder<List<StoreDirectory>>(
                      future: FMTC
                          .instance.rootDirectory.stats.storesAvailableAsync,
                      builder: (context, snapshot) =>
                          DropdownButton<StoreDirectory>(
                        items: snapshot.data
                            ?.map(
                              (e) => DropdownMenuItem<StoreDirectory>(
                                value: e,
                                child: Text(e.storeName),
                              ),
                            )
                            .toList(),
                        onChanged: (store) =>
                            downloadState.selectedStore = store,
                        value: downloadState.selectedStore ??
                            (generalState.currentStore == null
                                ? null
                                : FMTC.instance(generalState.currentStore!)),
                        isExpanded: true,
                        hint: Text(
                          snapshot.data == null
                              ? 'Loading...'
                              : snapshot.data!.isEmpty
                                  ? 'None Available'
                                  : 'None Selected',
                        ),
                      ),
                    ));
          })
        ],
      );
}
