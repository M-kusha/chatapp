import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  CountryCode _selectedCountry = CountryCode.fromCountryCode('US');
  File? _profileImage;
  String _selectedGender = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();

    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _countryController.text = userData['country'] ?? '';
        _genderController.text = userData['gender'] ?? '';

        _phoneNumberController.text = userData['phoneNumber'] ?? '';
        _birthdateController.text = userData['birthdate'] ?? '';
        _selectedGender = userData['gender'] ?? ''; // Load gender
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectBirthdate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _birthdateController.text =
            DateFormat('d MMMM yyyy').format(pickedDate);
      });
    }
  }

  String _formatPhoneNumber(String number) {
    final cleanValue = number.replaceAll(RegExp(r'\D'), '');

    if (cleanValue.isEmpty) {
      return '';
    }

    final countryCode = _selectedCountry.dialCode;
    final areaCode = cleanValue.substring(0, 2);
    final phoneNumber = cleanValue.substring(2);

    final formattedPhoneNumber = '+$countryCode $areaCode $phoneNumber';

    return formattedPhoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (_user?.photoURL != null)
                        ? NetworkImage(_user!.photoURL!)
                        : null as ImageProvider<Object>?,
                child: _profileImage == null && _user?.photoURL == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text('Name: ${_user?.displayName ?? 'N/A'}'),
            Text('Email: ${_user?.email ?? 'N/A'}'),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmNewPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Center(
              child: DropdownButtonFormField<String>(
                value: _selectedGender.isNotEmpty ? _selectedGender : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
                items: ['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        key: Key(value),
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Gender',
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _selectBirthdate,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _birthdateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Birthdate',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(fontSize: 13),
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  _phoneNumberController.text =
                      _formatPhoneNumber(value.trim());
                });
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _phoneNumberController.text = '';
                    });
                  },
                  child: CountryCodePicker(
                    initialSelection: 'US',
                    hideMainText: true,
                    textStyle: const TextStyle(fontSize: 13),
                    showFlag: true,
                    showDropDownButton: false,
                    showOnlyCountryWhenClosed: true,
                    alignLeft: false,
                    showCountryOnly: true,
                    onChanged: (CountryCode countryCode) {
                      setState(() {
                        _selectedCountry = countryCode;
                        _phoneNumberController.text =
                            _formatPhoneNumber(_phoneNumberController.text);
                      });
                    },
                  ),
                ),
                hintText: 'Enter phone number',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user!.uid)
                    .update({
                  'gender': _genderController.text,
                  'phoneNumber': _phoneNumberController.text,
                  'birthdate': _birthdateController.text,
                });
                if (_profileImage != null) {
                  final storageRef = FirebaseStorage.instance
                      .ref()
                      .child('profileImage')
                      .child(_user!.uid);
                  final uploadTask = storageRef.putFile(_profileImage!);
                  final snapshot = await uploadTask.whenComplete(() => null);
                  final downloadUrl = await snapshot.ref.getDownloadURL();
                  await _user!.updatePhotoURL(downloadUrl);
                }
                if (_newPasswordController.text.isNotEmpty &&
                    _newPasswordController.text ==
                        _confirmNewPasswordController.text) {
                  await _user!.updatePassword(_newPasswordController.text);
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
