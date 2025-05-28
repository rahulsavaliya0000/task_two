import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/app_routes.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedColor = 0;

  final List<Color> _colors = [
    Color(0xFF8B0000),
    Colors.black,
    Colors.blue,
    Colors.brown,
    Colors.grey,
  ];

  final List<String> _images = [];

  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _images.add(widget.product.image);

    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${widget.product.title}" added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.black54),
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Share tapped'))),
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black54),
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Favorite tapped'))),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _images.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => CachedNetworkImage(
                    imageUrl: _images[i],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholder: (_, __) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) => Center(
                        child: Icon(Icons.broken_image,
                            size: 80, color: Colors.grey)),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: _images.length,
                      effect: WormEffect(
                          dotColor: Colors.white54,
                          activeDotColor: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text('\$${p.price.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange)),
                        Spacer(),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text('${p.rating.rate} (${p.rating.count})',
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    SizedBox(height: 16),
                    Text('Color',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(_colors.length, (i) {
                        final c = _colors[i];
                        final sel = i == _selectedColor;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = i),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: 12),
                            padding: EdgeInsets.all(sel ? 3 : 0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: sel
                                  ? Border.all(
                                      color: Colors.deepOrange, width: 2)
                                  : null,
                            ),
                            child: CircleAvatar(
                              backgroundColor: c,
                              radius: 12,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.deepOrange,
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: Colors.deepOrange,
                      tabs: [
                        Tab(text: 'Description'),
                        Tab(text: 'Specifications'),
                        Tab(text: 'Reviews'),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(p.description),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Specifications go here'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('⭐⭐⭐⭐☆'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ElevatedButton(
          onPressed: _addToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Add to Cart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
