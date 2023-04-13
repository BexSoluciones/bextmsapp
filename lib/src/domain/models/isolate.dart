class IsolateModel {
  IsolateModel(this.iteration, this.functions);

  final int iteration;
  final List<Future<void>> functions;
}