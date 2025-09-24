import 'package:flutter/material.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  State<ProductDetail> createState() => _ProductDetail();
}

class _ProductDetail extends State<ProductDetail> {
  int quantity = 1;

  final Map<String, String> product = {
    'name': 'Colombian Dark Roast',
    'price': '1500',
    'image': 'assets/2.png',
    'description': 'A rich, bold coffee with hints of chocolate.',
    'tastingNotes': 'Chocolate, Nutty, Smooth finish.',
    'shipping': 'Free delivery within 3 days. Easy returns.',
    'roastDate': '2025-06-01',
  };

  void _changeQuantity(int delta) {
    setState(() {
      quantity = (quantity + delta).clamp(1, 99);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isWideScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildImage()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildDetails()),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(),
                    const SizedBox(height: 16),
                    _buildDetails(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildImage() {
    return Center(
      child: Image.asset(
        product['image']!,
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['name']!,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Rs. ${product['price']}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[600],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          product['description']!,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _buildInfo("Tasting Notes", product['tastingNotes']!),
        _buildInfo("Shipping & Returns", product['shipping']!),
        _buildInfo("Roast Date", product['roastDate']!),
        const SizedBox(height: 24),
        _buildQuantityAndButton(),
      ],
    );
  }

  Widget _buildInfo(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuantityAndButton() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _changeQuantity(-1),
              ),
              Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _changeQuantity(1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Just clickable. No visible change or SnackBar.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Buy Now'),
          ),
        ),
      ],
    );
  }
}
