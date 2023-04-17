import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:equatable/equatable.dart';

part 'general_state.dart';

class GeneralCubit extends Cubit<GeneralState> {
  GeneralCubit() : super(GeneralLoading());


  String? get currentStore => state.currentStore;

  set currentStore(String? newStore) {
    currentStore = newStore;
  }

  void resetMap() => state.resetController!.add(null);

}