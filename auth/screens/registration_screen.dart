import 'package:flutter/material.dart';
import 'package:myapp/core/services/api_service.dart'; // Import centralized ApiService
import 'package:myapp/shared/app_colors.dart'; 

class RegistrationScreen extends StatefulWidget {
  static const String routeName = '/register';

  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _message = '';
  bool _isLoading = false;

  // Use the centralized ApiService
  final ApiService _apiService = ApiService();

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        // Call the register method from the centralized ApiService
        final response = await _apiService.register(
          name: _nameController.text,
          company: _companyController.text.isEmpty ? null : _companyController.text,
          email: _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          password: _passwordController.text,
        );
        if (mounted) {
          setState(() {
            // Adapt message based on actual API response structure from your backend
            _message = response['message'] as String? ?? '¡Registro exitoso! Ahora puedes iniciar sesión.';
            // If successful, you might want to clear the form or navigate
            // _formKey.currentState?.reset();
            // Consider a slight delay before navigation or a confirmation dialog
            // Future.delayed(const Duration(seconds: 2), () {
            //   if (mounted) Navigator.pop(context); // Go back to login
            // });
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _message = e.toString().replaceFirst('Exception: ', '');
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
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo_jjds.png', 
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: const Icon(Icons.business_center, size: 70, color: AppColors.primaryColor),
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Contacto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Empresa (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su correo electrónico';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor ingrese un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una contraseña';
                    }
                    if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirme su contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _message.toLowerCase().contains('successful') || _message.toLowerCase().contains('exitoso') || _message.toLowerCase().contains('exitosa') // Adjusted for Spanish success
                            ? AppColors.successGreen
                            : AppColors.errorRed,
                        fontSize: 14,
                      ),
                    ),
                  ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: const TextStyle(fontSize: 18.0),
                        ),
                        child: const Text('Registrarme'), 
                      ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                        Navigator.pop(context); 
                    } else {
                        Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia Sesión',
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
