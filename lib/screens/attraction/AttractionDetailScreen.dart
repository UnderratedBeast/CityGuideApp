import 'package:flutter/material.dart';

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
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  late List<String> _allImages;

  @override
  void initState() {
    super.initState();
    _allImages = [
      widget.imageUrl,
      ...?widget.additionalImages,
    ];
    while (_allImages.length < 4) {
      _allImages.add(_allImages.isNotEmpty ? _allImages.last : widget.imageUrl);
    }
    _allImages = _allImages.take(4).toList();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 161, 73, 73),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ----- MAIN IMAGE WITH THUMBNAIL OVERLAY -----
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _allImages.length,
                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) => Image.network(
                          _allImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
                          ),
                        ),
                      ),
                    ),

Positioned(
  bottom: 16,
  left: 0,
  right: 0,
  child: Center(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 👈 IMPORTANT
        children: List.generate(_allImages.length, (index) {
          final isSelected = index == _currentImageIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    _allImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
  ),
)

                  
                  ],
                ),
              ),
            ),
            
            
            const SizedBox(height: 20),

            // ----- CONTENT -----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' · ${_formatReviewCount(widget.reviewCount)} Reviews · ',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      Text(
                        widget.priceLevel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // About
                  const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Read more',
                      style: TextStyle(color: Colors.purple.shade600, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location
                  const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'See on Map',
                      style: TextStyle(color: Colors.purple.shade600, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.address}\n${widget.city}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://maps.googleapis.com/maps/api/staticmap?center=${widget.latitude ?? 40.7580},${widget.longitude ?? -73.9855}&zoom=15&size=600x300&maptype=roadmap&markers=color:purple%7C${widget.latitude ?? 40.7580},${widget.longitude ?? -73.9855}&key=YOUR_API_KEY',
                        ),
                        fit: BoxFit.cover,
                        onError: (_, __) => const SizedBox(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: Colors.purple.shade600),
                        child: const Text('Write a review'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReviewCard(
                    userName: 'Sarah Jenkins',
                    timeAgo: '2 DAYS AGO',
                    ratingNumber: '12',
                    comment:
                        'The sunset views here are simply unmatched! Get there about 30 mins before golden hour. Highly recommended!',
                  ),
                  const SizedBox(height: 16),
                  _buildReviewCard(
                    userName: 'Mark Thompson',
                    timeAgo: '1 WEEK AGO',
                    ratingNumber: '4',
                    comment:
                        'A bit crowded on weekends, but the digital museum on the lower floor is actually very cool.',
                  ),
                  const SizedBox(height: 32),

                  // Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.directions, color: Colors.white),
                          label: const Text('Get Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.language, color: Colors.purple.shade600),
                          label: Text('Website', style: TextStyle(color: Colors.purple.shade600)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.purple.shade600),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  Widget _buildReviewCard({
    required String userName,
    required String timeAgo,
    required String ratingNumber,
    required String comment,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.purple.shade100,
                child: Text(
                  userName[0],
                  style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ratingNumber,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment, style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5)),
        ],
      ),
    );
  }
}
