import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:country_code_picker/country_code_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  File? _profileImage;
  DateTime _selectedDate = DateTime.now();
  bool _showTermsWarning = false;
  bool _acceptTerms = false;
  bool _showFieldsWarning = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _registerUser() async {
    if (_areFieldsEmpty()) {
      setState(() {
        _showFieldsWarning = true;
      });
      return;
    }
    setState(() {
      _showFieldsWarning = false;
    });
    if (!_acceptTerms) {
      setState(() {
        _showTermsWarning = true;
      });
      return;
    }
    setState(() {
      _showTermsWarning = false;
    });

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
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
        'kickExpiration': null,
        'banExpiration': null,
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
    } else {}
  }

  bool _areFieldsEmpty() {
    List<TextEditingController> controllers = [
      _emailController,
      _passwordController,
      _confirmPasswordController,
      _usernameController,
      _phoneNumberController,
      _birthdateController,
    ];

    return controllers.any((controller) => controller.text.isEmpty);
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
    Navigator.of(context)
        .pop(); // Change this to navigate to your success screen
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

  Widget _profileImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        backgroundImage:
            _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _formFieldSection() {
    return Column(
      children: [
        _buildTextField(
            _emailController, 'email'.tr(), false, TextInputType.emailAddress),
        _buildTextField(
            _usernameController, 'username'.tr(), false, TextInputType.text),
        _buildTextField(_passwordController, 'password'.tr(), true,
            TextInputType.visiblePassword),
        _buildTextField(_confirmPasswordController, 'confirm_password'.tr(),
            true, TextInputType.visiblePassword),
        _buildPhoneField(),
        _buildDateField('birthdate'.tr(), _birthdateController),
        _pleaseFillAllTheFields(),
      ],
    );
  }

  Widget _registerButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: Colors.blue,
      ),
      onPressed: _registerUser,
      child: Text(
        'register'.tr(),
      ),
    );
  }

  Widget _alreadyHaveAnAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('already_have_account'.tr()),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'login_title'.tr(),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptTerms() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value!;
              _showTermsWarning = false;
            });
          },
        ),
        Text('i_agree_to_the'.tr()),
        TextButton(
          onPressed: () {
            // Navigate to terms and conditions page
          },
          child: Text(
            'terms_and_conditions'.tr(),
            style: TextStyle(
              color: _showTermsWarning ? Colors.red : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pleaseFillAllTheFields() {
    return Visibility(
      visible: _showFieldsWarning,
      child: const Text(
        'Please fill all the fields',
        style: TextStyle(color: Colors.red, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      bool isObscure, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: _phoneNumberController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: '${'phone_number'.tr()} *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CountryCodePicker(
              initialSelection: 'US',
              showFlag: false,
              padding: const EdgeInsets.all(8),
              onChanged: (CountryCode countryCode) {
                // save countryCode to a variable
              },
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: _selectBirthdate,
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                _profileImageSection(),
                const SizedBox(height: 20),
                _formFieldSection(),
                const SizedBox(height: 20),
                _registerButton(),
                const SizedBox(height: 10),
                Center(child: _buildAcceptTerms()),
                _alreadyHaveAnAccount(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
