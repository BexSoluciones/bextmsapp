class IsolateModel {
  IsolateModel(this.iteration, this.functions);

  final int iteration;
  final List<Function> functions;

  Map<String, dynamic> toJson() {
    return {
      'functions': functions.toString(),
      'iteration': iteration,
    };
  }
}