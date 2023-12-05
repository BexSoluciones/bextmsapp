import 'package:flutter/material.dart';

//utils
import '../../../../../utils/constants/strings.dart';

//models
import '../../../../../domain/models/work.dart';
import '../../../../../domain/models/arguments.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

Widget carouselCard(
    Work work, int index, num distance, num duration, BuildContext context) {
  return GestureDetector(
      onTap: () async {
        if (work.hasCompleted != null && work.hasCompleted == 0) {
          _navigationService.goTo(summaryRoute,
              arguments: SummaryArgument(work: work));
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
                  backgroundColor: Colors.primaries[work.color ?? 1],
                  child: Text('${work.order! + 1}')),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work.customer!,
                        style: const TextStyle(
                            fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                      Text(work.address!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 8, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(
                        '${distance > 0.1000 ? '${distance.toStringAsFixed(2)}kms' : '${(distance * 1000).toStringAsFixed(2)}ms'} , ${duration > 0.60 ? '${duration.toStringAsFixed(2)}mins' : '${(duration * 60).toStringAsFixed(2)}secs'}',
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
