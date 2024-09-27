import 'package:flutter/material.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  final void Function() getCurrentLocationFun;
  const FloatingActionButtonWidget({super.key,required this.getCurrentLocationFun});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: getCurrentLocationFun,
          child: const Icon(Icons.gps_fixed),
        ),
      ],
    );
  }
}
