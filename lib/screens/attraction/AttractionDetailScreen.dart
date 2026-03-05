import 'dart:async';
import 'package:city_guide_app/screens/CityguideHome/CityListScreen.dart';
import 'package:city_guide_app/widgets/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final String listingType;

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
    required this.listingType,
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

  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _loadingReviews = true;
  String? _reviewsError;
  List<bool> _expandedReviews = [];

  String _hashtag = '';
  String _phoneNumber = '';
  String? _cityId;
  String? _listingId;
  String? _currentUserId;

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

    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _fetchAttractionData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttractionData() async {
    setState(() {
      _loadingReviews = true;
      _reviewsError = null;
    });

    try {
      final cityQuery = await FirebaseFirestore.instance
          .collection('cities')
          .where('name', isEqualTo: widget.city.trim())
          .limit(1)
          .get();

      if (cityQuery.docs.isEmpty) {
        setState(() => _loadingReviews = false);
        return;
      }
      _cityId = cityQuery.docs.first.id;

      final query = await FirebaseFirestore.instance
          .collection('cities')
          .doc(_cityId!)
          .collection(widget.listingType)
          .where('name', isEqualTo: widget.name.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _listingId = query.docs.first.id;
        final data = query.docs.first.data();
        _hashtag = data['hashtag'] ?? '';
        _phoneNumber = data['phoneNumber'] ?? '';
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('cities')
            .doc(_cityId!)
            .collection(widget.listingType)
            .doc(widget.name)
            .get();

        if (doc.exists) {
          _listingId = doc.id;
          final data = doc.data() as Map<String, dynamic>;
          _hashtag = data['hashtag'] ?? '';
          _phoneNumber = data['phoneNumber'] ?? '';
        } else {
          setState(() => _loadingReviews = false);
          return;
        }
      }

      _setupReviewsStream();
    } catch (e) {
      print('Error in _fetchAttractionData: $e');
      setState(() {
        _reviewsError = e.toString();
        _loadingReviews = false;
      });
    }
  }

  void _setupReviewsStream() {
    if (_cityId == null || _listingId == null) return;

    _reviewService.getListingReviews(
      cityId: _cityId!,
      listingId: _listingId!,
      listingType: widget.listingType,
    ).listen((reviews) {
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _loadingReviews = false;
          _expandedReviews = List<bool>.filled(reviews.length, false);
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

  // FIXED: pass only reviewId to like/unlike
  Future<void> _toggleLike(ReviewModel review) async {
    if (_currentUserId == null) {
      _showSnackBar('You must be logged in to like reviews');
      return;
    }

    try {
      if (review.likedBy.contains(_currentUserId)) {
        await _reviewService.unlikeReview(review.id!);
      } else {
        await _reviewService.likeReview(review.id!);
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
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
    if (widget.latitude == null || widget.longitude == null) {
      _showSnackBar('Location coordinates are not available.');
      return;
    }
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Please enable location services.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission required.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions permanently denied.');
        return;
      }
      Position position = await Geolocator.getCurrentPosition();
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
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _getItemType(String listingType) {
    switch (listingType) {
      case 'attractions': return 'attraction';
      case 'dining': return 'restaurant';
      case 'hotels': return 'hotel';
      case 'events': return 'event';
      default: return 'attraction';
    }
  }

  Widget _buildImageWithPlaceholder(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey.shade300, Colors.grey.shade100, Colors.grey.shade300],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: AppTheme.primaryBlue,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade400, Colors.grey.shade200, Colors.grey.shade400],
          ),
        ),
        child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey.shade600)),
      ),
    );
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
        title: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          FavoriteButton(
            itemId: _listingId ?? widget.name.replaceAll(' ', '_').toLowerCase(),
            itemType: _getItemType(widget.listingType),
            name: widget.name,
            imageUrl: widget.imageUrl,
            cityName: widget.city,
            rating: widget.rating,
            priceLevel: widget.priceLevel,
            address: widget.address,
            description: widget.description,
            latitude: widget.latitude,
            longitude: widget.longitude,
            additionalImages: widget.additionalImages,
            website: widget.website,
            phoneNumber: _phoneNumber,
            size: 22,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: 4,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemBuilder: (_, index) => _buildImageWithPlaceholder(_allImages[index]),
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
                            color: _currentIndex == index ? Colors.white : Colors.white54,
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
                      _badge(_firstTag, const Color.fromARGB(30, 46, 91, 255), AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      if (_phoneNumber.isNotEmpty)
                        _badge("CALL NOW", Colors.green.shade100, Colors.green.shade700),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
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
                  const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: Text(widget.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(height: 1.6)),
                    secondChild: Text(widget.description, style: const TextStyle(height: 1.6)),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Text(
                      _isExpanded ? "Show less" : "Read more",
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (_phoneNumber.isNotEmpty) ...[
                    const Text("Contact", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final Uri phoneUri = Uri(scheme: 'tel', path: _phoneNumber);
                        if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.phone, color: Colors.green.shade700),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_phoneNumber, style: TextStyle(color: Colors.green.shade700, fontSize: 16))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (hasValidLocation)
                        GestureDetector(
                          onTap: _openMaps,
                          child: Text("See on Map", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                        )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.address.isNotEmpty ? "${widget.address}, ${widget.city}" : widget.city,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),

                  if (hasValidLocation)
                    GestureDetector(
                      onTap: _openMaps,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: latLng.LatLng(widget.latitude!, widget.longitude!),
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
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
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey.shade200),
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
                                listingId: _listingId!,
                                listingType: widget.listingType,
                                listingName: widget.name,
                              ),
                            ),
                          );
                          if (result == true) _showSnackBar('Review submitted for approval!');
                        },
                        child: Text("Write a review", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reviews list
                  _loadingReviews
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
                      : _reviewsError != null
                          ? Center(
                              child: Column(
                                children: [
                                  Text('Error loading reviews: $_reviewsError'),
                                  ElevatedButton(
                                    onPressed: _fetchAttractionData,
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
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

                  if (widget.website.isNotEmpty) ...[
                    const Text("Official Website", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _openWebsite,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new, color: AppTheme.primaryBlue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(widget.website, style: TextStyle(color: AppTheme.primaryBlue), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: hasValidLocation ? _openDirections : null,
                      icon: const Icon(Icons.directions),
                      label: const Text("Get Directions"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
          if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const CityListScreen()));
        },
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // Review card with like button
  Widget _buildReviewCard(int index) {
    final review = _reviews[index];
    final isExpanded = _expandedReviews[index];
    final isLiked = review.likedBy.contains(_currentUserId);
    final likeCount = review.likes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.userProfileImage.isNotEmpty ? NetworkImage(review.userProfileImage) : null,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
                child: review.userProfileImage.isEmpty
                    ? Text(
                        review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(_formatDate(review.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
              const SizedBox(width: 8),
              // Like button
              GestureDetector(
                onTap: () => _toggleLike(review),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_off_alt_outlined,
                      color: isLiked ? Colors.blue : Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likeCount.toString(),
                      style: TextStyle(
                        color: isLiked ? Colors.blue : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Text(review.reviewText, maxLines: 3, overflow: TextOverflow.ellipsis),
            secondChild: Text(review.reviewText),
          ),
          if (review.reviewText.length > 100)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GestureDetector(
                onTap: () => setState(() => _expandedReviews[index] = !_expandedReviews[index]),
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
    if (count >= 1000) return "${(count / 1000).toStringAsFixed(1)}k";
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