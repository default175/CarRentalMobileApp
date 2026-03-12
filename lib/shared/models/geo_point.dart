class GeoPoint {
  const GeoPoint({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  GeoPoint shift({
    double latOffset = 0,
    double lngOffset = 0,
  }) {
    return GeoPoint(
      lat: lat + latOffset,
      lng: lng + lngOffset,
    );
  }
}
