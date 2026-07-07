// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/core/network/api_exception.dart';
import 'package:phonoquest_signup_flow/features/journey/data/alphabet_lounge_repository.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../core/l10n/app_language_controller.dart';

const _chipColors = <Color>[
  Color(0xFFB6D3FF),
  Color(0xFFFDE68A),
  Color(0xFF86EFAC),
  Color(0xFFFAC515),
  Color(0xFFF9A8D4),
  Color(0xFFA7F3D0),
];

class alphabetLoungeHeroScreen extends StatefulWidget {
  const alphabetLoungeHeroScreen({super.key});

  @override
  State<alphabetLoungeHeroScreen> createState() => _AlphabetLoungeHeroScreenState();
}

class _AlphabetLoungeHeroScreenState extends State<alphabetLoungeHeroScreen> {
  final AlphabetLoungeRepository _repo = AlphabetLoungeRepository();
  List<String> _masteredLabels = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMasteredLetters();
  }

  Future<void> _loadMasteredLetters() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = await _repo.fetchMasteredLetters(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _masteredLabels = payload.labels;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  Widget _masteredLettersSection() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF667085)),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _loadMasteredLetters, child: Text(context.tr('Retry'))),
          ],
        ),
      );
    }
    if (_masteredLabels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          context.tr('Your mastered letters will appear here after you complete letter activities.'),
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 12.5,
            height: 1.35,
            color: const Color(0xFF667085),
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var i = 0; i < _masteredLabels.length; i++)
          _MasterChip(
            label: _masteredLabels[i],
            color: _chipColors[i % _chipColors.length],
          ),
      ],
    );
  }

  Widget _nextLessonButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: TextButton(
        onPressed: () => AppRouter.navigateToAlphabetLounge(context),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF47495),
          foregroundColor: const Color.fromRGBO(28, 28, 28, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('Next Lesson'),
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color.fromRGBO(28, 28, 28, 1),
              ),
            ),
            const SizedBox(width: 30),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Color.fromRGBO(28, 28, 28, 1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 52,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => AppRouter.navigateToDashboard(context),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Center(
                          child: Image.asset(
                            AppAssets.backimage,
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: 340,
                          maxHeight: constraints.maxHeight,
                        ),
                        padding: const EdgeInsets.fromLTRB(22, 34, 22, 22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xFFE4E7EC), width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 92,
                                      height: 92,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFAC515),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x33FAC515),
                                            blurRadius: 26,
                                            offset: Offset(0, 16),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.star_rounded,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: const Color.fromRGBO(0, 102, 204, 1),
                                        ),
                                        children: [
                                          TextSpan(text: context.tr("You're an A–Z\n")),
                                          TextSpan(
                                            text: 'Hero!',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w900,
                                              color: const Color.fromRGBO(0, 102, 204, 1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        context.tr('Letters Mastered'),
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color.fromRGBO(26, 28, 28, 1),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _masteredLettersSection(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _nextLessonButton(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasterChip extends StatelessWidget {
  const _MasterChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color.fromRGBO(26, 28, 28, 1),
          ),
        ),
      ),
    );
  }
}
