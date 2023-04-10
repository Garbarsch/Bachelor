class Coord<int> {
  int x;
  double y;

  Coord(this.x, this.y);
}

class SearchBound {
  int begin;
  int end; // Exclusive.

  SearchBound(this.begin, this.end);
}