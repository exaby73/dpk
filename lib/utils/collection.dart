import 'package:collection/collection.dart' as collection;

Map<K, V> mergeMaps<K, V>(Map<K, V> a, Map<K, V> b) {
  return collection.mergeMaps(
    a,
    b,
    value: (c1, c2) {
      if (c1 is Map<K, V> && c2 is Map<K, V>) {
        return mergeMaps(c1, c2) as V;
      }

      if (c1 is List && c2 is List) {
        return [...c1, ...c2] as V;
      }

      return c2;
    },
  );
}
