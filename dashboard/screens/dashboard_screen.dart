import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/providers/auth_provider.dart';
import 'package:myapp/core/services/api_service.dart'; 
import 'package:myapp/models/tour.dart';
import 'package:myapp/features/auth/screens/login_screen.dart';
import 'package:myapp/features/dashboard/widgets/tour_card_widget.dart';
import 'package:myapp/shared/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key}); 

  @override 
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Tour>> _toursFuture;
  final ApiService _apiService = ApiService(); 

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated && authProvider.user?.token != null) {
      _toursFuture = _fetchTours(authProvider.user!.token); // Pass non-nullable token
    } else {
      // If not authenticated or token is null, redirect or show error message earlier.
      // For now, _toursFuture will result in an error displayed by FutureBuilder.
      _toursFuture = Future.error(Exception('Usuario no autenticado o token no disponible.'));
      // Alternative: Navigate away or show a placeholder immediately
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (mounted) Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      // });
    }
  }

  Future<List<Tour>> _fetchTours(String token) async {
    // If token is null or empty, it ideally shouldn't reach here due to initState check
    // but as a safeguard:
    if (token.isEmpty) {
      throw Exception("Token de autenticación inválido.");
    }
    try {
      // Call the ApiService to get tours
      return await _apiService.getTours(token);
    } catch (e) {
      // Rethrow or handle specific errors for the UI
      // For example, if API returns 401 (Unauthorized), you might want to log out the user.
      // For now, just rethrow to be caught by FutureBuilder.
      rethrow;
    }
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // This check might be redundant if initState handles unauthenticated state by redirecting
    // or if _toursFuture itself reflects an unauthenticated error state.
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { 
          Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recorridos Virtuales'),
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
              'Bienvenido/a, ${authProvider.user?.name ?? 'Cliente'}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Tour>>(
                future: _toursFuture, 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error al cargar recorridos: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                          style: const TextStyle(color: AppColors.errorRed),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tienes recorridos asignados aún.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    final tours = snapshot.data!;
                    return ListView.builder(
                      itemCount: tours.length,
                      itemBuilder: (context, index) {
                        return TourCardWidget(tour: tours[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
