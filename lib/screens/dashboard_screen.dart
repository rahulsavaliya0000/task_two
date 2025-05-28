
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:task_two/screens/cart_screen.dart';
import '../api/api_service.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/app_routes.dart';
import '../utils/constants.dart';


const Color _primary = Color(0xFFFF6B00); 
const Color _secondary = Color(0xFFFF8A3D); 
const Color _accent = Color(0xFFFF8A3D); 
const Color _bg = Color(0xFFF9F9F9); 
const Color _text = Color(0xFF333333); 
const Color _subText = Color(0xFF666666); 

class PromotionBanner {
  final String imageUrl;
  final String? targetRoute;
  PromotionBanner({required this.imageUrl, this.targetRoute});
}


final List<PromotionBanner> _samplePromotions = [
  PromotionBanner(imageUrl: 'https://th.bing.com/th/id/OIP.ivSDPbHpnyw8g9gLNkLHzwHaE8?w=306&h=204&c=8&rs=1&qlt=90&o=6&dpr=1.1&pid=3.1&rm=2'),
  PromotionBanner(imageUrl: 'https://th.bing.com/th/id/OIP.z2abAhWs2EA9TnSNioatewHaDt?w=350&h=175&c=8&rs=1&qlt=90&o=6&dpr=1.1&pid=3.1&rm=2'),
  PromotionBanner(imageUrl: 'https://th.bing.com/th/id/OIP.iILRuY-BJ0lHE3O_KIug0gHaDt?w=350&h=175&c=8&rs=1&qlt=90&o=6&dpr=1.1&pid=3.1&rm=2'),
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  final ApiService _apiService = ApiService();
  late Future<List<String>> _categoriesFuture;
  late Future<List<Product>> _productsFuture;

  
  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBanner = 0;

  
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _apiService.getCategories();
    _productsFuture = _apiService.getProducts().then((all) => all.take(8).toList());
    _bannerController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final next = (_currentBanner + 1) % _samplePromotions.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showError(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.redAccent),
    );
  }

  void _onNavTap(int idx) {
    setState(() => _selectedNav = idx);
    switch (idx) {
      case 0: break;
      case 1: Navigator.pushNamed(context, AppRoutes.productDetail); break;
      case 2: Navigator.pushNamed(context, AppRoutes.cart); break;
      case 3: Navigator.pushNamed(context, AppRoutes.productList); break;
    }
  }

Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            child: Icon(
              Icons.search,
              color: Colors.orange,
              size: 24,
            ),
          ),
          Positioned.fill(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  color: Colors.orange.withOpacity(0.7),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 52,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
              onSubmitted: (q) => _showError('Search “$q” not implemented'),
            ),
          ),
          Positioned(
            right: 16,
            child: SizedBox(
              width: 32,
              height: 32,
              child: RawMaterialButton(
                fillColor: Colors.orange,
                shape: const CircleBorder(),
                elevation: 4,
                onPressed: () => _showError('Search action triggered'),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBanners() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _samplePromotions.length,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _primary.withOpacity(0.9),
                        _secondary.withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: _samplePromotions[i].imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, size: 40)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          child: SmoothPageIndicator(
            controller: _bannerController,
            count: _samplePromotions.length,
            effect: WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              spacing: 8,
              activeDotColor: _accent,
              dotColor: _subText.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _text,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5)),
          const Spacer(),
          TextButton(
            onPressed: () => _showError('View all $title'),
            child: Text('View All',
                style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return FutureBuilder<List<String>>(
      future: _categoriesFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final cats = snap.data ?? [];
        if (cats.isEmpty) {
          return SizedBox(
            height: 80,
            child: Center(
                child: Text('No categories', style: TextStyle(color: _subText))),
          );
        }
        return SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: cats.length,
            itemBuilder: (ctx, i) {
              final name = cats[i];
              IconData icon;
              switch (name.toLowerCase()) {
                case "electronics":
                  icon = Icons.electrical_services;
                  break;
                case "jewelery":
                  icon = Icons.diamond_outlined;
                  break;
                case "men's clothing":
                  icon = Icons.man;
                  break;
                case "women's clothing":
                  icon = Icons.woman;
                  break;
                default:
                  icon = Icons.category;
              }
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.productList,
                    arguments: name),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white70,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 36,
                        color: _secondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _text,
                            fontFamily: 'Roboto'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSpecial() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final prods = snap.data ?? [];
        if (prods.isEmpty) {
          return SizedBox(
            height: 100,
            child: Center(
                child: Text('No products', style: TextStyle(color: _subText))),
          );
        }
        return SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: prods.length,
            itemBuilder: (ctx, i) {
              final p = prods[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.productDetail,
                    arguments: p),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white70,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: CachedNetworkImage(
                            imageUrl: p.image,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[200],
                            ),
                            errorWidget: (_, __, ___) => Icon(
                                Icons.broken_image,
                                size: 40,
                                color: _subText),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: _text,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Roboto')),
                            const SizedBox(height: 8),
                            Text('\$${p.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _accent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedNav,
      onTap: _onNavTap,
      selectedItemColor: _primary,
      unselectedItemColor: _subText,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            activeIcon: Icon(Icons.home_rounded, size: 30),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined, size: 28),
            activeIcon: Icon(Icons.category_rounded, size: 30),
            label: 'Categories'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, size: 28),
            activeIcon: Icon(Icons.shopping_cart_rounded, size: 30),
            label: 'Cart'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 28),
            activeIcon: Icon(Icons.person_rounded, size: 30),
            label: 'Profile'),
      ],
    );
  }

  Widget _buildScanButton() {
    return FloatingActionButton(
      backgroundColor: _primary,
      elevation: 10,
      child: const Icon(
        Icons.qr_code_scanner_rounded,
        size: 32,
      ),
      onPressed: () => _showError('Scanner coming soon'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Text(
          AppConstants.appName,
          style: TextStyle(
              color: _primary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              fontFamily: 'Roboto',
              letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.notifications_none, color: _text, size: 28),
              onPressed: () => _showError('No notifications')),
          Stack(children: [
            IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: _text, size: 28),
                onPressed: () => Navigator.pushNamed(
                    context, AppRoutes.cart)),
            if (cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: _primary, shape: BoxShape.circle),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text('$cartCount',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center),
                ),
              )
          ]),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: _buildSearchBar(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _categoriesFuture = _apiService.getCategories();
            _productsFuture =
                _apiService.getProducts().then((all) => all.take(8).toList());
          });
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildBanners(),
              _sectionHeader('Categories'),
              _buildCategories(),
              _sectionHeader('Special For You'),
              _buildSpecial(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildScanButton(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }
}