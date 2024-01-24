import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/download_provider.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool cancelled = false;

  @override
  Widget build(BuildContext context) => Consumer<DownloadProvider>(
        builder: (context, provider, _) => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descargando',
                  ),
                  Text(
                    'Descargando a: ${provider.selectedStore?.storeName ?? '<en modo de prueba>'}',
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: 'Cancelar descarga',
              onPressed: cancelled
                  ? null
                  : () async {
                      await FMTC
                          .instance(provider.selectedStore!.storeName)
                          .download
                          .cancel();
                      setState(() => cancelled = true);
                    },
            ),
          ],
        ),
      );
}
