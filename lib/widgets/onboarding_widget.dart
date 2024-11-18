import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  int _currentIndex = 0;

  List<Map> onboardingItems = [
    {
      "image": "assets/images/onboarding1.svg",
      "description": "Don’t worry about annoying ads, we got you covered",
    },
    {
      "image": "assets/images/onboarding2.svg",
      "description": "Sharing is caring, but not when it comes to personal info. Protect your privacy.",
    },
    {
      "image": "assets/images/onboarding3.svg",
      "description": "Don’t worry about annoying ads, we got you covered",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final CarouselOptions options = CarouselOptions(
      height: MediaQuery.of(context).size.height * 0.65,
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 5),
      autoPlayAnimationDuration: const Duration(milliseconds: 1200),
      autoPlayCurve: Curves.fastOutSlowIn,
      pauseAutoPlayOnTouch: true,
      enableInfiniteScroll: false,
      viewportFraction: 1,
      onPageChanged: (index, reason) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselSlider(
          options: options,
          items: onboardingItems
              .map(
                (item) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      item["image"],
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.45,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          AutoSizeText(
                            "We’ve made it \nEasy for you.",
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item["description"],
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w200,
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
              .toList(),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedSmoothIndicator(
            activeIndex: _currentIndex,
            count: onboardingItems.length,
            effect: const ExpandingDotsEffect(
              expansionFactor: 6,
              activeDotColor: Colors.white,
              dotColor: Colors.grey,
              dotHeight: 8,
              dotWidth: 8,
              spacing: 8,
            ),
          ),
        )
      ],
    );
  }
}
