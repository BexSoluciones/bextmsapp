import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'general_state.dart';

class GeneralCubit extends Cubit<GeneralState> {
  GeneralCubit() : super(const GeneralLoading());
}