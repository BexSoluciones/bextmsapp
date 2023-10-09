import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../cubits/database/database_cubit.dart';

class DatabaseView extends StatefulWidget {
  const DatabaseView({Key? key}) : super(key: key);

  @override
  State<DatabaseView> createState() => DatabaseViewState();
}

class DatabaseViewState extends State<DatabaseView> {
  late DatabaseCubit databaseCubit;

  bool isLoading = false;

  @override
  void initState() {
    databaseCubit = BlocProvider.of<DatabaseCubit>(context);
    databaseCubit.getDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<DatabaseCubit, DatabaseState>(
      listener: (context, state) {
        isLoading = state is DatabaseLoading;
      },
      builder: (context, state) {
        return WillPopScope(
            onWillPop: () async => !isLoading,
            child: Scaffold(
                appBar: AppBar(
                  title: const Text('Exportar base de datos'),
                ),
                body: _buildBody(size, state)));
      },
    );
  }

  Widget _buildBody(Size size, state) {
    if (state.runtimeType == DatabaseLoading) {
      return _buildLoading(size, state.tables, state.error);
    } else if (state.runtimeType == DatabaseSuccess ||
        state.runtimeType == DatabaseFailed) {
      return _buildDatabase(size, state.dbPath, state.error);
    } else {
      return const SizedBox();
    }
  }

  Widget _buildLoading(Size size, List<String>? tables, String? error) {
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: [
          const CupertinoActivityIndicator(),
          Expanded(
            child: ListView.builder(
                itemCount: tables?.length ?? 0,
                itemBuilder: (BuildContext context, int index) => ListTile(
                  title: Text(tables![index]),
                  subtitle: const LinearProgressIndicator(),
                ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildDatabase(Size size, String? path, String? error) {
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.upload_file, size: 50),
            onPressed: () => databaseCubit.exportDatabase(),
          ),
          if (path != null) Text(path, textAlign: TextAlign.center),
          if (error != null) Text(error, textAlign: TextAlign.center)
        ],
      ),
    );
  }
}
