import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../../../utils/constants/strings.dart';

//blocs
import '../../../../blocs/issues/issues_bloc.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class IssuesListView extends StatelessWidget {
  const IssuesListView({super.key});

  @override
  Widget build(BuildContext context) {
    var issuesBloc = BlocProvider.of<IssuesBloc>(context);

    return BlocBuilder<IssuesBloc, IssuesState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.issuesList!.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                  '${state.issuesList![index].codmotvis} - ${state.issuesList![index].nommotvis.toUpperCase()}'),
              onTap: () {
                issuesBloc.add(
                    SelectIssue(newSelectedIssue: state.issuesList![index]));
                _navigationService.goTo(fillIssueRoute);
              },
              //reasonCallbacks
            );
          },
        );
      },
    );
  }
}
