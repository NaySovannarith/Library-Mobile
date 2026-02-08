import 'package:flutter/material.dart';
import 'package:library_app/auth/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'auth/login_page.dart';
import 'module/staff_module/admin_home.dart';
import 'module/navbar/navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthService
  final authService = AuthService();
  await authService.initialize();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: authService)],
      child: MaterialApp(
        title: 'Library App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          platform: TargetPlatform.iOS,
        ),
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            // Show loading while checking auth
            if (authService.isLoading && authService.currentUser == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Navigate based on auth status
            if (authService.isAuthenticated) {
              final role = authService.currentUser?.role?.toUpperCase();
              if (role == 'ADMIN') {
                return const AdminHome();
              }
              return const CustomNavBar1();
            } else {
              return const LoginPage();
            }
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const CustomNavBar1(),
          '/admin': (context) => const AdminHome(),
        },
      ),
    );
  }
}
