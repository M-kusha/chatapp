import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final String message;
  const LoginPage({Key? key, required this.message}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  String _errorMessage = '';
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;
    setState(() {
      _rememberMe = rememberMe;
      if (rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  _saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', value);
    if (value) {
      prefs.setString('email', _emailController.text.trim());
      prefs.setString('password', _passwordController.text.trim());
    } else {
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        size: 35, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(
                      'Chat Rooms',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                        fontFamily: 'CustomFont', // Use your custom font
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                _buildLoginContainer(),
                const SizedBox(height: 20),
                _buildSocialLoginButtons(),
                const SizedBox(height: 20),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Login', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  const Text('Remember me').tr(),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text("Forgot Password?").tr(),
                ),
              ),
            ],
          ),
          _buildErrorMessage(),
          const SizedBox(height: 20),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: tr("email_label"),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: tr("password_label"),
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            // Update the state i.e. toogle the state of passwordVisible variable
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container();
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _handleLogin,
      child: const Text('Authenticate').tr(),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 20),
        const Text('Or use').tr(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.g_mobiledata),
              onPressed: () {
                // Handle Google login
              },
            ),
            const Text('Google').tr(),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.facebook),
              onPressed: () {
                // Handle Facebook login
              },
            ),
            const Text('Facebook').tr(),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?").tr(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/register'),
          child: const Text('Create now').tr(),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _saveRememberMe(_rememberMe);
      _handleLoginSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An unknown error occurred';
      });
    }
  }

  void _handleLoginSuccess() {
    Navigator.pushNamed(context, '/chatrooms');
  }
}
