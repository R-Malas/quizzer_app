import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton(
      {Key? key,
      required this.label,
      required this.color,
      required this.onPress})
      : super(key: key);

  final String label;
  final Color color;
  final void Function()? onPress;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ElevatedButton(
        onPressed: onPress,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey;
            }
            return color;
          },
        )),
      ),
    );
  }
}
