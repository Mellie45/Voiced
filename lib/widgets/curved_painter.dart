import 'package:flutter/material.dart';
import 'package:wolpz/support_files/constants.dart';

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
        ..color = kDarkBlue
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 0.0;

    Path path_0 = Path();
    path_0.moveTo(size.width*-0.0071624,size.height*0.1346000);
    path_0.cubicTo(size.width*0.0306170,size.height*0.1369857,size.width*0.0278815,size.height*0.1811143,size.width*0.0648834,size.height*0.1822286);
    path_0.cubicTo(size.width*0.1060750,size.height*0.1809286,size.width*0.0977532,size.height*0.1396429,size.width*0.1391176,size.height*0.1356571);
    path_0.cubicTo(size.width*0.1753709,size.height*0.1374714,size.width*0.1684024,size.height*0.1774429,size.width*0.2102707,size.height*0.1786429);
    path_0.cubicTo(size.width*0.2442491,size.height*0.1771143,size.width*0.2431117,size.height*0.1397857,size.width*0.2822877,size.height*0.1370286);
    path_0.cubicTo(size.width*0.3198367,size.height*0.1374000,size.width*0.3215932,size.height*0.1767429,size.width*0.3548518,size.height*0.1778571);
    path_0.cubicTo(size.width*0.3857059,size.height*0.1768857,size.width*0.3880383,size.height*0.1409857,size.width*0.4274734,size.height*0.1385000);
    path_0.cubicTo(size.width*0.4637411,size.height*0.1415857,size.width*0.4644754,size.height*0.1757857,size.width*0.4985834,size.height*0.1764429);
    path_0.cubicTo(size.width*0.5316979,size.height*0.1767857,size.width*0.5321586,size.height*0.1387000,size.width*0.5702404,size.height*0.1370286);
    path_0.cubicTo(size.width*0.6069400,size.height*0.1394286,size.width*0.6116048,size.height*0.1744286,size.width*0.6455976,size.height*0.1775000);
    path_0.cubicTo(size.width*0.6772004,size.height*0.1753714,size.width*0.6762934,size.height*0.1393571,size.width*0.7128202,size.height*0.1354714);
    path_0.cubicTo(size.width*0.7515498,size.height*0.1378000,size.width*0.7524856,size.height*0.1772000,size.width*0.7867808,size.height*0.1788143);
    path_0.cubicTo(size.width*0.8226309,size.height*0.1767286,size.width*0.8251361,size.height*0.1399857,size.width*0.8612022,size.height*0.1370286);
    path_0.cubicTo(size.width*0.8938560,size.height*0.1385000,size.width*0.8952670,size.height*0.1789429,size.width*0.9300949,size.height*0.1797286);
    path_0.cubicTo(size.width*0.9639149,size.height*0.1778714,size.width*0.9650811,size.height*0.1378000,size.width*1.0034796,size.height*0.1370286);
    path_0.quadraticBezierTo(size.width*1.0038971,size.height*0.2263143,size.width*1.0021838,size.height*0.2809000);
    path_0.lineTo(size.width*-0.0051611,size.height*0.2801714);
    path_0.quadraticBezierTo(size.width*-0.0068312,size.height*0.1637571,size.width*-0.0071624,size.height*0.1346000);
    path_0.close();
    canvas.drawPath(path_0, paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}