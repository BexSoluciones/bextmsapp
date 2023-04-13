part of 'work_bloc.dart';

abstract class WorkEvent {}

class GetWorksEvent extends WorkEvent {}

class ConfirmWorkEvent extends WorkEvent {}