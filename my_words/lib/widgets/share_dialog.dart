// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:share_plus/share_plus.dart';

// import 'shared_flashcard.dart';

// Future<void> shareToInstagramStory(
//     BuildContext context, String word, String meaning) async {
//   final controller = ScreenshotController();
//   final bytes = await controller.captureFromWidget(
//     ShareableWordCard(word: word, meaning: meaning),
//     delay: Duration(milliseconds: 10),
//     pixelRatio: 3,
//   );

//   final directory = await getApplicationDocumentsDirectory();
//   final image = File('${directory.path}/word_card.png');
//   image.writeAsBytesSync(bytes);

//   final result = await Share.shareFiles([image.path],
//       text: 'Check out this word I learned with CORCO!');

//   if (result.status == ShareResultStatus.success) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Shared successfully')),
//     );
//   }
// }
