import 'package:flutter/material.dart';

class QuestionsSummary extends StatelessWidget {
  const QuestionsSummary(this.summaryData, {super.key});

  final List<Map<String, Object>> summaryData;

  static const _correctColor = Color(0xFF7BD389);
  static const _wrongColor = Color(0xFFF28B82);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...summaryData.map((data) {
            final isCorrect = data['user_answer'] == data['correct_answer'];
            final questionNumber = (data['question_index'] as int) + 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isCorrect ? _correctColor : _wrongColor,
                    child: Text(
                      questionNumber.toString(),
                      style: const TextStyle(
                        color: Color(0xFF1B2A4A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['question'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tvoja odpoveď: ${data['user_answer']}',
                          style: TextStyle(
                            color: isCorrect ? _correctColor : _wrongColor,
                          ),
                        ),
                        Text(
                          'Správna odpoveď: ${data['correct_answer']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
