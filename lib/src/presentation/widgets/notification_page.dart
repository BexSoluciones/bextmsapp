import 'dart:convert';
import 'package:bexdeliveries/src/domain/abstracts/format_abstract.dart';
import 'package:bexdeliveries/src/presentation/blocs/processing_queue/processing_queue_bloc.dart';
import 'package:flutter/material.dart';
import 'package:bexdeliveries/src/domain/models/notification.dart'
    as notificationModel;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

import 'package:badges/badges.dart' as badge;

import '../../domain/models/processing_queue.dart';
import '../../domain/repositories/database_repository.dart';
import '../../locator.dart';
import '../../utils/constants/colors.dart';

final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();
final ProcessingQueueBloc _processingQueueBloc = locator<ProcessingQueueBloc>();

class BuildNotificationCard extends StatefulWidget {
  const BuildNotificationCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  final notificationModel.PushNotification notification;

  @override
  State<BuildNotificationCard> createState() => _BuildNotificationCardState();
}

class _BuildNotificationCardState extends State<BuildNotificationCard>
    with AutomaticKeepAliveClientMixin, FormatDate {
  late DateTime? dateParse;
  late bool updateStatus;

  @override
  void initState() {
    initializeDateFormatting();

    (widget.notification.date != null)
        ? dateParse = DateTime.parse(widget.notification.date!)
        : dateParse = null;

    (widget.notification.read_at == null)
        ? updateStatus = false
        : updateStatus = true;

    super.initState();
  }

  String formatDateTime(DateTime dateTime) {
    final format = DateFormat(
      'MMMM d, yyyy h:mm a',
      'es_ES',
    );
    return format.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () async {
          if (!updateStatus) {
            await _databaseRepository.updateNotification(
                widget.notification.id!, DateTime.now().toString());
            if (widget.notification.id_from_server != null) {
              var processingQueue = ProcessingQueue(
                body: jsonEncode({
                  'notification_id': widget.notification.id_from_server,
                  'date': '${DateTime.now()}'
                }),
                task: 'incomplete',
                code: 'store_notification',
                createdAt: now(),
                updatedAt: now(),
              );
              _processingQueueBloc.inAddPq.add(processingQueue);
            }

            setState(() {
              updateStatus = true;
            });
          } else {
            print('already updated.');
          }
        },
        child: badge.Badge(
          showBadge: (!updateStatus),
          badgeContent: const Text(
            '',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          position: badge.BadgePosition.topEnd(top: -10, end: -5),
          badgeStyle: const badge.BadgeStyle(
            badgeColor: Colors.red,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      child: Image.asset(
                    'assets/images/bex-deliveries-icon.png',
                    height: 30,
                    width: 30,
                  )),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.notification.title ?? 'Notificacion',
                            style: const TextStyle(
                                color: Color(0xFF202020),
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 15),
                        ReadMoreText(
                          widget.notification.body ?? '',
                          colorClickableText: kPrimaryColor,
                          style: const TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                          trimLines: 3,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: '... Ver mas',
                          trimExpandedText: ' Menos',
                        ),
                        const SizedBox(height: 12),
                        (dateParse != null)
                            ? Text(formatDateTime(dateParse!),
                                style: const TextStyle(
                                    color: Color(0xFF737373),
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal))
                            : const Text(''),
                        const SizedBox(height: 15),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
