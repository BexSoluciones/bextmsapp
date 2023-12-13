import 'package:meta/meta.dart';
import 'dart:async';
import 'package:equatable/equatable.dart';

import '../../../domain/repositories/database_repository.dart';
import '../base/base_cubit.dart';
part 'left_state.dart';




class LeftCubit extends BaseCubit<LeftState , bool> {
  final DatabaseRepository _databaseRepository;
  LeftCubit(this._databaseRepository) : super(const LeftLoading(),false);


  Future<int> getCountLeft(String workCode) async {
    if (isBusy) {
      return 0;
    }
    try {
      final count = await _databaseRepository.countLeftClients(workCode);
      emit(LeftSuccess(count: count));
      return count;
    } catch (error) {
      emit(LeftFailed(error: error.toString()));
      return 0;
    }
  }

}