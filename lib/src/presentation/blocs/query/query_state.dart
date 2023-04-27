part of 'query_bloc.dart';

abstract class QueryState {}

class QueryInitial extends QueryState {}

class QuerySuccess extends QueryState {}

class QueryFailure extends QueryState {}