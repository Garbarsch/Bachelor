
import 'dart:math';

import 'package:latlong2/spline.dart';

import '../models/node.dart';

class hilbertCurve {

  List<Node> geopoints = [];
  var order = 64;


  hilbertCurve() {
    var order = 64;
    var n = pow(order, 2);
    var total = n * n; // number of points which is n sqr
    var dist = 0;


  }


  int encode(Node node) {
    var bits = 32;
    var d = 0, tmp;
    int x = (node.lon*10000000).toInt(), y = (node.lat*10000000).toInt();
    for (var s = (1 << bits) / 2; s > 0; s /= 2){
      var rx = 0, ry = 0;

      if ((x  & s.toInt() ) > 0) rx = 1;
      if ((y  & s.toInt() )> 0) ry = 1;

      d += (s * s * ((3 * rx) ^ ry)).toInt();
      if (ry == 0) {
        if (rx == 1) {
          x = (s - 1 - x).toInt();
          y = (s - 1 - y).toInt();
        }
        tmp = x;
        x = y;
        y = tmp;
      }
      // end inline
    }
    return d;
    }
   Point2D decode(bits, double d) {
    var x = 0, y = 0, tmp;
    var n = 1 << bits;
    for (var s = 1; s < n; s *= 2) {
      var temp = (d / 2);

      var rx = 1 & temp.toInt();
      var ry = 1 & (d.toInt() ^ rx);
      // inlining
      // hilbertRot(s, p, rx, ry)
      if (ry == 0) {
        if (rx == 1) {
          x = s - 1 - x;
          y = s - 1 - y;
        }
        tmp = x;
        x = y;
        y = tmp;
      }
      // end inline

      x += s * rx;
      y += s * ry;
      d /= 4;
    }
    return Point2D(x.toDouble()/10000000, y.toDouble()/10000000);
  }


  }

