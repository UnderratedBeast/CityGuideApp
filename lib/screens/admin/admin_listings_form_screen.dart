// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AdminAttractionFormScreen extends StatefulWidget {
//   final String? attractionId; // null for create
//   final Map<String, dynamic>? existingData; // existing data for edit

//   const AdminAttractionFormScreen({super.key, this.attractionId, this.existingData});

//   @override
//   State<AdminAttractionFormScreen> createState() => _AdminAttractionFormScreenState();
// }

// class _AdminAttractionFormScreenState extends State<AdminAttractionFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final CollectionReference attractionsRef = FirebaseFirestore.instance.collection('attractions');

//   // Form fields
//   late TextEditingController _nameController;
//   late TextEditingController _cityController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _addressController;
//   late TextEditingController _websiteController;
//   late TextEditingController _imageUrlController;
//   late TextEditingController _additionalImagesController;
//   late TextEditingController _priceLevelController;
//   late TextEditingController _ratingController;

//   @override
//   void initState() {
//     super.initState();
//     final data = widget.existingData ?? {};
//     _nameController = TextEditingController(text: data['name'] ?? '');
//     _cityController = TextEditingController(text: data['city'] ?? '');
//     _descriptionController = TextEditingController(text: data['description'] ?? '');
//     _addressController = TextEditingController(text: data['address'] ?? '');
//     _websiteController = TextEditingController(text: data['website'] ?? '');
//     _imageUrlController = TextEditingController(text: data['imageUrl'] ?? '');
//     _additionalImagesController = TextEditingController(
//         text: (data['additionalImages'] as List<dynamic>?)?.join(', ') ?? '');
//     _priceLevelController = TextEditingController(
//         text: data['priceLevel']?.toString() ?? '0');
//     _ratingController = TextEditingController(
//         text: data['rating']?.toString() ?? '0');
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _cityController.dispose();
//     _descriptionController.dispose();
//     _addressController.dispose();
//     _websiteController.dispose();
//     _imageUrlController.dispose();
//     _additionalImagesController.dispose();
//     _priceLevelController.dispose();
//     _ratingController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveAttraction() async {
//     if (!_formKey.currentState!.validate()) return;

//     final data = {
//       'name': _nameController.text.trim(),
//       'city': _cityController.text.trim(),
//       'description': _descriptionController.text.trim(),
//       'address': _addressController.text.trim(),
//       'website': _websiteController.text.trim(),
//       'imageUrl': _imageUrlController.text.trim(),
//       'additionalImages': _additionalImagesController.text
//           .split(',')
//           .map((e) => e.trim())
//           .toList(),
//       'priceLevel': int.tryParse(_priceLevelController.text.trim()) ?? 0,
//       'rating': double.tryParse(_ratingController.text.trim()) ?? 0.0,
//       'updatedAt': FieldValue.serverTimestamp(),
//     };

//     try {
//       if (widget.attractionId != null) {
//         // Update
//         await attractionsRef.doc(widget.attractionId).update(data);
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Attraction updated')));
//       } else {
//         // Create
//         data['createdAt'] = FieldValue.serverTimestamp();
//         await attractionsRef.add(data);
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Attraction created')));
//       }
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.attractionId != null;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEdit ? 'Edit Attraction' : 'Add Attraction'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               _buildTextField(_nameController, 'Name'),
//               _buildTextField(_cityController, 'City'),
//               _buildTextField(_descriptionController, 'Description', maxLines: 3),
//               _buildTextField(_addressController, 'Address'),
//               _buildTextField(_websiteController, 'Website'),
//               _buildTextField(_imageUrlController, 'Main Image URL'),
//               _buildTextField(_additionalImagesController, 'Additional Image URLs (comma separated)'),
//               _buildTextField(_priceLevelController, 'Price Level', inputType: TextInputType.number),
//               _buildTextField(_ratingController, 'Rating', inputType: TextInputType.number),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _saveAttraction,
//                 child: Text(isEdit ? 'Update Attraction' : 'Add Attraction'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String label,
//       {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: inputType,
//         maxLines: maxLines,
//         validator: (value) => value == null || value.isEmpty ? 'Required' : null,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_notification_service.dart';
import '../../utils/helpers.dart';

class AdminListingFormScreen extends StatefulWidget {
  final String cityId;
  final String collectionName; // attractions | hotels | dining | events
  final String? listingId;
  final Map<String, dynamic>? existingData;

  const AdminListingFormScreen({
    super.key,
    required this.cityId,
    required this.collectionName,
    this.listingId,
    this.existingData,
  });

  @override
  State<AdminListingFormScreen> createState() =>
      _AdminListingFormScreenState();
}

class _AdminListingFormScreenState
    extends State<AdminListingFormScreen> {

  final _formKey = GlobalKey<FormState>();
  late CollectionReference listingsRef;

  // Controllers
final TextEditingController _name = TextEditingController();
final TextEditingController _description = TextEditingController();
final TextEditingController _address = TextEditingController();
final TextEditingController _website = TextEditingController();
final TextEditingController _imageUrl = TextEditingController();
final TextEditingController _additionalImages = TextEditingController();
final TextEditingController _priceLevel = TextEditingController();
final TextEditingController _rating = TextEditingController();
final TextEditingController _latitude = TextEditingController();
final TextEditingController _longitude = TextEditingController();

  @override
void initState() {
  super.initState();

  listingsRef = FirebaseFirestore.instance
      .collection('cities')
      .doc(widget.cityId)
      .collection(widget.collectionName);

  final d = widget.existingData ?? {};

  _name.text = d['name'] ?? '';
  _description.text = d['description'] ?? '';
  _address.text = d['address'] ?? '';
  _website.text = d['website'] ?? '';
  _imageUrl.text = d['imageUrl'] ?? '';
  _additionalImages.text =
      (d['additionalImages'] as List<dynamic>?)?.join(', ') ?? '';
  _priceLevel.text = d['priceLevel']?.toString() ?? '0';
  _rating.text = d['rating']?.toString() ?? '0';

  final location = d['location'];

if (location != null) {
  if (location is GeoPoint) {
    _latitude.text = location.latitude.toString();
    _longitude.text = location.longitude.toString();
  } else if (location is Map<String, dynamic>) {
    _latitude.text = location['latitude']?.toString() ?? '';
    _longitude.text = location['longitude']?.toString() ?? '';
  }
}
}

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _address.dispose();
    _website.dispose();
    _imageUrl.dispose();
    _additionalImages.dispose();
    _priceLevel.dispose();
    _rating.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

  //   final data = {
  //     'name': _name.text.trim(),
  //     'description': _description.text.trim(),
  //     'address': _address.text.trim(),
  //     'website': _website.text.trim(),
  //     'imageUrl': _imageUrl.text.trim(),
  //     'additionalImages': _additionalImages.text
  //         .split(',')
  //         .map((e) => e.trim())
  //         .where((e) => e.isNotEmpty)
  //         .toList(),
  //     'priceLevel': int.tryParse(_priceLevel.text.trim()) ?? 0,
  //     'rating': double.tryParse(_rating.text.trim()) ?? 0.0,
  //     'location': GeoPoint(
  //       double.tryParse(_latitude.text.trim()) ?? 0,
  //       double.tryParse(_longitude.text.trim()) ?? 0,
  // ),

  //     'updatedAt': FieldValue.serverTimestamp(),
  //   };

  final lat = double.tryParse(_latitude.text.trim());
final lng = double.tryParse(_longitude.text.trim());

if (lat == null || lng == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid latitude or longitude')),
  );
  return;
}

final data = {
  'name': _name.text.trim(),
  'description': _description.text.trim(),
  'address': _address.text.trim(),
  'website': _website.text.trim(),
  'imageUrl': _imageUrl.text.trim(),
  'additionalImages': _additionalImages.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(),
  'priceLevel': int.tryParse(_priceLevel.text.trim()) ?? 0,
  'rating': double.tryParse(_rating.text.trim()) ?? 0.0,
  'location': GeoPoint(lat, lng),
  'updatedAt': FieldValue.serverTimestamp(),
};

    try {
      if (widget.listingId != null) {
        // UPDATE
        await listingsRef.doc(widget.listingId).update(data);
      } else {
        // CREATE
        data['createdAt'] = FieldValue.serverTimestamp();
        final doc = await listingsRef.add(data);

        // Log Activity
        Helper.logActivity(
          type: 'listing',
          title: 'New ${widget.collectionName} added',
          body: '${_name.text.trim()} was created',
          refId: doc.id,
        );

        await _sendNotification(doc.id);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendNotification(String listingId) async {
    switch (widget.collectionName) {
      case 'attractions':
        await NotificationService.newAttraction(
          cityId: widget.cityId,
          name: _name.text.trim(),
          description: _description.text.trim(),
          listingId: listingId,
          imageUrl: _imageUrl.text.trim(),
        );
        break;

      case 'hotels':
        await NotificationService.newHotel(
          cityId: widget.cityId,
          name: _name.text.trim(),
          description: _description.text.trim(),
          listingId: listingId,
          imageUrl: _imageUrl.text.trim(),
        );
        break;

      case 'dining':
        await NotificationService.newDining(
          cityId: widget.cityId,
          name: _name.text.trim(),
          description: _description.text.trim(),
          listingId: listingId,
          imageUrl: _imageUrl.text.trim(),
        );
        break;

      case 'events':
        await NotificationService.newEvent(
          cityId: widget.cityId,
          name: _name.text.trim(),
          description: _description.text.trim(),
          listingId: listingId,
          imageUrl: _imageUrl.text.trim(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.listingId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Listing' : 'Add Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_name, 'Name'),
              _field(_description, 'Description', maxLines: 3),
              _field(_address, 'Address'),
              _field(_website, 'Website'),
              _field(_imageUrl, 'Main Image URL'),
              _field(_additionalImages,
                  'Additional Image URLs (comma separated)'),
              _field(_priceLevel, 'Price Level',
                  inputType: TextInputType.number),
              _field(_rating, 'Rating',
                  inputType: TextInputType.number),
              
              _field(
                  _latitude,
                  'Latitude',
                  inputType: TextInputType.number,
                ),

              _field(
                _longitude,
                'Longitude',
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1565C0),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: _save,
  child: Text(
    isEdit ? 'Update Listing' : 'Create Listing',
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        validator: (v) =>
            v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
  labelText: label,
  filled: true,
  fillColor: const Color(0xFFF5F9FF), // very light blue background

  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(
      color: Color(0xFFBBDEFB), // light blue border
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(
      color: Color(0xFF1565C0), // strong blue when focused
      width: 2,
    ),
  ),

  labelStyle: const TextStyle(
    color: Color(0xFF1565C0),
  ),
),
      ),
    );
  }
}