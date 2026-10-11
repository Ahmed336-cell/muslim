import 'package:hydrated_bloc/hydrated_bloc.dart';

/// In-memory stand-in for [HydratedStorage].
class MemoryStorage implements Storage {
  final _data = <String, dynamic>{};

  @override
  dynamic read(String key) => _data[key];

  @override
  Future<void> write(String key, dynamic value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();

  @override
  Future<void> close() async {}
}

MemoryStorage useMemoryStorage() {
  final storage = MemoryStorage();
  HydratedBloc.storage = storage;
  return storage;
}
