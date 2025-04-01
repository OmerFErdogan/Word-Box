import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/words_model.dart';

class UserProfile extends StatelessWidget {
  final WordsModel wordsModel;

  UserProfile({required this.wordsModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Level: ${wordsModel.currentLevel}'),
          LinearProgressIndicator(
            value: _calculateExpProgress(
                wordsModel.currentExp, wordsModel.currentLevel),
          ),
          Text('${wordsModel.currentExp} EXP'),
        ],
      ),
    );
  }

  double _calculateExpProgress(int exp, int level) {
    const expThresholds = [
      300,
      480,
      756,
      1134,
      1701,
      2551,
      3827,
      5740,
      8610,
      12915,
      19372,
      29058,
      43587,
      65380,
      98070,
      147105,
      220658,
      331012,
      496518,
      744777,
      982839,
      1312233,
      1758449,
      2343737,
      3125769,
      4170725,
      5563931,
      7421274,
      9900066,
      13260087,
      17756114,
      23799032,
      31894722,
      42740199,
      57218661,
      76668893,
      102425919,
      136901010,
      183329343,
      245195973
    ];

    if (level - 1 >= expThresholds.length) return 1.0;
    if (level == 1) return exp / expThresholds[0];
    return (exp - expThresholds[level - 2]) /
        (expThresholds[level - 1] - expThresholds[level - 2]);
  }
}
