import 'package:flutter/material.dart';
import 'package:city_guide_app/screens/attraction/AttractionDetailScreen.dart';

class AttractionListScreen extends StatelessWidget {
  final String category;
  final String cityName;

  const AttractionListScreen({
    super.key,
    required this.category,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final List<AttractionItem> items = [
      AttractionItem(
        title: "L'Osteria Urbano",
        imageUrl: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&auto=format",
        additionalImages: [
          "https://images.unsplash.com/photo-1579684947550-22e945225d9a?w=500&auto=format",
          "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&auto=format",
          "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&auto=format",
        ],
        description: "Authentic Italian pasta and wood‑fired pizza in a cozy downtown setting.",
        phone: "+1 212-555-1234",
        website: "losteria.com",
        openingHours: "Mon–Sun 11:00–23:00",
        rating: 4.8,
        priceLevel: "\$\$\$",
        popularity: "Very Popular",
        cuisine: "Italian",
        location: "Downtown",
        distance: "0.8 mi",
        actions: ["Book Table"],
        isOpen: true,
        reviewCount: 1240,
        address: "42nd Ave, Stay Tower",
        latitude: 40.7580,
        longitude: -73.9855,
        city: "New York City",
      ),
      AttractionItem(
        title: "The Blue Grill",
        imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format",
        additionalImages: [
          "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=500&auto=format",
          "https://images.unsplash.com/photo-1611143669185-5522241f25ab?w=500&auto=format",
          "https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=500&auto=format",
        ],
        description: "Premium steaks and seafood with panoramic waterfront views.",
        phone: "+1 212-555-5678",
        website: "bluegrill.nyc",
        openingHours: "Tue–Sun 17:00–23:00",
        rating: 4.5,
        priceLevel: "\$\$\$\$",
        popularity: "Fine Dining",
        cuisine: "Steakhouse",
        location: "Waterfront",
        distance: "1.2 mi",
        actions: ["View Menu"],
        isOpen: true,
        reviewCount: 890,
        address: "1 Waterfront Plaza, NYC",
        latitude: 40.7050,
        longitude: -74.0130,
        city: "New York City",
      ),
      AttractionItem(
        title: "Neon Sushi",
        imageUrl: "https://images.unsplash.com/photo-1553621042-f6e147245754?w=500&auto=format",
        additionalImages: [
          "https://images.unsplash.com/photo-1617196035154-1e7e6e28b0db?w=500&auto=format",
          "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500&auto=format",
          "https://images.unsplash.com/photo-1611143669185-5522241f25ab?w=500&auto=format",
        ],
        description: "Creative rolls and sake in a vibrant, artsy atmosphere.",
        phone: "+1 212-555-9012",
        website: "neonsushi.com",
        openingHours: "Mon–Sat 12:00–22:30",
        rating: 4.2,
        priceLevel: "\$\$",
        popularity: "Trendy",
        cuisine: "Japanese",
        location: "Arts District",
        distance: "0.5 mi",
        actions: ["Order Now"],
        isOpen: false,
        reviewCount: 562,
        address: "45 Arts District Blvd, NYC",
        latitude: 40.7290,
        longitude: -73.9920,
        city: "New York City",
      ),
      AttractionItem(
        title: "The Patty Club",
        imageUrl: "https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500&auto=format",
        additionalImages: [
          "https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format",
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format",
          "https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format",
        ],
        description: "Juicy burgers, craft beers, and retro vibes.",
        phone: "+1 212-555-3456",
        website: "pattyclub.nyc",
        openingHours: "Mon–Sun 10:00–02:00",
        rating: 4.3,
        priceLevel: "\$\$",
        popularity: "Casual",
        cuisine: "American",
        location: "Midtown",
        distance: "2.1 mi",
        actions: ["Map View", "Directions"],
        isOpen: true,
        reviewCount: 2100,
        address: "123 Midtown Ave, NYC",
        latitude: 40.7540,
        longitude: -73.9840,
        city: "New York City",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Top $category",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey.shade800),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FilterChip(label: "Price"),
                Container(width: 1, height: 20, color: Colors.grey.shade300),
                _FilterChip(label: "Rating"),
                Container(width: 1, height: 20, color: Colors.grey.shade300),
                _FilterChip(label: "Category"),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AttractionCard(item: item),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple.shade700,
        unselectedItemColor: Colors.grey.shade500,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "General"),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Filter Chip
// ------------------------------------------------------------
class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Attraction Card – with navigation to detail screen
// ------------------------------------------------------------
class _AttractionCard extends StatefulWidget {
  final AttractionItem item;
  const _AttractionCard({required this.item});

  @override
  State<_AttractionCard> createState() => _AttractionCardState();
}

class _AttractionCardState extends State<_AttractionCard> {
  bool isFavorited = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttractionDetailScreen(
              name: item.title,
              imageUrl: item.imageUrl,
              additionalImages: item.additionalImages,
              rating: item.rating,
              reviewCount: item.reviewCount,
              priceLevel: item.priceLevel,
              description: item.description,
              address: item.address,
              city: item.city,
              website: item.website,
              latitude: item.latitude,
              longitude: item.longitude,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- IMAGE WITH OVERLAYS -----
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    item.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                // Favorite heart (toggle)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => isFavorited = !isFavorited),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? Colors.red : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Open/Closed badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.isOpen ? "OPEN" : "CLOSED",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ----- CONTENT -----
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Cuisine • location • distance
                  Text(
                    "${item.cuisine} • ${item.location} • ${item.distance}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description (2 lines max)
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // ----- CONTACT & OPENING HOURS -----
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        item.phone,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.language, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        item.website,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Opening hours
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        item.openingHours,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ----- RATING & ACTION BUTTON -----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating with stars
                      Row(
                        children: [
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            children: List.generate(5, (index) {
                              if (index < item.rating.floor()) {
                                return const Icon(Icons.star, color: Colors.amber, size: 18);
                              } else if (index < item.rating) {
                                return const Icon(Icons.star_half, color: Colors.amber, size: 18);
                              } else {
                                return Icon(Icons.star_border, color: Colors.amber.shade300, size: 18);
                              }
                            }),
                          ),
                        ],
                      ),
                      // Action button
                      ElevatedButton(
                        onPressed: () {
                          // Button action (book, order, etc.)
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.actions.contains("Map") || item.actions.contains("Directions")
                              ? Colors.grey.shade100
                              : Colors.purple.shade600,
                          foregroundColor: item.actions.contains("Map") || item.actions.contains("Directions")
                              ? Colors.grey.shade800
                              : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          item.actions.first,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Data Model
// ------------------------------------------------------------
class AttractionItem {
  final String title;
  final String imageUrl;
  final String description;
  final String phone;
  final String website;
  final String openingHours;
  final double rating;
  final String priceLevel;
  final String popularity;
  final String cuisine;
  final String location;
  final String distance;
  final List<String> actions;
  final bool isOpen;
  final int reviewCount;
  final String address;
  final double latitude;
  final double longitude;
  final String city;
  final List<String>? additionalImages;

  AttractionItem({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.phone,
    required this.website,
    required this.openingHours,
    required this.rating,
    required this.priceLevel,
    required this.popularity,
    required this.cuisine,
    required this.location,
    required this.distance,
    required this.actions,
    required this.isOpen,
    required this.reviewCount,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.city,
    this.additionalImages,
  });
}
