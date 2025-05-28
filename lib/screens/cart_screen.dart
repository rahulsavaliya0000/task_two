import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';

const Color _primary = Color(0xFFFF6B00);
const Color _secondary = Color(0xFFFF8A3D);
const Color _accent = Color(0xFFFFD280);
const Color _bg = Color(0xFFF9F9F9);
const Color _text = Color(0xFF333333);
const Color _subText = Color(0xFF666666);

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _couponController;
  late AnimationController _animController;
  late Animation<double> _titleScale;
  bool _hasDiscount = false;

  @override
  void initState() {
    super.initState();
    _couponController = TextEditingController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _couponController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _applyCoupon(CartProvider cart) {
    final code = _couponController.text.trim();
    if (code.isNotEmpty && !_hasDiscount) {
      setState(() => _hasDiscount = true);
      cart.applyDiscount(0.10);
      _couponController.clear();
      _showMessage('10% discount applied successfully!');
    } else if (code.isNotEmpty && _hasDiscount) {
      _showMessage('Only one discount can be applied per order');
    } else {
      _showMessage('Please enter a valid discount code');
    }
  }

  void _removeDiscount(CartProvider cart) {
    setState(() => _hasDiscount = false);
    cart.removeDiscount();
    _showMessage('Discount removed');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final cart = Provider.of<CartProvider>(ctx);
    final before = cart.totalAmountBeforeDiscount;
    final discount = cart.discountAmount;
    final total = cart.totalAmount;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        leading: BackButton(color: Colors.black87),
        title: ScaleTransition(
          scale: _titleScale,
          child: const Text(
            'My Cart',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: _subText,
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: _buildCartItems(cart),
                ),
                _buildSummarySection(before, discount, total, cart),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: _subText,
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty!',
            style: TextStyle(fontSize: 20, color: _subText),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: cart.items.length,
        itemBuilder: (ctx, i) {
          final entry = cart.items.entries.toList()[i];
          final id = entry.key;
          final item = entry.value as CartItem;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.product.image,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${item.product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: _primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    _buildQuantityControls(id, item.quantity, cart),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantityControls(String id, int quantity, CartProvider cart) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQuantityButton(
          icon: Icons.remove_circle_outline,
          color: Colors.redAccent,
          onPressed: () => cart.decrementQuantity(id),
          size: 24,
        ),
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _primary, width: 1),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Text(
            '$quantity',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: _text),
          ),
        ),
        const SizedBox(width: 8),
        _buildQuantityButton(
          icon: Icons.add_circle_outline,
          color: _primary,
          onPressed: () => cart.incrementQuantity(id),
          size: 24,
        ),
      ],
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onPressed,
      required double size}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        hoverColor: color.withOpacity(0.1),
        focusColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.2),
        splashColor: color.withOpacity(0.3),
        onTap: onPressed,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: size - 8),
        ),
      ),
    );
  }

  Widget _buildSummarySection(
      double subtotal, double discount, double total, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildCouponSection(cart),
              const SizedBox(height: 16),
              _buildPriceSummary(subtotal, discount, total),
              const SizedBox(height: 20),
              _buildCheckoutButton(cart),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponSection(CartProvider cart) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _couponController,
            decoration: InputDecoration(
              hintText: 'Enter Discount Code',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.local_offer, color: _subText),
            ),
            style: TextStyle(color: _text),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => _applyCoupon(cart),
          child: const Text('APPLY'),
        ),
        if (_hasDiscount)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _removeDiscount(cart),
          ),
      ],
    );
  }

  Widget _buildPriceSummary(double subtotal, double discount, double total) {
    return Column(
      children: [
        _buildPriceRow('Subtotal', subtotal),
        const SizedBox(height: 12),
        if (discount > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Discount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.green,
                ),
              ),
              Text(
                '- \$${discount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        _buildPriceRow('Total', total, isTotal: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : _text,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? _primary : _text,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(CartProvider cart) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        onPressed: cart.totalAmount > 0
            ? () {
                _showMessage('Proceeding to checkout...');
              }
            : null,
        child: const Text(
          'Proceed to Checkout',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
