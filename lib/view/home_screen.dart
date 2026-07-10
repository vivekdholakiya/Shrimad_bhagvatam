// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:shrimad_bhagavatam/halper/app_text.dart';
import 'package:shrimad_bhagavatam/theme/app_colors.dart';
import 'package:shrimad_bhagavatam/halper/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';

import '../halper/util.dart';
import '../util/bg_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(20),
                  vertical: context.responsiveSize(18)),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        app_names[selectedLanguage],
                        style: GoogleFonts.poppins(
                          fontSize: context.responsiveFontSize(24),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      Text(
                        "||सत्यं परम धीमहि||",
                        style: GoogleFonts.notoSerifDevanagari(
                          fontSize: context.responsiveFontSize(20),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      SpiritualDivider(
                        icon: Icons.spa,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: context.responsiveSize(10),
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ContinueReadingCard(
                          canto: 1,
                          chapter: 1,
                          verse: 1,
                          progress: 0.25,
                          onTap: () {
                            // Handle resume reading action
                          },
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            ),
          )),
    );
  }
}

class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({
    super.key,
    required this.canto,
    required this.chapter,
    required this.verse,
    required this.progress,
    required this.onTap,
  });

  final int canto;
  final int chapter;
  final int verse;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(.75),
        
        border: Border.all(
          color: AppColors.goldGlow.withOpacity(.75),
          width: 1,
        ),
        borderRadius: BorderRadiusGeometry.circular(context.responsiveSize(24)),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [


              ClipRRect(
                borderRadius:BorderRadiusGeometry.only(
                  topLeft: Radius.circular(context.responsiveSize(24)),
                  bottomLeft: Radius.circular(context.responsiveSize(24)),
                ),
                child: Stack(

                  children: [
                    Image.asset(
                      "assets/images/krishna.png",
                      width: context.responsiveSize(160),
                      height: context.responsiveSize(150),
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: Container( decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,

                            AppColors.background.withOpacity(.75),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),),
                    )
                  ],
                ),
              ),


              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Continue Reading",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
