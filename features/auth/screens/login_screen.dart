import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/providers/auth_provider.dart'; 
import 'package:myapp/features/auth/screens/registration_screen.dart';
import 'package:myapp/shared/app_colors.dart'; 

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login'; 

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState(); 
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) { 
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(_emailController.text, _passwordController.text);
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } catch (e) {
        if (mounted) { 
          setState(() {
            _errorMessage = e.toString().replaceFirst('Exception: ', ''); 
          });
        }
      } finally {
        if (mounted) { 
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Restore Logo
                Image.asset(
                  'assets/images/logo_jjds.png', 
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if logo fails to load
                    return Container(
                      height: 120,
                      alignment: Alignment.center,
                      child: const Icon(Icons.business, size: 80, color: AppColors.primaryColor),
                    );
                  },
                ),
                const SizedBox(height: 48.0),
                Text(
                  'Acceso Clientes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 24.0),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu correo electrónico';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: AppColors.errorRed, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 12.0),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18, color: AppColors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.white)
                        )
                      : const Text('Iniciar Sesión', style: TextStyle(color: AppColors.white)),
                ),
                const SizedBox(height: 24.0),

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RegistrationScreen.routeName);
                  },
                  child: const Text(
                    '¿No tienes cuenta? Crea una',
                    style: TextStyle(color: AppColors.secondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
