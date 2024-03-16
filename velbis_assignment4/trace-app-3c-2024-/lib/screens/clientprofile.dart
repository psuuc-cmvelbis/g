import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileClientScreen extends StatefulWidget {
  final String userId;

  const ProfileClientScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileClientScreenState createState() => _ProfileClientScreenState();
}

class _ProfileClientScreenState extends State<ProfileClientScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  DateTime? setDate;

  @override
  void initState() {
    super.initState();
    fetchUserProfile(widget.userId).then((profile) {
      setState(() {
        _firstNameController.text = profile['firstname'] ?? '';
        _middleNameController.text = profile['middlename'] ?? '';
        _lastNameController.text = profile['lastname'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _birthDateController.text = profile['birthdate'] ?? '';
      });
    }).catchError((error) {
      print('Error fetching user profile: $error');
    });
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic>? data = snapshot.data();

      if (data != null) {
        // Print the data retrieved from Firestore
        print('User Profile Data: $data');
      } else {
        print('User Profile Data is null');
      }

      return data ?? {}; // Return an empty map if data is null
    } catch (error) {
      print('Error fetching user profile: $error');
      rethrow;
    }
  }

  Future<void> saveUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'firstname': _firstNameController.text,
        'middlename': _middleNameController.text,
        'lastname': _lastNameController.text,
        'address': _addressController.text,
        'birthdate': _birthDateController.text,
      });
      // Show success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (error) {
      print('Error updating user profile: $error');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  void _setDate(BuildContext context) async {
    final DateTime? selectDate = await showDatePicker(
      context: context,
      initialDate: setDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selectDate != null && selectDate != setDate) {
      setState(() {
        setDate = selectDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: _middleNameController,
              decoration: InputDecoration(labelText: 'Middle Name'),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextFormField(
              controller: _birthDateController,
              decoration: InputDecoration(labelText: 'Birth Date'),
            ),
            ElevatedButton(
              onPressed: () {
                saveUserProfile(widget.userId);
              },
              child: Text('Save'),
            ),
        
          ]
        ),
      ),
    );
  }
}
