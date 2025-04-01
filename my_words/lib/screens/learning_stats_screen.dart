import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_words/models/words_model.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WordsModel>(
      builder: (context, wordsModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(wordsModel),
                  const SizedBox(height: 20),
                  _buildLearningChart(wordsModel),
                  const SizedBox(height: 20),
                  _buildCategoryDistribution(wordsModel),
                  const SizedBox(height: 20),
                  _buildAchievements(wordsModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(WordsModel model) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Total Words: ${model.words.length}'),
            Text('Favorite Words: ${model.favoriteWords.length}'),
            Text('Current Streak: ${model.currentStreak} days'),
            Text('Current Level: ${model.currentLevel}'),
            Text('Current EXP: ${model.currentExp}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningChart(WordsModel model) {
    List<FlSpot> spots = [];
    model.learningStats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))
      ..forEach((entry) {
        spots.add(FlSpot(entry.key.millisecondsSinceEpoch.toDouble(),
            entry.value.toDouble()));
      });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Learning Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution(WordsModel model) {
    Map<String, int> categoryCount = {};
    for (var word in model.words) {
      for (var category in word.categories) {
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category Distribution',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...categoryCount.entries
                .map((entry) => Text('${entry.key}: ${entry.value} words'))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(WordsModel model) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Achievements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Bu kısmı, mevcut başarımlarınıza göre düzenleyin
            ListTile(
              leading: Icon(Icons.emoji_events,
                  color:
                      model.words.length >= 10 ? Colors.yellow : Colors.grey),
              title: const Text('Beginner'),
              subtitle: const Text('Save 10 words'),
            ),
            ListTile(
              leading: Icon(Icons.emoji_events,
                  color:
                      model.words.length >= 50 ? Colors.yellow : Colors.grey),
              title: const Text('Intermediate'),
              subtitle: const Text('Save 50 words'),
            ),
            // Daha fazla başarım ekleyebilirsiniz
          ],
        ),
      ),
    );
  }
}
