part of 'georeference_cubit.dart';

abstract class GeoReferenceState {}

class GeoReferenceInitial extends GeoReferenceState {}

class GeoReferenceLoading extends GeoReferenceState {}

class GeoReferenceSuccess extends GeoReferenceState {}

class GeoReferenceFinished extends GeoReferenceState {}

class GeoReferenceFailed extends GeoReferenceState {}