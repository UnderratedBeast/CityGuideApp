import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:cloud_firestore/cloud_firestore.dart';

class AllPlacesMapScreen extends StatefulWidget {
  const AllPlacesMapScreen({super.key});

  @override
  State<AllPlacesMapScreen> createState() => _AllPlacesMapScreenState();
}

class _AllPlacesMapScreenState extends State<AllPlacesMapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _isLoading = true;

  // List of subcollection names to fetch
  final List<String> _subcollections = ['attractions', 'hotels', 'dining', 'events'];

  @override
  void initState() {
    super.initState();
    _fetchAllPlaces();
  }

  /// Fetch all cities and then all places from their subcollections
  Future<void> _fetchAllPlaces() async {
    try {
      // Step 1: Fetch all city documents
      final citiesSnapshot = await FirebaseFirestore.instance.collection('cities').get();
      final allMarkers = <Marker>[];

      // Step 2: For each city, fetch places from all subcollections
      for (var cityDoc in citiesSnapshot.docs) {
        final cityName = cityDoc.data()['name'] ?? 'Unknown City';

        for (String subcol in _subcollections) {
          final subSnapshot = await cityDoc.reference.collection(subcol).get();

          for (var placeDoc in subSnapshot.docs) {
            final data = placeDoc.data();

            // Extract coordinates from nested 'location' map
            final location = data['location'] as Map<String, dynamic>?;
            // Use num to accept int or double, then convert to double
            final latNum = location?['latitude'] as num?;
            final lngNum = location?['longitude'] as num?;
            final lat = latNum?.toDouble();
            final lng = lngNum?.toDouble();
            final name = data['name'] ?? 'Unnamed';
            final type = subcol; // e.g., "attraction", "hotel", etc.

            if (lat != null && lng != null) {
              print('✅ $type: $name at ($lat, $lng) in $cityName');
              allMarkers.add(
                Marker(
                  point: latLng.LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      // Show a snackbar with place info; optionally navigate to detail screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$name ($type)'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              );
            } else {
              print('❌ Missing coordinates for $name in $cityName ($type)');
            }
          }
        }
      }

      setState(() {
        _markers = allMarkers;
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
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search places...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _markers.isEmpty
              ? const Center(
                  child: Text(
                    'No places with coordinates found.\nAdd latitude/longitude inside a "location" map in your place documents.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    // Center on the first marker (usually Abuja)
                    initialCenter: _markers.first.point,
                    initialZoom: 10,
                  ),
                  children: [
                    // Use OpenStreetMap for testing (no API key required)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    // Clustered markers
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 60,
                        size: const Size(40, 40),
                        markers: _markers,
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