/// Map from data to entity
abstract class BaseDataMapper<Data, Entity> {
  BaseDataMapper();

  Entity mapToEntity(Data? data);

  Entity? mapToNullableEntity(Data? data) {
    if (data == null) {
      return null;
    }

    return mapToEntity(data);
  }

  List<Entity> mapToListEntity(Iterable<Data>? data) {
    return data?.map(mapToEntity).toList() ?? List.empty();
  }

  Set<Entity> mapToSetEntity(Iterable<Data>? data) {
    return data?.map(mapToEntity).toSet() ?? <Entity>{};
  }

  /// Convert a list dat thành Map với key là 1 trường của entity, còn value chính là entity đó
  Map<T, Entity> toMapEntityByValue<T>(
    Iterable<Data>? data,
    T? Function(Entity) getKey,
  ) {
    final result = <T, Entity>{};
    if (data == null) return result;
    for (final item in data) {
      final entity = mapToEntity(item);
      final key = getKey(entity);

      if (key == null) continue;
      if (key is String && key.isEmpty) continue;

      result[key] = entity;
    }
    return result;
  }
}

/// One-way mapping: Entity → Data
abstract class BaseEntityMapper<Entity, Data> {
  Data mapToData(Entity entity);

  Data? mapToNullableData(Entity? entity) {
    if (entity == null) {
      return null;
    }

    return mapToData(entity);
  }

  List<Data>? mapToNullableListData(Iterable<Entity>? entities) {
    return entities?.map(mapToData).toList();
  }

  List<Data> mapToListData(Iterable<Entity>? entities) {
    return mapToNullableListData(entities) ?? List.empty();
  }
}

/// Map from entity to data
mixin DataMapperMixin<Data, Entity> on BaseDataMapper<Data, Entity> {
  Data mapToData(Entity entity);

  Data? mapToNullableData(Entity? entity) {
    if (entity == null) {
      return null;
    }

    return mapToData(entity);
  }

  List<Data>? mapToNullableListData(Iterable<Entity>? entities) {
    return entities?.map(mapToData).toList();
  }

  List<Data> mapToListData(Iterable<Entity>? entities) {
    return mapToNullableListData(entities) ?? List.empty();
  }
}
