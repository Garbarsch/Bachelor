import 'dart:math';


import 'common.dart';


class RadixSpline {
  int minKey;
  int maxKey;
  int numKeys;
  int numRadixBits;
  int numShiftBits;
  int maxError;
  List<int> radixTable;
  List<Coord<int>> splinePoints;

  RadixSpline(this.minKey,
      this.maxKey,
      this.numKeys,
      this.numRadixBits,
      this.numShiftBits,
      this.maxError,
      this.radixTable,
      this.splinePoints,);


  double getEstimatedPosition(int key) {
    if (key! <= minKey) return 0;
    if (key! >= maxKey) return numKeys! - 1;

    final index = getSplineSegment(key);
    final down = splinePoints[index - 1];
    final up = splinePoints[index];

    final xDiff = up.x - down.x;
    final yDiff = up.y - down.y;
    final double slope = yDiff / xDiff;

    final keyDiff = key - down.x;
    return keyDiff * slope + down.y;
  }

  SearchBound getSearchBound(int key) {
    final int estimate = getEstimatedPosition(key).toInt();
    final int begin = max(0, estimate - maxError);
    final end = min(numKeys, estimate + maxError + 2);
    return SearchBound(begin, end);
  }
  int getSplineSegment(int key) {
    final prefix = (key - minKey) >> numShiftBits;
    assert(prefix + 1 < radixTable.length);
    final begin = radixTable[prefix];
    final end = radixTable[prefix + 1];

    if (end - begin < 32) {
      var current = begin;
      while (splinePoints[current].x < key) {
        ++current;
      }

      return current;
    }

    final lb = lowerBound(splinePoints.sublist(begin, end), key,
            (Coord<int> coord, int key) => coord.x < key);
    return begin + lb;
  }
  int lowerBound(List<Coord<int>> list, int value, bool Function(Coord<int> a, int b) compare) {
    int first = 0;
    int count = list.length;
    while (count > 0) {
      final int step = count ~/ 2;
      final int it = first + step;
      final Coord<int> coord = list[it];
      if (compare(coord, value)) {
        first = it + 1;
        count -= step + 1;
      } else {
        count = step;
      }
    }
    return first;
  }
  int lowerBound2(List<int> arr, int lowerBoundIndex, int upperBoundIndex, int target) {
    int left = lowerBoundIndex;
    int right = upperBoundIndex;
    int result = -1;

    while (left <= right) {
      int mid = (left + right) ~/ 2;


      if (arr[mid] >= target) {
        result = mid;
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    }

    return result;
  }
}




