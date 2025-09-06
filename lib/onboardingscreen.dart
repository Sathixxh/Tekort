
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tekort/Presentation/auth/login.dart';
import 'package:tekort/core/core/utils/styles.dart';
import 'package:tekort/main.dart';

class ImagesPath {
  static String kOnboarding1 = 'assets/images/onboarding1.png';
  static String kOnboarding2 = 'assets/images/onBoarding2.png';
  static String kOnboarding3 = 'assets/images/onBoarding3.png';
}



 class DoorHubOnboardingScreen extends StatefulWidget {
  const DoorHubOnboardingScreen({Key? key}) : super(key: key);

  @override
  DoorHubOnboardingScreenState createState() => DoorHubOnboardingScreenState();
}

class DoorHubOnboardingScreenState extends State<DoorHubOnboardingScreen> {
  int _currentPageIndex = 0;
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundcolor,
      appBar: AppBar(
        backgroundColor: backgroundcolor,
        actions: [
          SkipButton(
            onTap: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: PageView.builder(
  itemCount: onboardingList.length,
  controller: _pageController,
  // Enable swipe by changing this line:
  physics: const BouncingScrollPhysics(), // or: ClampingScrollPhysics() for Android feel
  onPageChanged: (index) {
    setState(() {
      _currentPageIndex = index;
    });
  },
  itemBuilder: (context, index) {
    return OnboardingCard(
      playAnimation: index == _currentPageIndex, // 🔄 Ensure animation triggers only on visible card
      onboarding: onboardingList[index],
    );
  },
),
),
        SmoothPageIndicator(
  controller: _pageController,
  count: onboardingList.length,
  effect: WormEffect(
    dotHeight: 8,
    dotWidth: 8,
    dotColor: primaryColor.withOpacity(0.2), 
    activeDotColor:primaryColor,
  ),
  onDotClicked: (index) {
    setState(() {
      _currentPageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  },
),

          const SizedBox(height: 30),
          (_currentPageIndex < onboardingList.length - 1)
              ? NextButton(onTap: () {
               
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                })
              : PrimaryButton(
                  onTap: () {



                  },
                  width: 166,
                  text: 'Get Started',
                ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}


class PrimaryButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? fontSize;
  final Color? color;
  final bool isBorder;
  const PrimaryButton({
    required this.onTap,
    required this.text,
    this.height,
    this.width,
    this.borderRadius,
    this.isBorder = false,
    this.fontSize,
    this.color,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(),));

      },
      child: Container(
        height: height ?? 50,
        alignment: Alignment.center,
        width: width ?? double.maxFinite,
        decoration: BoxDecoration(
            color: color ?? primaryColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            border: isBorder ? Border.all(color: blackColor) : null),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
        
            fontSize: fontSize ?? 15,
          ),
        ),
      ),
    );
  }
}

class OnboardingAnimations {
  static AnimationController createSlideController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    );
  }

  static AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    );
  }

  static AnimationController createFadeController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );
  }

  static Animation<Offset> openSpotsSlideAnimation(
      AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.0, -0.8),
      end: const Offset(0.0, -0.05),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const ElasticOutCurve(1.2),
    ));
  }

  static Animation<Offset> digitalPermitsSlideAnimation(
      AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.07),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const ElasticOutCurve(1.2),
    ));
  }

  static Animation<Offset> rewardsSlideAnimation(
      AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.0, -0.8),
      end: const Offset(0.0, -0.05),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const ElasticOutCurve(1.2),
    ));
  }

  static Animation<double> fadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ));
  }
}

class OnboardingCard extends StatefulWidget {
  final bool playAnimation;
  final Onboarding onboarding;

  const OnboardingCard({
    required this.playAnimation,
    super.key,
    required this.onboarding,
  });

  @override
  State<OnboardingCard> createState() => _OnboardingCardState();
}

class _OnboardingCardState extends State<OnboardingCard>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideAnimationController =
        OnboardingAnimations.createSlideController(this);
    _slideAnimation = OnboardingAnimations.openSpotsSlideAnimation(
      _slideAnimationController,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.playAnimation) {
      _slideAnimationController.forward();
    } else {
      _slideAnimationController.animateTo(1,
          duration: const Duration(milliseconds: 0));
    }
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, vertical: screenHeight * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),
            Image.asset(
              widget.onboarding.image,
              height: screenHeight * 0.50,
              fit: BoxFit.contain,
            ),
            // SizedBox(height: screenHeight * 0.04),
            Text(
              widget.onboarding.title,
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            // SizedBox(height: screenHeight * 0.02),
            Text(
              widget.onboarding.description,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            // SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
}


class NextButton extends StatelessWidget {
  final VoidCallback onTap;
  const NextButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration:
            const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        child: const Icon(Icons.navigate_next, size: 30, color: Colors.white),
      ),
    );
  }
}

class SkipButton extends StatelessWidget {
  final VoidCallback onTap;
  const SkipButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: secpriColor,
        ),
        child: const Text(
          'Skip',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
        ),
      ),
    );
  }
}

class Onboarding {
  String image;
  String title;
  String description;

  Onboarding(
      {required this.description, required this.image, required this.title});
}

List<Onboarding> onboardingList = [
  Onboarding(
    title: 'Learn Anytime, Anywhere',
    description: 'Access high-quality courses from your phone or desktop, 24/7.',
    image: ImagesPath.kOnboarding1, // You can keep or change the image path
  ),
  Onboarding(
    title: 'Top Instructors & Experts',
    description: 'Learn from industry professionals with hands-on experience.',
    image: ImagesPath.kOnboarding2,
  ),
  Onboarding(
    title: 'Wide Range of Courses',
    description: 'Choose from programming, design, marketing, and more.',
    image: ImagesPath.kOnboarding3,
  ),
];















