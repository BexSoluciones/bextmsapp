import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../../../cubits/download/download_cubit.dart';


import 'components/header.dart';
import 'components/horizontal_layout.dart';
import 'components/vertical_layout.dart';

class DownloadingPage extends StatefulWidget {
  const DownloadingPage({super.key});

  @override
  State<DownloadingPage> createState() => _DownloadingPageState();
}

class _DownloadingPageState extends State<DownloadingPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Header(),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: BlocBuilder<DownloadCubit, DownloadState>(
                      builder: (context, state) =>
                          StreamBuilder<DownloadProgress>(
                        stream: state.downloadProgress,
                        initialData: DownloadProgress.empty(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => state.downloadProgress = null,
                            );
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) =>
                                constraints.maxWidth > 725
                                    ? HorizontalLayout(data: snapshot.data!)
                                    : VerticalLayout(data: snapshot.data!),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
