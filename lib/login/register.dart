import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _birthdateController = TextEditingController();

  File? _profileImage;
  String _selectedGender = '';
  DateTime _selectedDate = DateTime.now();
  CountryCode _selectedCountry = CountryCode.fromCountryCode('US');

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _registerUser() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User user = userCredential.user!;
      final String uid = user.uid;

      // Store additional user details in Firestore
      final userDocument =
          FirebaseFirestore.instance.collection('users').doc(uid);

      await userDocument.set({
        'username': _usernameController.text,
        'phoneNumber': _phoneNumberController.text,
        'birthdate': _birthdateController.text,
        'gender': _selectedGender,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });

      if (_profileImage != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('profile_images').child(uid);
        final uploadTask = storageRef.putFile(_profileImage!);
        final snapshot = await uploadTask.whenComplete(() => null);
        final imageUrl = await snapshot.ref.getDownloadURL();

        await userDocument.update({'profileImage': imageUrl});
      }
      _handleSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
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

  void _handleSuccess() {
    Navigator.of(context).pop(); // Change this to your success screen
  }

  String _formatPhoneNumber(String number) {
    // Remove all non-digit characters from the entered value
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
        title: const Text('Register'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.add_a_photo,
                            size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                    ),
                  ),
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
                ElevatedButton(
                  onPressed: _registerUser,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _birthdateController.dispose();

    super.dispose();
  }
}
