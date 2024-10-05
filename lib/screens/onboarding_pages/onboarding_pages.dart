// import 'onboarding_page1.dart';
// import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'onboarding_page2.dart';
// import 'onboarding_page3.dart';
//
// class OnboardingPages extends StatelessWidget {
//
//   final PageController _pageController = PageController(initialPage: 0);
//
//   final List<Widget> _pages = [
//     const OnboardingPage1(),
//     const OnboardingPage2(),
//     const OnboardingPage3()
//   ];
//
//   OnboardingPages({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           SizedBox(
//             child: PageView(
//               controller: _pageController,
//               children: _pages,
//             ),
//           ),
//           // SmoothPageIndicator(
//           //   controller: _pageController,
//           //   count: _pages.length,
//           //   effect: const ExpandingDotsEffect(
//           //     radius: 10.0,
//           //   ),
//           // )
//         ],
//       ),
//     );
//   }
// }
