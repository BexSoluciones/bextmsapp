import 'package:bexdeliveries/src/presentation/cubits/notification/count/count_cubit.dart';
import 'package:bexdeliveries/src/presentation/cubits/notification/count/count_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badge;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/size.dart';

class createDrawerItem extends StatefulWidget {
  BuildContext context;
  IconData icon;
  String text;
  GestureTapCallback? onTap;

  createDrawerItem(
      {super.key,
      required this.context,
      required this.icon,
      required this.text,
      required this.onTap});

  @override
  State<createDrawerItem> createState() => _createDrawerItemState();
}

class _createDrawerItemState extends State<createDrawerItem> {
  late CountCubit countCubit;

  @override
  void initState() {
    // TODO: implement initState
    countCubit = BlocProvider.of<CountCubit>(context);
    countCubit.getCountNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountCubit, CountState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case CountLoading:
            return const Center(child: CupertinoActivityIndicator());
          case CountSuccess:
            return ListTile(
              title: Row(
                children: <Widget>[
                  (widget.text != 'Notificaciones.')
                      ? Icon(widget.icon,
                          color: Theme.of(context).colorScheme.scrim)
                      : (state.count != 0)
                          ? badge.Badge(
                              badgeContent: Text(
                                state.count.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              position:
                                  badge.BadgePosition.topEnd(top: -10, end: -5),
                              badgeStyle: const badge.BadgeStyle(
                                badgeColor: Colors.red,
                              ),
                              child: Icon(Icons.notifications,
                                  color: Theme.of(context).colorScheme.scrim),
                            )
                          : Icon(Icons.notifications,
                              color: Theme.of(context).colorScheme.scrim),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(widget.text,
                        textScaleFactor: textScaleFactor(context)),
                  ),
                ],
              ),
              onTap: widget.onTap,
            );
          case CountFailed:
            return Center(
              child: Text(state.error!),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}
