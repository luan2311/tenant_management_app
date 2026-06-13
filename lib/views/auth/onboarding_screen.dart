import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/theme/styles.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'login_screen.dart';

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
      'title': 'Lumiere Stay',
      'subtitle': 'The Ethereal Sanctuary',
      'description': 'Hệ thống quản lý phòng thuê cao cấp, tinh tế và thông minh cho cả chủ nhà và khách thuê.',
    },
    {
      'title': 'Quản Lý Dễ Dàng',
      'subtitle': 'Mọi Thứ Trong Tầm Tay',
      'description': 'Theo dõi trạng thái phòng, hợp đồng, hóa đơn điện nước chỉ với vài lượt chạm đơn giản.',
    },
    {
      'title': 'Thanh Toán Tiện Lợi',
      'subtitle': 'Minh Bạch & Nhanh Chóng',
      'description': 'Nhận thông báo hóa đơn tự động mỗi tháng và xác nhận thanh toán trực quan.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Pre-initialize database in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().checkAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundStart,
              Color(0xFFE8E8FD),
              AppColors.backgroundEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // App logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: AppStyles.glassmorphic(opacity: 0.8, borderRadius: 16),
                    child: const Icon(
                      Icons.blur_on,
                      size: 36,
                      color: AppColors.sanctuaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Lumiere Stay',
                    style: AppStyles.headline(
                      context,
                      color: AppColors.sanctuaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
              // Onboarding cards carousel
              SizedBox(
                height: 380,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final item = _onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: GlassmorphicContainer(
                        padding: const EdgeInsets.all(30),
                        borderRadius: 28,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item['title']!,
                              textAlign: TextAlign.center,
                              style: AppStyles.headline(
                                context,
                                color: AppColors.sanctuaryDark,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['subtitle']!,
                              textAlign: TextAlign.center,
                              style: AppStyles.title(
                                context,
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white60, thickness: 1),
                            const SizedBox(height: 24),
                            Text(
                              item['description']!,
                              textAlign: TextAlign.center,
                              style: AppStyles.body(
                                context,
                                color: AppColors.textPrimary.withOpacity(0.8),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.sanctuaryDark
                          : AppColors.sanctuaryDark.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Navigation button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Skip onboarding
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Bỏ qua',
                        style: AppStyles.body(
                          context,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sanctuaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1 ? 'Bắt đầu' : 'Tiếp theo',
                        style: AppStyles.body(
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
