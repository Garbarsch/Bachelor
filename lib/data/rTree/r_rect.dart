part of r_tree;



abstract class RRect {
  Rectangle? get rect;

  // Calculate if otherRect overlaps with the current rectangle
  //
  // This function is a replication of Rectangle.intersects. It differs in that
  // the inequalities are strict and do not allow for equivalences. This means
  // that the two rectangles are not considered overlapping if they share an edge.
  bool overlaps(Rectangle otherRect) {
    return (rect!.left < otherRect.left + otherRect.width &&
        otherRect.left < rect!.left + rect!.width &&
        rect!.top < otherRect.top + otherRect.height &&
        otherRect.top < rect!.top + rect!.height);
  }
}
class RDataRect<E> extends RRect{
  final Rectangle rect;
  final E value;

  RDataRect(this.rect, this.value);


}
