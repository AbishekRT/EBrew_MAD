import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final faqList = [
      {
        'q': 'How should I store my coffee to keep it fresh?',
        'a':
            'To maintain freshness, store your coffee in an airtight container in a cool, dry place away from sunlight, moisture, and strong odors. Avoid refrigerating or freezing as it can affect the flavor.',
      },
      {
        'q': 'Is your coffee ground or whole bean?',
        'a':
            'We offer both ground and whole bean options. You can select your preferred type before adding the product to your cart.',
      },
      {
        'q': 'How long does your coffee stay fresh?',
        'a':
            'Our coffee is best consumed within 2 to 3 weeks of opening. Unopened, it can remain fresh for up to 6 months if stored properly.',
      },
      {
        'q': 'What brewing method works best?',
        'a':
            'Our coffee is suitable for most brewing methods including drip, French press, espresso, and pour-over. For best results, choose the grind that matches your method.',
      },
      {
        'q': 'Are your coffee beans organic or fair trade?',
        'a':
            'Yes! We source our beans from ethical and sustainable farms. Many of our products are certified organic and fair trade. Check the product description for details.',
      },
      {
        'q': 'How long does shipping take?',
        'a':
            'Orders are usually processed within 1-2 business days. Delivery typically takes 3–7 business days depending on your location.',
      },
      {
        'q': 'Do you offer subscriptions?',
        'a':
            'Yes, we offer flexible subscription plans where you can receive your favorite coffee delivered monthly. You can pause or cancel at any time.',
      },
      {
        'q': 'Is your packaging eco-friendly?',
        'a':
            'We are committed to sustainability. Our coffee bags are made from recyclable materials and we are working on 100% compostable packaging in the near future.',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isLandscape || constraints.maxWidth > 600) {
            return Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: faqList.length,
                    itemBuilder: (context, index) {
                      final faq = faqList[index];
                      return _buildCard(
                        context,
                        faq['q']!,
                        faq['a']!,
                        isDarkMode,
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: faqList.length,
              itemBuilder: (context, index) {
                final faq = faqList[index];
                return _buildCard(context, faq['q']!, faq['a']!, isDarkMode);
              },
            );
          }
        },
      ),
      bottomNavigationBar: const BottomNav(
        currentIndex: 3,
      ), // Set index as per tab
    );
  }

  Widget _buildCard(
    BuildContext context,
    String question,
    String answer,
    bool isDarkMode,
  ) {
    return Card(
      color: isDarkMode ? const Color(0xFF3E2723) : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "❓",
                  style: TextStyle(fontSize: 24, color: Colors.amber),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(answer, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
