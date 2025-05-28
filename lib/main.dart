import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_two/providers/cart_provider.dart';
import './screens/splash_screen.dart';
import './screens/login_screen.dart';
import './screens/dashboard_screen.dart';
import './screens/product_list_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './utils/app_routes.dart';
import './models/product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CartProvider(),
      child: MaterialApp(
        title: 'Flutter E-Commerce',
        theme: ThemeData(
            primarySwatch: Colors.teal,
            hintColor: Colors.amber,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            )),
            cardTheme: CardTheme(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            )),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (ctx) => const SplashScreen(),
          AppRoutes.login: (ctx) => const LoginScreen(),
          AppRoutes.dashboard: (ctx) => const DashboardScreen(),
          AppRoutes.cart: (ctx) => const CartScreen(),
        },
        onGenerateRoute: (settings) {
          
          if (settings.name == AppRoutes.productList) {
            final category = settings.arguments as String;
            return MaterialPageRoute(
              builder: (ctx) => ProductListScreen(category: category),
            );
          }
          if (settings.name == AppRoutes.productDetail) {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (ctx) => ProductDetailScreen(
                  product: product), 
            );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
