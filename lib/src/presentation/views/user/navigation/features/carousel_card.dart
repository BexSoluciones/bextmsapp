import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../../../utils/constants/strings.dart';

//models
import '../../../../../domain/models/work.dart';
import '../../../../../domain/models/arguments.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';
import '../../../../cubits/navigation/navigation_cubit.dart';

final NavigationService _navigationService = locator<NavigationService>();


class carouselCard extends StatefulWidget {
  Work work;
  int index;
  num distance;
  num duration;
  BuildContext context;
   carouselCard({super.key, required this.work,required this.index,required this.distance, required this.duration,required this.context});

  @override
  State<carouselCard> createState() => _carouselCardState();
}

class _carouselCardState extends State<carouselCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          context.read<NavigationCubit>().clean();
          if (widget.work.hasCompleted != null && widget.work.hasCompleted == 0) {
            _navigationService.goTo(AppRoutes.summary,
                arguments: SummaryArgument(work: widget.work));
          }
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    backgroundColor: Colors.primaries[widget.work.color ?? 1],
                    child: Text('${widget.index + 1}')),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.work.customer!,
                          style: const TextStyle(
                              fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.work.address!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(
                          '${widget.distance > 0.1000 ? '${widget.distance.toStringAsFixed(2)}kms' : '${(widget.distance * 1000).toStringAsFixed(2)}ms'} , ${widget.duration > 0.60 ? '${widget.duration.toStringAsFixed(2)}mins' : '${(widget.duration * 60).toStringAsFixed(2)}secs'}',
                          style: const TextStyle(fontSize: 8),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

