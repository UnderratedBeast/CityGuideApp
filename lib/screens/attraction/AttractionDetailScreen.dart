import 'dart:async';
import 'package:city_guide_app/screens/CityguideHome/CityListScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import '../../screens/map/MapScreen.dart';
import '../../utils/theme.dart';
import '../review/AddReviewScreen.dart';
import '../../services/review_service.dart';
import '../../models/review_model.dart';
import 'package:city_guide_app/widgets/floating_bottom_nav_bar.dart';
import '../../screens/profile/profile_screen.dart';

class AttractionDetailScreen extends StatefulWidget {
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String priceLevel;
  final String description;
  final String address;
  final String city;
  final String website;
  final double? latitude;
  final double? longitude;
  final List<String>? additionalImages;
  final String listingType; // ADD THIS - identifies which collection (attractions, hotels, dining, events)

  const AttractionDetailScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.priceLevel,
    required this.description,
    required this.address,
    required this.city,
    required this.website,
    this.latitude,
    this.longitude,
    this.additionalImages,
    required this.listingType, // ADD THIS
  });

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  late PageController _pageController;
  late List<String> _allImages;
  int _currentIndex = 0;
  Timer? _timer;
  bool _isExpanded = false;
  int _currentNavIndex = 0;

  // Reviews - Using Stream from ReviewService
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _loadingReviews = true;
  String? _reviewsError;
  List<bool> _expandedReviews = [];
  Set<int> _likedReviews = {};

  // Hashtag (for badge)
  String _hashtag = '';

  // Phone number (optional, from Firestore)
  String _phoneNumber = '';

  // Document IDs needed for review submission
  String? _cityId;
  String? _listingId;

  @override
  void initState() {
    super.initState();

    _allImages = [
      widget.imageUrl,
      ...?widget.additionalImages,
    ];

    while (_allImages.length < 4) {
      _allImages.add(widget.imageUrl);
    }
    _allImages = _allImages.take(4).toList();

    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentIndex + 1) % 4;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    _fetchAttractionData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Fetch attraction document to get hashtag, phone, and set up reviews stream
  Future<void> _fetchAttractionData() async {
    setState(() {
      _loadingReviews = true;
      _reviewsError = null;
    });

    try {
      // 1. Find city document by name
      final cityQuery = await FirebaseFirestore.instance
          .collection('cities')
          .where('name', isEqualTo: widget.city.trim())
          .limit(1)
          .get();

      if (cityQuery.docs.isEmpty) {
        throw Exception('City "${widget.city}" not found.');
      }
      _cityId = cityQuery.docs.first.id;

      // 2. Find document using the provided listingType (faster and more reliable)
      final doc = await FirebaseFirestore.instance
          .collection('cities')
          .doc(_cityId)
          .collection(widget.listingType) // Use the passed listingType
          .doc(widget.name) // Try with name first
          .get();

      if (doc.exists) {
        _listingId = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        _hashtag = data['hashtag'] ?? '';
        _phoneNumber = data['phoneNumber'] ?? '';
      } else {
        // If not found by name, try searching by name field (fallback)
        final query = await FirebaseFirestore.instance
            .collection('cities')
            .doc(_cityId)
            .collection(widget.listingType)
            .where('name', isEqualTo: widget.name.trim())
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          _listingId = query.docs.first.id;
          final data = query.docs.first.data() as Map<String, dynamic>;
          _hashtag = data['hashtag'] ?? '';
          _phoneNumber = data['phoneNumber'] ?? '';
        } else {
          setState(() {
            _loadingReviews = false;
          });
          return;
        }
      }

      // Set up real-time reviews stream
      _setupReviewsStream();
      
    } catch (e) {
      setState(() {
        _reviewsError = e.toString();
        _loadingReviews = false;
      });
    }
  }

  // Set up stream for approved reviews
  void _setupReviewsStream() {
    if (_cityId == null || _listingId == null) return;

    _reviewService.getListingReviews(
      cityId: _cityId!,
      listingId: _listingId!,
      listingType: widget.listingType, // Use the passed listingType
    ).listen((reviews) {
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _loadingReviews = false;
          _expandedReviews = List<bool>.filled(reviews.length, false);
          _likedReviews.clear();
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _reviewsError = error.toString();
          _loadingReviews = false;
        });
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';
    
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30} months ago';
    return '${diff.inDays ~/ 365} years ago';
  }

  String get _firstTag {
    if (_hashtag.isEmpty) return widget.listingType.toUpperCase();
    final tags = _hashtag.split(' ');
    return tags.first.toUpperCase();
  }

  Future<void> _openDirections() async {
    // Safety check: ensure we have valid destination coordinates
    if (widget.latitude == null || widget.longitude == null) {
      _showSnackBar('Location coordinates are not available for this place.');
      return;
    }

    try {
      // 1. Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Please enable location services to get directions.');
        return;
      }

      // 2. Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission is required to show directions.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied. Please enable them in app settings.');
        return;
      }

      // 3. Get current position
      Position position = await Geolocator.getCurrentPosition();

      // 4. Navigate to MapScreen with both locations
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            name: widget.name,
            rating: widget.rating,
            address: widget.address,
            latitude: widget.latitude!,
            longitude: widget.longitude!,
            userLatitude: position.latitude,
            userLongitude: position.longitude,
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('Error in _openDirections: $e\n$stack');
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final hasValidLocation = widget.latitude != null && widget.longitude != null;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          widget.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.share_outlined),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image slideshow
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: 4,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (_, index) {
                      return Image.network(
                        _allImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.broken_image, size: 50)),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == index ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      _badge(
                        _firstTag,
                        const Color.fromARGB(30, 46, 91, 255),
                        AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      _badge(
                        "OPEN NOW",
                        Colors.green.shade100,
                        Colors.green.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(widget.rating.toStringAsFixed(1)),
                      const SizedBox(width: 8),
                      Text(
                        "• ${_reviews.length} Reviews • ${widget.priceLevel}",
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),

                  // About
                  const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Text(
                      widget.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(height: 1.6),
                    ),
                    secondChild: Text(
                      widget.description,
                      style: const TextStyle(height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 6),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? "Show less" : "Read more",
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Location with mini map
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (hasValidLocation)
                        GestureDetector(
                          onTap: _openMaps,
                          child: Text(
                            "See on Map",
                            style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${widget.address}, ${widget.city}",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),

                  // Mini map preview (tappable)
                  if (hasValidLocation)
                    GestureDetector(
                      onTap: _openMaps,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: latLng.LatLng(widget.latitude!, widget.longitude!),
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://api.maptiler.com/maps/outdoor/256/{z}/{x}/{y}.png?key=hEMxVy08camnprepOea3',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: latLng.LatLng(widget.latitude!, widget.longitude!),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.shade200,
                      ),
                      child: const Center(child: Text('Location not available')),
                    ),
                  const SizedBox(height: 30),

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () async {
                          if (_cityId == null || _listingId == null) {
                            _showSnackBar('Error: Cannot find listing information');
                            return;
                          }
                          
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReviewScreen(
                                cityId: _cityId!,
                                listingId: _listingId!, // This is the correct document ID (with hyphens)
                                listingType: widget.listingType, // This is dynamic (attractions/hotels/dining/events)
                                listingName: widget.name,
                              ),
                            ),
                          );
                          if (result == true) {
                            _showSnackBar('Review submitted for approval!');
                          }
                        },
                        child: Text(
                          "Write a review",
                          style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reviews list
                  _loadingReviews
                      ? const Center(child: CircularProgressIndicator())
                      : _reviewsError != null
                          ? Center(
                              child: Column(
                                children: [
                                  Text('Error loading reviews: $_reviewsError'),
                                  ElevatedButton(
                                    onPressed: _fetchAttractionData,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _reviews.isEmpty
                              ? const Center(child: Text('No reviews yet'))
                              : Column(
                                  children: List.generate(_reviews.length, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _buildReviewCard(index),
                                    );
                                  }),
                                ),

                  const SizedBox(height: 30),

                  // Website (if available)
                  if (widget.website.isNotEmpty) ...[
                    const Text("Official Website", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _openWebsite,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color.fromARGB(255, 136, 159, 238)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new, color: AppTheme.primaryBlue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.website,
                                style: TextStyle(color: AppTheme.primaryBlue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Get Directions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: hasValidLocation ? _openDirections : null,
                      icon: const Icon(Icons.directions),
                      label: const Text("Get Directions"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: -1,
        onTap: (index) {
           if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
          if (index == 0) {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CityListScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Review card using ReviewModel
  Widget _buildReviewCard(int index) {
    final review = _reviews[index];
    final isExpanded = _expandedReviews[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(74, 46, 91, 255),
                child: Text(review.userName[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(_formatDate(review.createdAt), 
                         style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              // Rating stars
              Row(
                children: List.generate(5, (starIndex) {
                  return Icon(
                    starIndex < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Text(
              review.reviewText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(review.reviewText),
          ),
          if (review.reviewText.length > 100)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedReviews[index] = !_expandedReviews[index];
                  });
                },
                child: Text(
                  isExpanded ? "Show less" : "Read more",
                  style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}k";
    }
    return count.toString();
  }

  Future<void> _openWebsite() async {
    final Uri url = Uri.parse(widget.website);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not launch website.');
    }
  }

  Future<void> _openMaps() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          name: widget.name,
          rating: widget.rating,
          address: widget.address,
          latitude: widget.latitude ?? 0,
          longitude: widget.longitude ?? 0,
        ),
      ),
    );
  }
}