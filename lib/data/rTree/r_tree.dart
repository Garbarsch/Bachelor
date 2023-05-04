/*
 * Copyright 2015 Workiva Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of r_tree;

/// A two dimensional index of data that allows querying by rectangular areas
class RTree<E> {
  late Node<E> _root;
  late int _branchFactor;

  RTree([int branchFactor = 9]) {
    if (branchFactor < 3) {
      throw ArgumentError('branchFactor must be greater than 2');
    }
    _branchFactor = branchFactor;
    _resetRoot();
  }

  remove(RDataRect<E> item) {
    _root.remove(item);

    if (_root.children.isEmpty) {
      _resetRoot();
    }
  }

  insert(RDataRect<E> item) {
    Node<E>? splitNode = _root.insert(item);

    if (splitNode != null) {
      _growTree(_root, splitNode);
    }
  }
  getChildren(){
    List<Polygon> rTreePolygons  = [];
    _root.children.forEach((element)  {rTreePolygons.add(Polygon(points: [LatLng(element.rect!.bottomLeft.y.toDouble(), element.rect!.bottomLeft.x.toDouble()),LatLng(element.rect!.topLeft.y.toDouble(), element.rect!.topLeft.x.toDouble()),LatLng(element.rect!.topRight.y.toDouble(), element.rect!.topRight.x.toDouble()),LatLng(element.rect!.bottomRight.y.toDouble(), element.rect!.bottomRight.x.toDouble()) ],isFilled: false, color: Colors.redAccent)); });
  return rTreePolygons;
  }

  _resetRoot() {
    _root = LeafNode<E>(_branchFactor);
  }

  // Returns all items whose rectangles overlap the @searchRect
  //  Note: Rectangles that share only a border are not considered to overlap
  Iterable<RDataRect<E>>? search(Rectangle searchRect,
      {bool Function(E item)? shouldInclude}) {
    shouldInclude ??= (_) => true;

    if (_root is LeafNode<E>) {
      return _root.search(searchRect, shouldInclude).toList();
    }

    return _root.search(searchRect, shouldInclude);
  }

  _growTree(Node<E> node1, Node<E> node2) {
    NonLeafNode<E> newRoot = NonLeafNode<E>(_branchFactor);
    newRoot.addChild(node1);
    newRoot.addChild(node2);
    _root = newRoot;
  }
}