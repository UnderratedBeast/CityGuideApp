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

  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _imageUrl;

  @override
  void initState() {
    super.initState();

    listingsRef = FirebaseFirestore.instance
        .collection('cities')
        .doc(widget.cityId)
        .collection(widget.collectionName);

    final d = widget.existingData ?? {};

    _name = TextEditingController(text: d['name'] ?? '');
    _description = TextEditingController(text: d['description'] ?? '');
    _imageUrl = TextEditingController(text: d['imageUrl'] ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'imageUrl': _imageUrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.listingId != null) {
        await listingsRef.doc(widget.listingId).update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        final doc = await listingsRef.add(data);

        // 🔥 Log Activity
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_name, 'Name'),
              _field(_description, 'Description', maxLines: 3),
              _field(_imageUrl, 'Image URL'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Update' : 'Create'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: (v) =>
            v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}