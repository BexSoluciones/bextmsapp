import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

//providers
import '../../../../../../providers/general_provider.dart';
import '../../../../../../providers/download_provider.dart';

//components
import 'min_max_zoom_controller_popup.dart';
import 'shape_controller_popup.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Downloader',
              ),
              Consumer<GeneralProvider>(
                builder: (context, provider, _) => provider.currentStore == null
                    ? const SizedBox.shrink()
                    : const Text(
                        'Existing tiles will appear in red',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (_) => const MinMaxZoomControllerPopup(),
            ).then(
              (_) => Provider.of<DownloadProvider>(context, listen: false)
                  .triggerManualPolygonRecalc(),
            ),
            icon: const Icon(Icons.zoom_in),
          ),
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (_) => const ShapeControllerPopup(),
            ).then(
              (_) => Provider.of<DownloadProvider>(context, listen: false)
                  .triggerManualPolygonRecalc(),
            ),
            icon: const Icon(Icons.select_all),
          ),
        ],
      );
}
