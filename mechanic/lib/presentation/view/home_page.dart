import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Hello word", style: TextStyle(color: Colors.black, fontSize: 20),),
      ),
    );
  }
}