import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Enterprise POS & Inventory Engine',
      'subtitle': 'မိုဘိုင်း ပြုပြင်ရေးနှင့် အရောင်းစာရင်းများကို 100% တိကျစွာ Auto-Sync ပြုလုပ်ပေးနိုင်သော ခေတ်မီ စနစ်ကြီး',
      'icon': 'point_of_sale',
    },
    {
      'title': 'Hardware Smart Diagnostics System',
      'subtitle': 'Micro-soldering, Motherboard IC repair နှင့် circuit ဘုတ်များကို စနစ်တကျ စစ်ဆေးပေးသည့် Smart Engine',
      'icon': 'hardware',
    },
    {
      'title': '5TB Free Cloud & Enterprise Security',
      'subtitle': 'AES-256 Cloud Backup နှင့် Email-linked Disaster Recovery ကြောင့် စာရင်းများ လုံးဝ မပျောက်ပျက်နိုင်ပါ',
      'icon': 'shield',
    },
  ];

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'hardware':
        return Icons.hardware;
      case 'shield':
        return Icons.shield_outlined;
      default:
        return Icons.point_of_sale;
    }
  }

  void _onFinishOnboarding() {
    // Navigate back to Main Module Navigation Hub
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Welcome to OmniFix Enterprise POS!'),
          backgroundColor: Colors.indigo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onFinishOnboarding,
                child: Text(
                  'SKIP',
                  style: TextStyle(
                    color: Colors.indigo.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // PageView Area (Overflow Protection Included)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final item = _onboardingData[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(item['icon']!),
                            size: 100,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                        const SizedBox(height: 40),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item['title']!,style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicators & Next/Get Started Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot Indicators
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.indigo.shade800 : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Action Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _onFinishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _onboardingData.length - 1 ? 'GET STARTED' : 'NEXT',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}