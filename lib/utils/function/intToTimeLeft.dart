String intToTimeLeft(int value) {
  int h, m;
  String result="";

  h = value ~/ 3600;

  m = ((value - h * 3600)) ~/ 60;


  String hourLeft =h.toString();

   String minuteLeft =  m.toString();

  if (h==0) {
     result = "$minuteLeft min";
  } else if (m==0) {
     result = "$hourLeft hr";
  }else{
    result ="$hourLeft hr $minuteLeft min ";
  }
  return result;
}

