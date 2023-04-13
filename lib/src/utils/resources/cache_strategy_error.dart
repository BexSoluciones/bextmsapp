class CacheStrategyError extends Error {
  final String message;

  CacheStrategyError(this.message);

  @override
  String toString() {
    return 'CacheStrategy: $message';
  }
}