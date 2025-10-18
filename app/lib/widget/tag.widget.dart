import 'package:flutter/cupertino.dart';

class Tag extends StatelessWidget {
  final Color color;
  final String text;

  const Tag({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(text),
      ),
    );
  }
}
