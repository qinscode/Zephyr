import 'package:flutter/material.dart';

class BaseView extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;
  final Widget? floatingActionButton;

  const BaseView({
    super.key,
    required this.title,
    required this.actions,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: Text(title),
            actions: actions,
          ),
          body,
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
