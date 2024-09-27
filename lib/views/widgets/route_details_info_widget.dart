import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:route_tracker/utils/function/calculate_future_time.dart';
import 'package:route_tracker/utils/function/intToTimeLeft.dart';

class RouteDetailsInfoWidget extends StatelessWidget {
  final String duration;
  final int distanceMeters;

  const RouteDetailsInfoWidget(
      {super.key, required this.distanceMeters, required this.duration});

  @override
  Widget build(BuildContext context) {
    int durationValue=int.parse(duration.replaceAll("s", ""));
    String formattedTime =DateFormat('hh:mm a').format(calculateFutureTime(durationValue));
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20)),
      ),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Column(
            children: [
              Text(
                intToTimeLeft(durationValue),
                style: const TextStyle(
                    color: Colors.green, fontSize: 20),
              ),
              Text("${(distanceMeters / 1000).toStringAsFixed(1)} Km . $formattedTime",
                style: const TextStyle(color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
    );
  }

}