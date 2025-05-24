import 'package:flutter/material.dart';

class TestingField extends StatefulWidget {

  const TestingField({super.key});

  @override
  State<TestingField> createState() => _TestingFieldState();
}

class _TestingFieldState extends State<TestingField> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}