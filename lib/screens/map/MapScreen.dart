import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:url_launcher/url_launcher.dart';
import '../../utils/theme.dart';

class MapScreen extends StatefulWidget {
  final String name;
  final double rating;
  final String address;
  final double latitude;
  final double longitude;
  final double? userLatitude;   // optional: user's current location
  final double? userLongitude;  // optional: user's current location

  const MapScreen({
    super.key,
    required this.name,
    required this.rating,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  late latLng.LatLng _destination;
  latLng.LatLng? _userLocation;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _destination = latLng.LatLng(widget.latitude, widget.longitude);
    if (widget.userLatitude != null && widget.userLongitude != null) {
      _userLocation = latLng.LatLng(widget.userLatitude!, widget.userLongitude!);
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
              hintText: 'Search attractions, dining...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? _destination,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/outdoor/256/{z}/{x}/{y}.png?key=hEMxVy08camnprepOea3',
                userAgentPackageName: 'com.example.app',
              ),
              // Destination marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _destination,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ],
              ),
              // User location marker (if available)
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.navigation, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              // Polyline (straight line) between user and destination
              if (_userLocation != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_userLocation!, _destination],
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
            ],
          ),

          // Bottom info card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                widget.rating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'OPEN NOW',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Attraction name and address
                    Text(
                      widget.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.address,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          icon: Icons.directions,
                          label: 'ROUTE',
                          onTap: () {
                            // Already on map, maybe show route info or do nothing
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.phone,
                          label: 'CALL',
                          onTap: () async {
                            const phone = '+1234567890'; // replace with actual
                            final url = Uri.parse('tel:$phone');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.share,
                          label: 'SHARE',
                          onTap: () {
                            // Implement share
                          },
                        ),
                        _buildActionButton(
                          icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          label: 'SAVE',
                          onTap: () {
                            setState(() {
                              _isSaved = !_isSaved;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}