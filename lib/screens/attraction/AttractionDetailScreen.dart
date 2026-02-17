import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/map/MapScreen.dart';
import '../../utils/theme.dart';

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

class _AttractionDetailScreenState
    extends State<AttractionDetailScreen> {
  late PageController _pageController;
  late List<String> _allImages;
  int _currentIndex = 0;
  Timer? _timer;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _allImages = [
      widget.imageUrl,
      ...?widget.additionalImages,
    ];

    // Ensure exactly 4 images
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      /// ✅ STATIC TOP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          widget.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18),
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
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4),
                          width: _currentIndex == index
                              ? 18
                              : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white54,
                            borderRadius:
                                BorderRadius.circular(20),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// BADGES
                  Row(
                    children: [
                      _badge("ARCHITECTURE",
                          const Color.fromARGB(30, 46, 91, 255),
                          AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      _badge("OPEN NOW",
                          Colors.green.shade100,
                          Colors.green.shade700),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// TITLE
                  Text(
                    widget.name,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// RATING
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(widget.rating
                          .toStringAsFixed(1)),
                      const SizedBox(width: 8),
                      Text(
                        "• ${_formatReviewCount(widget.reviewCount)} Reviews • ${widget.priceLevel}",
                        style: TextStyle(
                            color:
                                Colors.grey.shade600),
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// ABOUT
                  const Text("About",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold)),
                  const SizedBox(height: 10),

                  AnimatedCrossFade(
                    duration:
                        const Duration(milliseconds: 300),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Text(
                      widget.description,
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                          height: 1.6),
                    ),
                    secondChild: Text(
                      widget.description,
                      style: const TextStyle(
                          height: 1.6),
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
                      _isExpanded
                          ? "Show less"
                          : "Read more",
                      style: TextStyle(
                          color:
                              AppTheme.primaryBlue,
                          fontWeight:
                              FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// LOCATION
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Location",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold)),
                      GestureDetector(
                        onTap: _openMaps,
                        child: Text("See on Map",
                            style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight:
                                    FontWeight.w600)),
                      )
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${widget.address}, ${widget.city}",
                    style: TextStyle(
                        color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(16),
                      color: Colors.grey.shade200,
                    ),
                    child: const Center(
                        child: Icon(Icons.map,
                            size: 40)),
                  ),

                  const SizedBox(height: 30),

                  /// REVIEWS (RIGHT AFTER MAP)
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Reviews",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold)),
                      Text("Write a review",
                          style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight:
                                  FontWeight.w600)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _reviewCard(
                      "Sarah Jenkins",
                      "2 DAYS AGO",
                      "12",
                      "The sunset views here are simply unmatched! Get there about 30 mins before golden hour. Highly recommended!"),

                  const SizedBox(height: 16),

                  _reviewCard(
                      "Mark Thompson",
                      "1 WEEK AGO",
                      "4",
                      "A bit crowded on weekends, but the digital museum on the lower floor is actually very cool."),

                  const SizedBox(height: 30),

                  /// WEBSITE
                  const Text("Official Website",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold)),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: _openWebsite,
                    child: Container(
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                                16),
                        border: Border.all(
                            color: const Color.fromARGB(255, 136, 159, 238)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.open_in_new,
                              color: AppTheme.primaryBlue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.website,
                              style: TextStyle(
                                  color: AppTheme.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// GET DIRECTIONS (NOT STICKY)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.directions),
                      label:
                          const Text("Get Directions"),
                      style:
                          ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets
                                .symmetric(
                                    vertical: 16),
                        backgroundColor:
                            AppTheme.primaryBlue,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
   
   
    );
  }

  Widget _badge(
      String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight:
                FontWeight.w600),
      ),
    );
  }

  Widget _reviewCard(String name,
      String time, String likes, String comment) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    const Color.fromARGB(74, 46, 91, 255),
                child: Text(name[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight:
                                FontWeight.w600)),
                    Text(time,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors
                                .grey.shade600)),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.favorite,
                      size: 16,
                      color: AppTheme.primaryBlue),
                  const SizedBox(width: 4),
                  Text(likes),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(comment),
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
    final Uri url =
        Uri.parse(widget.website);
    await launchUrl(url,
        mode: LaunchMode.externalApplication);
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
}}
