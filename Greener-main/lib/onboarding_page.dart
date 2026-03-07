import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greener/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: [
              buildPage(
                image: 'images/onboarding1.png',
                title: "Ever Wonder Where Your Trash Ends Up?",
                subtitle: "You toss it. It disappears.\nBut does it really go?",
              ),
              buildPage(
                image: 'images/onboarding2.png',
                title: "Track Your Waste",
                subtitle:
                    "See where your waste goes\nand how much you recycle.",
              ),
              buildPage(
                image: 'images/onboarding3.png',
                title: "Earn Rewards",
                subtitle: "Recycle and earn points\nthat you can redeem.",
              ),
              buildPage(
                image: 'images/onboarding4.png',
                title: "Join the Movement",
                subtitle: "Be part of a cleaner future.\nStart today!",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Row for Skip button only
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: Text(
                "Skip",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Image
        Center(child: Image.asset(image)),

        const SizedBox(height: 24),

        // Dots under image
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            bool isActive = index == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: isActive ? 22 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: isActive ? Color(0xFF6E8C39) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        // Title
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle
        Center(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Color(0xFF333333).withOpacity(0.7),
            ),
          ),
        ),

        const Spacer(),

        // Row for Back and Next buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button (text button)
            if (currentPage > 0)
              GestureDetector(
                onTap: () {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  "Back",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.normal, // regular
                    color: Color(0xFF333333),
                  ),
                ),
              )
            else
              const SizedBox(width: 24), // Placeholder when Back is hidden
            // Next / Get Started button
            GestureDetector(
              onTap: () {
                if (currentPage < 3) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              child: Text(
                currentPage == 3 ? "Get Started" : "Next",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6E8C39),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}
