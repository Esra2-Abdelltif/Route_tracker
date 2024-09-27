import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:route_tracker/utils/function/calculate_future_time.dart';
import 'package:route_tracker/utils/function/intToTimeLeft.dart';

class RouteDetailsInfoWidget extends StatelessWidget {
  final String duration;
  final int distanceMeters;
  final void Function() startRouteFun;
  final void Function() cancelRouteFun;


  const RouteDetailsInfoWidget(
      {super.key, required this.distanceMeters, required this.duration,required this.startRouteFun,required this.cancelRouteFun});

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
        const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconContainerWidget(
              icon: Icons.close,
              iconFun: cancelRouteFun,
            ),
            Center(
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
            IconContainerWidget(
              icon: Icons.alt_route_outlined,
              iconFun: startRouteFun,
            )

          ],
        ),
      ),
    );
  }

}
class IconContainerWidget extends StatelessWidget {
  const IconContainerWidget({super.key,required this.iconFun,required this.icon});
  final void Function() iconFun;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return   MouseRegion(
        cursor: SystemMouseCursors.click,
      child: GestureDetector(
behavior: HitTestBehavior.translucent,
        onTap:iconFun,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              // color: Colors.blue,
              border: Border.all(width: 1, color: Colors.white)
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
