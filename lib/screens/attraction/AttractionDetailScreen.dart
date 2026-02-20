import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/map/MapScreen.dart';
import '../../utils/theme.dart';
import '../../screens/review/WriteReviewScreen.dart';
import 'package:city_guide_app/widgets/floating_bottom_nav_bar.dart';

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
  });

  @override
  State<AttractionDetailScreen> createState() =>
      _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  late PageController _pageController;
  late List<String> _allImages;
  int _currentIndex = 0;
  Timer? _timer;
  bool _isExpanded = false;
  int _currentNavIndex = 0;

  // Reviews
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = true;
  String? _reviewsError;
  List<bool> _expandedReviews = []; // for expand/collapse
  Set<int> _likedReviews = {}; // indices of liked reviews

  // Hashtag (for badge)
  String _hashtag = '';

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

  /// Fetch attraction document to get reviews array and hashtag
  Future<void> _fetchAttractionData() async {
    setState(() {
      _loadingReviews = true;
      _reviewsError = null;
    });

    try {
      // 1. Find city document by name
      final cityQuery = await FirebaseFirestore.instance
          .collection('cities')
          .where('name', isEqualTo: widget.city)
          .limit(1)
          .get();

      if (cityQuery.docs.isEmpty) {
        throw Exception('City not found');
      }
      final cityId = cityQuery.docs.first.id;

      // 2. Find attraction document (assuming 'attractions' subcollection)
      final attractionQuery = await FirebaseFirestore.instance
          .collection('cities')
          .doc(cityId)
          .collection('attractions')
          .where('name', isEqualTo: widget.name)
          .limit(1)
          .get();

      if (attractionQuery.docs.isEmpty) {
        // Maybe it's in a different subcollection? We'll just return empty.
        setState(() {
          _reviews = [];
          _loadingReviews = false;
        });
        return;
      }

      final doc = attractionQuery.docs.first;
      final data = doc.data();

      // Extract hashtag
      _hashtag = data['hashtag'] ?? '';

      // Extract reviews array (if any)
      final List<dynamic>? reviewsArray = data['reviews'];
      if (reviewsArray != null) {
        _reviews = reviewsArray.map<Map<String, dynamic>>((review) {
          return {
            'userName': review['profileName'] ?? 'Anonymous',
            'timeAgo': _formatDateString(review['createdAt']),
            'rating': review['starRatings'] ?? 0,
            'comment': review['reviewDetails'] ?? '',
            'likes': review['likes'] ?? 0,
          };
        }).toList();
        // Initialize expand/collapse list
        _expandedReviews = List<bool>.filled(_reviews.length, false);
      }

      setState(() {
        _loadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _reviewsError = e.toString();
        _loadingReviews = false;
      });
    }
  }

  /// Convert date string like "2025-12-05" to relative time
  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Recently';
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final date = DateTime(year, month, day);
        final now = DateTime.now();
        final diff = now.difference(date);
        if (diff.inDays < 1) return 'Today';
        if (diff.inDays < 7) return '${diff.inDays} days ago';
        if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
        if (diff.inDays < 365) return '${diff.inDays ~/ 30} months ago';
        return '${diff.inDays ~/ 365} years ago';
      }
    } catch (_) {}
    return dateStr ?? 'Recently';
  }

  /// Get first tag from hashtag string
  String get _firstTag {
    if (_hashtag.isEmpty) return 'ATTRACTION';
    final tags = _hashtag.split(' ');
    return tags.first.toUpperCase();
  }

  void _toggleLike(int index) {
    setState(() {
      if (_likedReviews.contains(index)) {
        _likedReviews.remove(index);
        _reviews[index]['likes'] = (_reviews[index]['likes'] as int) - 1;
      } else {
        _likedReviews.add(index);
        _reviews[index]['likes'] = (_reviews[index]['likes'] as int) + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            /// ================= IMAGE SLIDESHOW =================
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
                      );
                    },
                  ),
                  /// Dots Indicator
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
                  /// BADGES – dynamic from hashtag
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

                  /// TITLE
                  Text(
                    widget.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  /// RATING
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(widget.rating.toStringAsFixed(1)),
                      const SizedBox(width: 8),
                      Text(
                        "• ${_formatReviewCount(widget.reviewCount)} Reviews • ${widget.priceLevel}",
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// ABOUT
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

                  /// LOCATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

                  /// Map placeholder
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade200,
                    ),
                    child: const Center(child: Icon(Icons.map, size: 40)),
                  ),
                  const SizedBox(height: 30),

                  /// REVIEWS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WriteReviewScreen(
                                attractionName: widget.name,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Write a review",
                          style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Reviews List
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

                  /// WEBSITE
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// GET DIRECTIONS
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openMaps,
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
                  /// Extra bottom spacing to clear the floating nav bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
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

  Widget _buildReviewCard(int index) {
    final review = _reviews[index];
    final isExpanded = _expandedReviews[index];
    final isLiked = _likedReviews.contains(index);
    final likes = review['likes'] as int;

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
                child: Text(review['userName'][0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['userName'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(review['timeAgo'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleLike(index),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isLiked ? Colors.red : AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(likes.toString()),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Text(
              review['comment'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(review['comment']),
          ),
          const SizedBox(height: 6),
          GestureDetector(
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
    await launchUrl(url, mode: LaunchMode.externalApplication);
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