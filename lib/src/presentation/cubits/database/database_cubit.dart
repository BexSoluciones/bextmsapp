import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

//domain
import '../../../domain/models/requests/database_request.dart';
import '../../../domain/repositories/api_repository.dart';

//base
import '../base/base_cubit.dart';

//services
import '../../../locator.dart';
import '../../../services/storage.dart';


part 'database_state.dart';


final LocalStorageService _storageService = locator<LocalStorageService>();

class DatabaseCubit extends BaseCubit<DatabaseState, String?> {
  final ApiRepository _apiRepository;

  DatabaseCubit(this._apiRepository)
      : super(const DatabaseLoading(), null);

  Future<void> getDatabase() async {
    emit(await _getDatabase());
  }

  Future<void> sendDatabase(dbPath) async {
    if (isBusy) return;

    await run(() async {
      emit(const DatabaseLoading());

      final response = await _apiRepository.database(
        request: DatabaseRequest(path: dbPath),
      );

      if(response is DatabaseSuccess){
        emit(const DatabaseSuccess());
      } else {
        emit(DatabaseFailed(error: response.error));
      }
    });
  }


  Future<DatabaseState> _getDatabase() async {
    var company  = _storageService.getString('company_name');
    if(company!=null){
      var dir = await getApplicationDocumentsDirectory();
      var dbPath = '${dir.path}/$company.db';
      return DatabaseSuccess(dbPath: dbPath);
    }else {
      return const DatabaseSuccess(dbPath: null);
    }
  }
}