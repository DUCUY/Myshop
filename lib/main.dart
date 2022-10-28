
import 'package:flutter/material.dart';
//import 'package:myshop/ui/products/product_detail_screen.dart';
//import 'package:myshop/ui/products/products_manager.dart';
//import 'ui/products/products_overview_screen.dart';
//import 'ui/products/user_products_screen.dart';
//import 'ui/cart/cart_screen.dart';
import 'ui/screens.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //(2)
        ChangeNotifierProvider(
          create: (context) => AuthManager(), 
        ),
        ChangeNotifierProxyProvider<AuthManager, ProductsManager>(
          create: (ctx) => ProductsManager(),
          update: (ctx, authMananger, productsManager) {
            // Khi authMananger có báo hiệu thay đổi  thì đọc lại authToken
            //  cho productsManager
            productsManager!.authToken = authMananger.authToken;
            return productsManager;
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrdersManager(),
        )
      ],
      child: Consumer<AuthManager>(
        builder: (ctx, authManager, child) {
      return MaterialApp (
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
        ).copyWith(
          secondary: Colors.deepOrange,
        ),
      ),
      home: authManager.isAuth 
        ? const ProductsOverviewScreen()
        : FutureBuilder (
          future: authManager.tryAutoLogin(),
          builder: (ctx, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
              ? const SplashScreen()
              : const AuthScreen();
          },
        ),
      routes: {
        CartScreen.routeName: (ctx) => const CartScreen(),
        OrdersScreen.routeName: (ctx) => const OrdersScreen(),
        UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ProductDetailScreen.routeName) {
          final productId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (ctx) {
              return ProductDetailScreen(
                ctx.read<ProductsManager>().findById(productId),
              );
            },
          );
        }
        if (settings.name == EditProductScreen.routeName) {
          final productId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (ctx) {
              return EditProductScreen(
                productId != null
                ? ctx.read<ProductsManager>().findById(productId)
                : null,
              );
            },
          );
        }
        return null;
        },
      );
        },
      ),
  

    );
  }
}

