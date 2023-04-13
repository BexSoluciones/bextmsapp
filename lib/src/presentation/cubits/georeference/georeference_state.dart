part of 'georeference_cubit.dart';

abstract class GeoreferenceState {}

class GeoreferenceLoading extends GeoreferenceState {}

class GeoreferenceSuccess extends GeoreferenceState {}

class GeoreferenceFinished extends GeoreferenceState {}

class GeoreferenceFailed extends GeoreferenceState {}