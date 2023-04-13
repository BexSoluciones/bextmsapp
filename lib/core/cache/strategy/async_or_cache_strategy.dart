import 'package:dio/dio.dart';

import '../cache_strategy.dart';
import '../storage/storage.dart';
import '../cache_manager.dart';

class AsyncOrCacheStrategy extends CacheStrategy {
  static final AsyncOrCacheStrategy _instance = AsyncOrCacheStrategy._internal();

  factory AsyncOrCacheStrategy() {
    return _instance;
  }

  AsyncOrCacheStrategy._internal();

  @override
  Future<T?> applyStrategy<T>(AsyncBloc<T> asyncBloc, String key, SerializerBloc<T> serializerBloc, int ttlValue, Storage storage) async => await invokeAsync(asyncBloc, key, storage).onError(
        (DioError restError, stackTrace) async {
      if (restError.response!.statusCode == 403 || restError.response!.statusCode == 404) {
        storage.clear(prefix: key);
        return Future.error(restError);
      } else {
        return await fetchCacheData(key, serializerBloc, storage, ttlValue: ttlValue) ?? Future.error(restError);
      }
    },
  );
}