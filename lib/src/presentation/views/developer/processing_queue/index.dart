import 'package:bexdeliveries/src/config/size.dart';
import 'package:bexdeliveries/src/presentation/views/developer/processing_queue/features/detail.dart';
import 'package:bexdeliveries/src/utils/constants/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

//domain
import '../../../../domain/models/processing_queue.dart';

//bloc
import '../../../../utils/constants/colors.dart';
import '../../../blocs/processing_queue/processing_queue_bloc.dart';

//features
import 'features/item.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class ProcessingQueueView extends StatefulWidget {
  const ProcessingQueueView({super.key});

  @override
  State<ProcessingQueueView> createState() => _ProcessingQueueViewState();
}

class _ProcessingQueueViewState extends State<ProcessingQueueView> {
  late ProcessingQueueBloc processingQueueBloc;
  static const _pageSize = 20;

  final PagingController<int, ProcessingQueue> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await processingQueueBloc.getData(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    processingQueueBloc = context.read<ProcessingQueueBloc>();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    changeFilterValue(processingQueueBloc.itemsFilter.first['key']);
    changeStateValue(processingQueueBloc.itemsState.first['key']);
    // TODO: implement initState
    super.initState();
  }

  void changeFilterValue(String? value) {
    processingQueueBloc.add(ProcessingQueueSearchFilter(value: value));
  }

  void changeStateValue(String? value) {
    processingQueueBloc.add(ProcessingQueueSearchState(value: value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => _navigationService.goBack(),
            ),
            expandedHeight: 100,
            pinned: true,
            forceElevated: innerBoxIsScrolled,
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(120.0), // here the desired height
              child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 2.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 2.0),
                          ),
                          hintStyle: TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                        style: const TextStyle(
                          color: kPrimaryColor,
                        ),
                        value: processingQueueBloc.state.dropdownFilterValue,
                        items: processingQueueBloc.itemsFilter.map((item) {
                          return DropdownMenuItem(
                            value: item['key'],
                            child: Text(item['value']!),
                          );
                        }).toList(),
                        onChanged: changeFilterValue),
                    gapH12,
                    DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 2.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 2.0),
                          ),
                          hintStyle: TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                        style: const TextStyle(
                          color: kPrimaryColor,
                        ),
                        value: processingQueueBloc.state.dropdownStateValue,
                        items: processingQueueBloc.itemsState.map((item) {
                          return DropdownMenuItem(
                            value: item['key'],
                            child: Text(item['value']!),
                          );
                        }).toList(),
                        onChanged: changeStateValue),
                  ],
                ),
              ),
            ),
          ),
        ],
        // The content of the scroll view
        body: SafeArea(
            child: SizedBox(
                width: getFullScreenWidth(),
                height: getFullScreenHeight(),
                child: PagedListView<int, ProcessingQueue>.separated(
                  shrinkWrap: true,
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<ProcessingQueue>(
                    itemBuilder: (context, item, index) => ProcessingQueueCard(
                      processingQueue: item,
                    ),
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                ))),
      ),
    );
  }
}
