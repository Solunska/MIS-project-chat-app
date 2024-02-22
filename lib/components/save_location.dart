import 'package:flutter/material.dart';

class SaveIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveIconButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        Icons.save,
        color: Color(0xFFfffcf2),
      ),
    );
  }
}
