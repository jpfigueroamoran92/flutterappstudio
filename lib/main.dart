import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/registration_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/dashboard/screens/tour_detail_screen.dart'; // Import TourDetailScreen
import 'package:myapp/models/tour.dart'; // Import Tour model for route arguments
import 'package:myapp/shared/app_colors.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        return AuthProvider();
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: 'J&J DS - Portal de Clientes',
          theme: ThemeData(
            primaryColor: AppColors.primaryColor,
            scaffoldBackgroundColor: AppColors.lightGreyBackground,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppColors.primaryColor,
              secondary: AppColors.secondaryColor,
              error: AppColors.errorRed,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondaryColor,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2.0,
                ),
              ),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home:
              authProvider.isAuthenticated
                  ? DashboardScreen()
                  : const LoginScreen(),
          onGenerateRoute: (settings) {
            // Use onGenerateRoute for routes that need arguments
            if (settings.name == TourDetailScreen.routeName) {
              final tour = settings.arguments as Tour; // Extract Tour argument
              return MaterialPageRoute(
                builder: (context) {
                  return TourDetailScreen(tour: tour);
                },
              );
            }
            // Handle other routes if necessary, or return null for default handling by 'routes' map
            return null;
          },
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegistrationScreen(),
            '/dashboard': (context) => DashboardScreen(),
            // TourDetailScreen is handled by onGenerateRoute because it takes arguments
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
