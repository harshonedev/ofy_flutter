import 'package:flutter/material.dart';
import 'package:llm_cpp_chat_app/features/model_picker/presentation/pages/model_picker_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Welcome to OfflineAI',
      description:
          'Chat with powerful AI models directly on your device. No internet required for local models! Enjoy privacy and instant responses.',
      icon: Icons.chat_bubble_outline,
    ),
    _OnboardingSlide(
      title: 'How to Use',
      description:
          '1. Pick a local GGUF model or connect to a cloud model.\n2. Download new models if needed.\n3. Start chatting and see responses stream in real time!',
      icon: Icons.model_training,
    ),
    _OnboardingSlide(
      title: 'Settings & Tips',
      description:
          '• Configure model type and API keys in Settings.\n• All chats and preferences are saved locally.\n• Switch between light and dark mode anytime.',
      icon: Icons.settings,
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            slide.icon,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          slide.description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? colorScheme.primary
                                  : colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage == _slides.length - 1)
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_complete', true);
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const ModelPickerPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Get Started'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Next'),
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

class _OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}
