import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../..//cubits/download/download_cubit.dart';

class BufferingConfiguration extends StatelessWidget {
  const BufferingConfiguration({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<DownloadCubit, DownloadState>(
    bloc: context.read<DownloadCubit>(),
    builder: (context, state) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BUFFERING CONFIGURATION'),
        const SizedBox(height: 15),
        if (state.regionTiles == null)
          const CircularProgressIndicator()
        else ...[
          Column(
            children: [
              Row(
                children: [
                  SegmentedButton<DownloadBufferMode>(
                    segments: const [
                      ButtonSegment(
                        value: DownloadBufferMode.disabled,
                        label: Text('Disabled'),
                        icon: Icon(Icons.cancel),
                      ),
                      ButtonSegment(
                        value: DownloadBufferMode.tiles,
                        label: Text('Tiles'),
                        icon: Icon(Icons.flip_to_front_outlined),
                      ),
                      ButtonSegment(
                        value: DownloadBufferMode.bytes,
                        label: Text('Size (kB)'),
                        icon: Icon(Icons.storage_rounded),
                      ),
                    ],
                    selected: {state.bufferMode},
                    onSelectionChanged: (s) => state.bufferMode = s.single,
                  ),
                ],
              ),
              state.bufferMode == DownloadBufferMode.disabled
                  ? const SizedBox.shrink()
                  : Text(
                state.bufferMode == DownloadBufferMode.tiles &&
                    state.bufferingAmount >=
                        state.regionTiles!
                    ? 'Write Once'
                    : '${state.bufferingAmount} ${state.bufferMode == DownloadBufferMode.tiles ? 'tiles' : 'kB'}',
              ),
            ],
          ),
          const SizedBox(height: 5),
          state.bufferMode == DownloadBufferMode.disabled
              ? const Slider(value: 0.5, onChanged: null)
              : Slider(
            value: state.bufferMode == DownloadBufferMode.tiles
                ? state.bufferingAmount
                .clamp(10, state.regionTiles!)
                .roundToDouble()
                : state.bufferingAmount.roundToDouble(),
            min: state.bufferMode == DownloadBufferMode.tiles
                ? 10
                : 500,
            max: state.bufferMode == DownloadBufferMode.tiles
                ? state.regionTiles!.toDouble()
                : 10000,
            onChanged: (value) =>
            state.bufferingAmount = value.round(),
          ),
        ],
      ],
    ),
  );
}