import 'package:flutter/material.dart';
import 'home_screen.dart';

// CHANGE TO:
const _emblemAsset = 'assets/logo.jpeg';
const _personAsset = 'assets/co.jpeg';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF888C96),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle radial gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF9A9EA8), Color(0xFF74777F)],
              ),
            ),
          ),

          // ── Top-centre: title ─────────────────────────────────
          Positioned(
            top: 36,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'B I P',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 67,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: Color(0xFFCC1F1F),
                    shadows: [
                      Shadow(
                        color: Color(0x55000000),
                        blurRadius: 4,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '(Bn Information Package)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFCC1F1F),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFCC1F1F),
                    shadows: [
                      Shadow(
                        color: Color(0x44000000),
                        blurRadius: 3,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Centre: emblem ────────────────────────────────────
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5F0E8), Color(0xFFEDE5D0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFFB8802E), width: 5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Color(0x22B8802E),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                _emblemAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _emblemPlaceholder(),
              ),
            ),
          ),

          // ── Bottom-left: tagline ──────────────────────────────
          const Positioned(
            left: 50,
            bottom: 50,
            child: Text(
              'A unique Solution for\nArmy Infantry Units\nAutomation',
              style: TextStyle(
                fontSize: 30,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE8EAF0),
                height: 1.6,
                shadows: [
                  Shadow(
                    color: Color(0x66000000),
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom-right: person photo ────────────────────────
          Positioned(
            right: 40,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFF5B9BD5), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    _personAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _personPlaceholder(),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                    width: 36, height: 1.4, color: const Color(0xFF5B9BD5)),
                const SizedBox(height: 8),
                const Text(
                  'COL KAMLESH KANDPAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: Color(0xFFE8EAF0),
                    shadows: [
                      Shadow(
                        color: Color(0x66000000),
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Enter button: bottom centre ───────────────────────
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 42,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xAAFFFFFF)),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _emblemPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.military_tech_outlined, size: 64, color: Color(0xFF8A7A5A)),
        SizedBox(height: 8),
        Text(
          'Add Emblem Image\n(set _emblemUrl in splash_screen.dart)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF8A7A5A)),
        ),
      ],
    );
  }

  static Widget _personPlaceholder() {
    return Container(
      color: const Color(0xFFD6D8DE),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 44, color: Color(0xFF7A7F8A)),
          SizedBox(height: 4),
          Text(
            'Photo',
            style: TextStyle(fontSize: 10, color: Color(0xFF7A7F8A)),
          ),
        ],
      ),
    );
  }
}
