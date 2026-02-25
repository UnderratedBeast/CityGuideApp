import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // for hashCode

class AllPlacesMapScreen extends StatefulWidget {
  const AllPlacesMapScreen({super.key});

  @override
  State<AllPlacesMapScreen> createState() => _AllPlacesMapScreenState();
}

class _AllPlacesMapScreenState extends State<AllPlacesMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Store markers with their associated place name
  List<_PlaceMarker> _allPlaceMarkers = [];
  List<_PlaceMarker> _filteredPlaceMarkers = [];

  bool _isLoading = true;
  final List<String> _subcollections = ['attractions', 'hotels', 'dining', 'events'];

  // Default map center (Abuja, Nigeria)
  final latLng.LatLng _defaultCenter = const latLng.LatLng(9.05785, 7.49508);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterMarkers);
    _fetchAllPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters markers based on the search query
  void _filterMarkers() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPlaceMarkers = List.from(_allPlaceMarkers);
      } else {
        _filteredPlaceMarkers = _allPlaceMarkers
            .where((pm) => pm.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  /// Fetches all cities and their subcollections, builds markers
  Future<void> _fetchAllPlaces() async {
    try {
      final citiesSnapshot =
          await FirebaseFirestore.instance.collection('cities').get();
      final List<_PlaceMarker> tempMarkers = [];

      for (var cityDoc in citiesSnapshot.docs) {
        final cityName = cityDoc.data()['name'] ?? 'Unknown City';

        for (String subcol in _subcollections) {
          final subSnapshot = await cityDoc.reference.collection(subcol).get();

          for (var placeDoc in subSnapshot.docs) {
            final data = placeDoc.data();
            final location = data['location'] as Map<String, dynamic>?;
            final latNum = location?['latitude'] as num?;
            final lngNum = location?['longitude'] as num?;
            final lat = latNum?.toDouble();
            final lng = lngNum?.toDouble();
            final name = data['name'] ?? 'Unnamed';
            final type = subcol;

            if (lat != null && lng != null) {
              print('✅ $type: $name at ($lat, $lng) in $cityName');

              // Generate initials and color for the marker
              final initials = _getInitials(name);
              final color = _getColor(name, type);

              final marker = Marker(
                point: latLng.LatLng(lat, lng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$name ($type)'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );

              tempMarkers.add(_PlaceMarker(marker, name));
            } else {
              print('❌ Missing coordinates for $name in $cityName ($type)');
            }
          }
        }
      }

      setState(() {
        _allPlaceMarkers = tempMarkers;
        _filteredPlaceMarkers = List.from(tempMarkers);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching places: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading places: $e')),
      );
    }
  }

  /// Returns initials from a place name (max 2 characters)
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    } else {
      return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
          .toUpperCase();
    }
  }

  /// Returns a consistent color based on place name and type
  Color _getColor(String name, String type) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.brown,
      Colors.amber,
    ];
    int hash = (name + type).hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search places...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredPlaceMarkers.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'No places with coordinates found.\nAdd latitude/longitude inside a "location" map in your place documents.'
                        : 'No places match your search.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _filteredPlaceMarkers.isNotEmpty
                        ? _filteredPlaceMarkers.first.marker.point
                        : _defaultCenter,
                    initialZoom: 10,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.maptiler.com/maps/outdoor/256/{z}/{x}/{y}.png?key=hEMxVy08camnprepOea3',
                      userAgentPackageName: 'com.example.city_guide_app',
                    ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 60,
                        size: const Size(40, 40),
                        markers: _filteredPlaceMarkers
                            .map((pm) => pm.marker)
                            .toList(),
                        polygonOptions: const PolygonOptions(
                          borderColor: Colors.blue,
                          color: Colors.black12,
                          borderStrokeWidth: 3,
                        ),
                        builder: (context, markers) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.blue,
                            ),
                            child: Center(
                              child: Text(
                                markers.length.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        centerMarkerOnClick: true,
                      ),
                    ),
                  ],
                ),
    );
  }
}

/// Helper class to associate a marker with its place name
class _PlaceMarker {
  final Marker marker;
  final String name;

  _PlaceMarker(this.marker, this.name);
}