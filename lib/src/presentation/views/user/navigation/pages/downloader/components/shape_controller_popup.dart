import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../../../../cubits/download/download_cubit.dart';

//utils
import '../../../../../../../utils/constants/enums.dart';

class ShapeControllerPopup extends StatelessWidget {
  const ShapeControllerPopup({super.key});

  static const Map<String, List<dynamic>> regionShapes = {
    'Square': [
      Icons.crop_square_sharp,
      RegionMode.square,
    ],
    'Rectangle (Vertical)': [
      Icons.crop_portrait_sharp,
      RegionMode.rectangleVertical,
    ],
    'Rectangle (Horizontal)': [
      Icons.crop_landscape_sharp,
      RegionMode.rectangleHorizontal,
    ],
    'Circle': [
      Icons.circle_outlined,
      RegionMode.circle,
    ],
    'Line/Path': [
      Icons.timeline,
      null,
    ],
  };

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: BlocBuilder<DownloadCubit, DownloadState>(
          builder: (context, state) => ListView.separated(
            itemCount: regionShapes.length,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              final String key = regionShapes.keys.toList()[i];
              final IconData icon = regionShapes.values.toList()[i][0];
              final RegionMode? mode = regionShapes.values.toList()[i][1];

              return ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(key),
                subtitle: i == regionShapes.length - 1
                    ? const Text('Disabled in example application')
                    : null,
                leading: Icon(icon),
                trailing:
                    state.regionMode == mode ? const Icon(Icons.done) : null,
                onTap: i != regionShapes.length - 1
                    ? () {
                        state.regionMode = mode!;
                        Navigator.of(context).pop();
                      }
                    : null,
                enabled: i != regionShapes.length - 1,
              );
            },
            separatorBuilder: (context, i) =>
                i == regionShapes.length - 2 ? const Divider() : Container(),
          ),
        ),
      );
}
