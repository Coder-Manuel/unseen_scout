import 'dart:typed_data';

/// Parses a PostGIS EWKB (Extended Well-Known Binary) hex string into
/// geographic coordinates.
///
/// PostGIS returns `geography` / `geometry` columns as EWKB when queried via
/// PostgREST (Supabase). This utility handles the standard Point sub-type with
/// an optional embedded SRID — which is what `ST_MakePoint` with SRID 4326
/// produces.
///
/// EWKB layout for a 2-D Point (little-endian, with SRID):
/// ```
/// [01]          byte order  (01 = little-endian)
/// [01000020]    wkbType     (0x20000001 = Point | hasSrid flag)
/// [E6100000]    SRID        (0x000010E6 = 4326)
/// [8 bytes]     X           (longitude, IEEE-754 double)
/// [8 bytes]     Y           (latitude,  IEEE-754 double)
/// ```
class EwkbParser {
  EwkbParser._();

  /// Returns `(latitude, longitude)` parsed from [hex], or `(null, null)` if
  /// the string is absent, too short, or not a Point geometry.
  static ({double latitude, double longitude}) parsePoint(String? hex) {
    if (hex == null || hex.length < 42) {
      return (latitude: 0, longitude: 0);
    }

    try {
      final bytes = Uint8List.fromList([
        for (int i = 0; i < hex.length; i += 2)
          int.parse(hex.substring(i, i + 2), radix: 16),
      ]);

      final data = ByteData.view(bytes.buffer);
      final endian = bytes[0] == 0x01 ? Endian.little : Endian.big;

      // wkbType at offset 1 — check hasSrid flag (0x20000000)
      final wkbType = data.getUint32(1, endian);
      final hasSrid = (wkbType & 0x20000000) != 0;

      // X (longitude) starts after: 1 byte order + 4 wkbType + 4 SRID (optional)
      final xOffset = 1 + 4 + (hasSrid ? 4 : 0);

      final longitude = data.getFloat64(xOffset, endian);
      final latitude = data.getFloat64(xOffset + 8, endian);

      return (latitude: latitude, longitude: longitude);
    } catch (_) {
      return (latitude: 0, longitude: 0);
    }
  }
}
