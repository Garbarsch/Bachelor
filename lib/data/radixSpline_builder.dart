
import 'dart:math';
import 'common.dart';
import 'package:github_client/data/radixSpline.dart';


import 'radixSpline.dart';

/// Allows building a [RadixSpline] in a single pass over sorted data.
///
enum Orientation { collinear, cw, ccw }
class Builder {
  late final int minKey;
  late final int maxKey;
  final int numRadixBits;
  final int maxError;
  late int numShiftBits;
  late int currNumKeys;
  late int currNumDistinctKeys;
  late int prevKey;
  late double prevPosition;
  late int prevPrefix;
  late final List<int> radixTable;
  late final List<Coord<int>> splinePoints;
  //previus CDF point
  late Coord prevPoint;
  // Current upper and lower limits on the error corridor of the spline.
  late Coord upperLimit;
  late Coord lowerLimit;

  Builder(this.minKey,
      this.maxKey, {
        this.numRadixBits = 18,
        this.maxError = 32,
      })
      : assert(numRadixBits >= 0),
        assert(maxError > 0) {
    numShiftBits = _getNumShiftBits(maxKey - minKey, numRadixBits);
    print("numshiftbits"); print(numShiftBits);
    currNumKeys = 0;
    currNumDistinctKeys = 0;
    prevKey = minKey;
    prevPosition = 0;
    prevPrefix = 0;

    // Initialize radix table, needs to contain all prefixes up to the largest
    // key + 1.
    print("max - min"); print(maxKey-minKey);
    final maxPrefix = (maxKey - minKey) >> numShiftBits;
    print("her, MaxPrefix:"); print(maxPrefix);
    print(List.filled(maxPrefix + 2, 0).length);
    radixTable = List.filled(maxPrefix + 2, 0);
    print("her2");
    splinePoints = [];
  }
  static int countLeadingZeros(int x) {
    int n = 64; // assuming 32-bit integer
    int y = x;
    int c = n >> 1;
    while (c != 0) {
      int z = y >> c;
      if (z != 0) {
        n -= c;
        y = z;
      }
      c >>= 1;
    }
    return n - y.bitLength + 1;
  }

  // Returns the number of shift bits based on the `diff` between the largest
  // and the smallest key.

  static int _getNumShiftBits(int diff, int numRadixBits) {
    final clz = countLeadingZeros(diff);
    print("clz"); print(clz);
    print(64-numRadixBits-clz);
    if((64-clz)<numRadixBits) return 0;
    return 64-numRadixBits-clz;
  }

  /// Adds a key. Assumes that keys are stored in a dense array.

  void AddKey(int key) {
    if (currNumKeys == 0) {
      addKey(key, /*position=*/0);
      return;
    }
    addKey(key, prevPosition + 1);
  }

  void addKey(int key, double position) {
    assert(key >= minKey && key <= maxKey);
    // Keys need to be monotonically increasing.
    assert(key >= prevKey);
    // Positions need to be strictly monotonically increasing.
    assert(prevPosition == 0 || position > prevPosition);

    _possiblyAddKeyToSpline(key, position + 1);

    currNumKeys++;
    prevKey = key;
    prevPosition++;
  }

 static double precision = 4.94065645841247E-324;

  Orientation computeOrientation(double dx1, double dy1, double dx2, double dy2) {
  final expr = (dy1 * dx2) - (dy2 * dx1);
  if (expr > precision) {
    return Orientation.cw;
  } else if (expr < -precision) {
    return Orientation.ccw;
  }
  return Orientation.collinear;
  }

  void setUpperLimit(int key, double position) {
    upperLimit = Coord(key, position);
  }
  void setLowerLimit(int key, double position) {
    lowerLimit = Coord(key, position);
  }
  void rememberPreviousCDFPoint(int key, double position) {
    prevPoint = Coord(key,position);
  }

  // Implementation is based on `GreedySplineCorridor` from:
  // T. Neumann and S. Michel. Smooth interpolating histograms with error
  // guarantees. [BNCOD'08]
  void _possiblyAddKeyToSpline(int key, double position) {
    // Add first CDF point to spline.
    if(currNumKeys == 0){
      _addKeyToSpline(key, position);
      currNumDistinctKeys++;
      rememberPreviousCDFPoint(key,position);
      return;
    }

    if(key == prevKey){
      // No new CDF point if the key didn't change.
      return;
    }
    // New CDF point.
    currNumDistinctKeys++;

    if(currNumDistinctKeys == 2){
      // Initialize `upper_limit_` and `lower_limit_` using the second CDF
      // point.
      setUpperLimit(key, position + maxError);
      setLowerLimit(key, (position < maxError) ? 0 : position - maxError);
      rememberPreviousCDFPoint(key, position);
      return;
    }
    // `B` in algorithm.
    final last = splinePoints.last;
    // Compute current `upperY` and `lowerY`.
    final double upperY = position + maxError;
    final  double lowerY = (position < maxError) ? 0 : position - maxError;

    //Compute differences.
    assert(upperLimit.x >= last.x.toDouble());
    assert(lowerLimit.x >= last.x.toDouble());
    assert(key >= last.x.toDouble());
    final double upperLimitXDiff = (upperLimit.x - last.x).toDouble();
    final double lowerLimitXDiff = (lowerLimit.x - last.x).toDouble();
    final double xDiff = (key - last.x).toDouble();

    assert(upperLimit.y >= last.y.toDouble());
    assert(position >= last.y.toDouble());
    final double upperLimitYDiff = upperLimit.y - last.y;
    final double lowerLimitYDiff = lowerLimit.y - last.y;
    final double yDiff = position - last.y;

    // `prevPoint` is the previous point on the CDF and the next candidate to
    // be added to the spline. Hence, it should be different from the `last`
    // point on the spline.
    assert(prevPoint.x != last.x);
    // Do we cut the error corridor?
    if ((computeOrientation(upperLimitXDiff, upperLimitYDiff, xDiff, yDiff) != Orientation.cw) ||
        (computeOrientation(lowerLimitXDiff, lowerLimitYDiff, xDiff, yDiff) != Orientation.ccw)) {
      // Add previous CDF point to spline.
      _addKeyToSpline(prevPoint.x, prevPoint.y);

      // Update limits.
      setUpperLimit(key, upperY);
      setLowerLimit(key, lowerY);
    } else {
      assert(upperY >= last.y);
      final upperYDiff = upperY - last.y;
      if (computeOrientation(upperLimitXDiff, upperLimitYDiff, xDiff, upperYDiff) == Orientation.cw) {
        setUpperLimit(key, upperY);
      }

      final lowerYDiff = lowerY - last.y;
      if (computeOrientation(lowerLimitXDiff, lowerLimitYDiff, xDiff, lowerYDiff) == Orientation.ccw) {
        setLowerLimit(key, lowerY);
      }
    }

    rememberPreviousCDFPoint(key, position);

  }

  void _addKeyToSpline(int key, double position) {
    splinePoints.add(Coord(key, position));
    possiblyAddKeyToRadixTable(key);
  }

  void possiblyAddKeyToRadixTable(int key) {
    final int currPrefix = (key - minKey) >> numShiftBits;
    if (currPrefix != prevPrefix) {
      final int currIndex = splinePoints.length - 1;
      for (var prefix = prevPrefix + 1; prefix <= currPrefix; ++prefix) {
        radixTable[prefix] = currIndex;
      }
      prevPrefix = currPrefix;
    }
  }

  void finalizeRadixTable() {
    prevPrefix++;
    final numSplinePoints = splinePoints.length;
    for (; prevPrefix < radixTable.length; prevPrefix++) {
      radixTable[prevPrefix] = numSplinePoints;
    }
  }


  /// Finalizes the construction and returns a read-only [RadixSpline].
  RadixSpline finalize() {
    // Last key needs to be equal to `maxKey`.
    assert(currNumKeys == 0 || prevKey == maxKey);

    // Ensure that `prevKey` (== `maxKey`) is last key on spline.
    if (currNumKeys > 0 && splinePoints.last.x != prevKey) {
      _addKeyToSpline(prevKey, prevPosition);
    }

    // Maybe even size the radix based on max key right from the start
    finalizeRadixTable();

    return RadixSpline(
      minKey,
      maxKey,
      currNumKeys,
      numRadixBits,
      numShiftBits,
      maxError,
      radixTable,
      splinePoints,
    );
  }
}


