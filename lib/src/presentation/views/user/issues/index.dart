import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//blocs
import '../../../blocs/issues/issues_bloc.dart';

//features
import '../partial/features/build_reasons_text-field.dart';
import 'features/listview.dart';

class IssuesView extends StatelessWidget {
  const IssuesView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var issuesBloc = context.read<IssuesBloc>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Reportar un problema'),
        ),
        body: BlocBuilder<IssuesBloc, IssuesState>(
          builder: (context, state) {
            if (state.issuesList != null && state.issuesList!.isNotEmpty) {
              return Column(
                children: [
                  HeaderSection(
                    onChanged: (value) {
                      issuesBloc.add(SearchIssue(issueToSearch: value));
                    },
                  ),
                  const Expanded(child: IssuesListView())
                ],
              );
            } else {
              return const Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Sincronice datos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Si el problema persiste contacte a soporte.'),
                    SizedBox()
                  ],
                ),
              );
            }
          },
        ));
  }
}
