import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/providers/auth_provider.dart';
import 'package:myapp/features/auth/screens/login_screen.dart';
import 'package:myapp/shared/app_colors.dart';
// Import other necessary models and services, e.g., for users, all tours, etc.
// For example, if you have a Tour model:
// import 'package:myapp/models/tour.dart';
// import 'package:myapp/core/services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // late Future<List<dynamic>> _adminDataFuture; // Example: replace with actual data type
  // final ApiService _apiService = ApiService(); // If you need API calls

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated || authProvider.user?.role != 'admin') {
      // If not authenticated as admin, redirect to login or show an error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acceso denegado. Se requieren privilegios de administrador.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      });
      // Initialize with an error or empty future to prevent build errors
      // _adminDataFuture = Future.error(Exception('Acceso no autorizado.'));
    } else {
      // User is admin, proceed to fetch admin-specific data
      // _adminDataFuture = _fetchAdminData(authProvider.user!.token);
      // For now, let's use a placeholder future
      // Replace this with actual data fetching for users, all tours, stats etc.
      // For example: _adminDataFuture = _fetchAllUsers(authProvider.user!.token);
    }
  }

  // Example function to fetch admin data (e.g., all users, all tours)
  // Future<List<dynamic>> _fetchAdminData(String token) async {
  //   if (token.isEmpty) {
  //     throw Exception("Token de autenticación inválido.");
  //   }
  //   try {
  //     // Replace with actual API call for admin data
  //     // For example: return await _apiService.getAllUsers(token);
  //     // Or: return await _apiService.getAllTours(token);
  //     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  //     return []; // Return empty list for now
  //   } catch (e) {
  //     throw Exception('Error al cargar datos de administrador: ${e.toString()}');
  //   }
  // }

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Basic check, though initState handles redirection, this prevents flicker.
    if (!authProvider.isAuthenticated || authProvider.user?.role != 'admin') {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Verificando acceso..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, Administrador ${authProvider.user?.name ?? ''}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              'Aquí podrás gestionar usuarios, tours, y otras configuraciones del sistema.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            // TODO: Add sections for managing users, tours, etc.
            // Example:
            // Expanded(
            //   child: FutureBuilder<List<dynamic>>(
            //     future: _adminDataFuture,
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Center(child: CircularProgressIndicator());
            //       } else if (snapshot.hasError) {
            //         return Center(
            //           child: Text(
            //             'Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
            //             style: const TextStyle(color: AppColors.errorRed),
            //             textAlign: TextAlign.center,
            //           ),
            //         );
            //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //         return const Center(
            //           child: Text(
            //             'No hay datos para mostrar.',
            //             style: TextStyle(fontSize: 16),
            //           ),
            //         );
            //       } else {
            //         // Build your list of admin items here
            //         // return ListView.builder(
            //         //   itemCount: snapshot.data!.length,
            //         //   itemBuilder: (context, index) {
            //         //     // Replace with your data model and widget
            //         //     final item = snapshot.data![index];
            //         //     return ListTile(title: Text(item.toString())); // Placeholder
            //         //   },
            //         // );
            //         return const Center(child: Text("Contenido del dashboard de admin irá aquí."));
            //       }
            //     },
            //   ),
            // ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.admin_panel_settings, size: 100, color: AppColors.secondaryColor),
                    const SizedBox(height: 20),
                    const Text(
                      'El contenido del dashboard de administrador irá aquí.',
                       style: TextStyle(fontSize: 16),
                       textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                     ElevatedButton.icon(
                        icon: const Icon(Icons.people_alt_outlined),
                        label: const Text("Gestionar Usuarios (Próximamente)"),
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Función de gestión de usuarios aún no implementada.')),
                          );
                        },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                        icon: const Icon(Icons.tour_outlined),
                        label: const Text("Gestionar Tours (Próximamente)"),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Función de gestión de tours aún no implementada.')),
                          );
                        },
                    ),
                  ],
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
