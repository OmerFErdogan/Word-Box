import 'package:flutter/material.dart';

class ShareableWordCard extends StatelessWidget {
  final String word;
  final String meaning;
  final String example;

  const ShareableWordCard({
    Key? key,
    required this.word,
    required this.meaning,
    required this.example,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      color: const Color(0xFF2D2D3A),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  '-' + meaning,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 36,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                Text(
                  example,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset('assets/images/playstore.png',
                    width: 100, height: 100),
                const SizedBox(height: 20),
                const Text(
                  'CORCO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
