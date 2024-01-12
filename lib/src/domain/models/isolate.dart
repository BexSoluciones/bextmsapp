class IsolateModel {
  IsolateModel(this.functions, this.iteration);

  final List<Function> functions;
  final int iteration;

  Map<String, dynamic> toJson() {
    return {
      'functions': functions.toString(),
      'iteration': iteration,
    };
  }
}