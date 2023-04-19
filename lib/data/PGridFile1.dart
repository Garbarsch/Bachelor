import 'dart:core';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';
import '../models/node.dart';
import '../models/relation.dart';
import 'jsonRepository.dart';

//The Polygon-oriented Grid File version 1
//An algorithm based on the classical spatial indexing technique, Grid File
//Partitions polygon-intersecting grid cells to sub-grids in order to reduce
//search time for highly dense areas in the space when searching for polygon formed areas.
//Well-suited for urban spatial indexing of areas such as cities, regions, municipalities and the like.
//@Author Carl Bruun and Rasmus Garbarsch

class PGridFile1 {
  //gridArray is a two-dimensional grid/matrix of all cells of our grid
  //Each cell element holds a pointer to the bucket/block/data page that contains the data points of that cell
  //The gridArray is also known as the directory.
  late final List<List<int>> gridArray;

  //The linear scales: a 2-d array defining the partitions of each of the domains as Rectangles (grid cells) in the space.
  late final List<List<Rectangle>> linearScalesRectangles;

  //Collection of blocks that the gridArray points to - map is well suited for a small collection, but is it scalable? it is for now at least.
  late final Map<int, List<Node>> blockCollection; //b-tree or quadtree.

  late int blockCapacity; //Block/Bucket capacity; how many records (nodes) fits here - some value we "assume".
  late final Rectangle<num> bounds; //Bounding box of the country
  late List<MunicipalityRelation> relations;
  late List<Node> nodes;

  PGridFile1(this.bounds, this.blockCapacity,this.relations,this.nodes ); //data kan vi bare tage fra repo

  void initializeGrid(){
    var cellSize = averageMunicipalitySize();
    double height = cellSize.item1;
    double width = cellSize.item2;

    //create linear scales - modified a bid, instead of 2 one-dimensional arrays we use 1 2-d list of rectangles
    linearScalesRectangles = partitionLinearScales(width, height);

    //initial repository - all with key 0 until the block collection has been created.
    gridArray =  List.generate(linearScalesRectangles.length, (index) => List.generate(linearScalesRectangles[0].length, (index) => 0), growable: false);

    //the collection of blocks - a map atm, would be faster in terms of growing data to have a B+ tree probably.
    blockCollection = initializeBlockCollection(linearScalesRectangles);

  }

  //For each of the cells (rectangles), collect all nodes within the rectangles as a collection mapped to by a key
  //the repository (gridArray) entry matching the cell index of the linear scales is set to the key of the block (list of nodes)
  Map<int, List<Node>> initializeBlockCollection(List<List<Rectangle>>linearScalesRect){ //TODO: vi kan godt optimere dette, så vi løber alle nodes igennem 1 gang, og så putter dem korrekt ind
    Map<int, List<Node>> blockMap = {};
    int blockCount = 0;
    int x = 0;
    int y = 0;
    for (var columnList in linearScalesRect) { //columns
      y=0;
      for (var rowElement in columnList) { //each row rectangle
        var cellNodes = allNodesInRectangle(rowElement); //all nodes in that rectangle
        blockMap[blockCount] = cellNodes; //block will not overflow: add nodes (IF WE CHANGE THIS, WE HAVE TO DO AN ADD ALL HERE)
        gridArray[x][y] = blockCount; //add key to directory
        blockCount++;
        y++;
      }
      x++;
    }

    return blockMap;
  }

  List<List<Rectangle>> partitionLinearScales(double latPartitionSize, double longPartitionSize) {
    final latPartitions = (bounds.height / latPartitionSize).ceil();
    final longPartitions = (bounds.width / longPartitionSize).ceil();

    final List<List<Rectangle>> scales = [];

    var left = bounds.left;
    var top = bounds.top;

    // For each x cell
    for (int x = 0; x < longPartitions; x++) {
      top = bounds.top; // Top is the bottom left corner
      scales.add([]);
      // For each cell up
      for (int y = 0; y < latPartitions; y++) {
        //if we are at the last cell to before we hit the right side of Denmark bounds
        //var rectangle;
        /*if(x==longPartitions-1 && y!=latPartitions-1){
          rectangle = Rectangle(left, top, bounds.right-left, latPartitionSize);
        }else if(x!=longPartitions-1 && y==latPartitions-1){
          rectangle = Rectangle(left, top, longPartitionSize, bounds.top-top);
        }else if(x ==longPartitions-1 && y==latPartitions-1){
          rectangle = Rectangle(left, top, bounds.right-left, bounds.top-top);
        }else{
          rectangle = Rectangle(left, top, longPartitionSize, latPartitionSize);
        }*/
        var rectangle = Rectangle(left, top, longPartitionSize, latPartitionSize);
        scales[x].add(rectangle);
        top += latPartitionSize; // Add lat to ensure the bottom is always one larger
      }
      left += longPartitionSize; // Add long to move from left to right
    }
    return scales;
  }


  Tuple2<double, double> averageMunicipalitySize(){
    double height = 0;
    double width = 0;
    for (var element in relations) {
      height += element.boundingBox!.height;
      width += element.boundingBox!.width;
    }
    //average height, average width
    return Tuple2((height/(relations.length)/6), (width/(relations.length)/6));
  }

  //Given a range query (rectangle), find all intersecting cells of the grid
  //find the block pointers of the cells in the directory
  //return the blocks that match.
  List<Node> find (MunicipalityRelation query){

    Stopwatch stopwatch = new Stopwatch()..start();
    List<Node> nodes = [];
    List<List<LatLng>> polyBounds = getMunilist([query.name]);
    List<List<LatLng>> concavePoints = getConcavePointsOfPolygon(polyBounds);
    List<Tuple2<int, int>> containingIndices = [];

    Stopwatch stopwatch2 = new Stopwatch()..start();
    //Search the grid for cells that intersect the query rectangle and save their indices
    for (int i = 0; i < linearScalesRectangles.length; i++){
      List<Rectangle> innerList = linearScalesRectangles[i];
      List<Tuple2<int, int>> intersectingIndices = innerList
          .asMap()
          .entries
          .where((entry) => entry.value.intersects(query.boundingBox!))
          .map((entry) => Tuple2(i, entry.key))
          .toList();

      if (intersectingIndices.isNotEmpty) {
        containingIndices.addAll(intersectingIndices);
      }
    }

    print("PGrid File1 find intersecting cells time: ${stopwatch2.elapsed.inMilliseconds}");

    Stopwatch stopwatch3 = new Stopwatch()..start();
    nodes = cellStatusSort(containingIndices, polyBounds,concavePoints, query.boundingBox!);
    print("cellStatusSort Time: ${stopwatch3.elapsed.inMilliseconds}");
    
    print("PGrid1 File Total Find Time: ${stopwatch.elapsed.inMilliseconds}");
    return nodes;
  }

  RectStatus isFullyContained(Rectangle rect, List<List<LatLng>> polyBounds, List<List<LatLng>> concavePoints, Rectangle muniBoundingBox) {

    // Convert rectangle corners to LatLng points.
    final corners = [
      LatLng(rect.topLeft.y.toDouble(), rect.topLeft.x.toDouble()),
      LatLng(rect.topRight.y.toDouble(), rect.topRight.x.toDouble()),
      LatLng(rect.bottomLeft.y.toDouble(), rect.bottomLeft.x.toDouble()),
      LatLng(rect.bottomRight.y.toDouble(), rect.bottomRight.x.toDouble()),
    ];

    bool anyPolygonIntersects = false; // Keep track whether any polygon intersects the cell rectangle.

    // Check each polygon of the municipality for containment.
    for (final polygon in polyBounds) {

      bool allCornersInside = true;
      bool anyCornerInside = false;

      // Check for each corner if they are inside the polygon.
      for (final corner in corners) {
        if (!jsonRepository.isPointInPolygon(corner, polygon)) {
          allCornersInside = false;
        } else {
          anyCornerInside = true;
        }

        // If not all corners are inside, but we know at least one is, we break out of the loop.
        if (!allCornersInside && anyCornerInside) {
          break;
        }
      }
      if(!allCornersInside && anyCornerInside){
        anyPolygonIntersects = true;
      }else if (concavePoints[polyBounds.indexOf(polygon)]
          .any((point) => latLongInRect(point, rect))) {
          anyPolygonIntersects = true;
      }else if(allCornersInside){
        return RectStatus.inside;
      }
    }
    if (!anyPolygonIntersects) {
      return RectStatus.outside;
    }

    //If we get here, the cell intersects at least one polygon.
    return RectStatus.intersect;
  }



// Collects the concave points of a polygon.
  List<List<LatLng>> getConcavePointsOfPolygon(List<List<LatLng>> boundaryCoords) {
    Stopwatch stopwatch = new Stopwatch()..start();
    List<List<LatLng>> concavePoints = [];

    // Iterate over each polygon in the list of boundary coordinates
    for (var polygonCoordList in boundaryCoords) {
      List<LatLng> points = [];

      // Iterate over each point in the polygon
      for (int i = 0; i < polygonCoordList.length; i++) {
        // Get the current point and the two adjacent points with respect to circularity
        LatLng now = polygonCoordList[i];
        LatLng before = polygonCoordList[(i - 1) % polygonCoordList.length];
        LatLng after = polygonCoordList[(i + 1) % polygonCoordList.length];

        // Check if the current point is a concave point based on its latitude and longitude
        if (now.latitude > before.latitude && now.latitude > after.latitude ||
            now.longitude > before.longitude && now.longitude > after.longitude) {
          points.add(now);
        }
      }
      concavePoints.add(points);
    }
    print("Get concave points time: ${stopwatch.elapsed.inMilliseconds}");
    return concavePoints;
  }


  List<Node> cellStatusSort(List<Tuple2<int, int>> containingIndices, List<List<LatLng>> polyBounds, List<List<LatLng>> concavePoints, Rectangle muniBoundingBox) {
    List<Node> nodes = [];
    print("Amount of top-layer cells: ${containingIndices.length}");
    int countTopCellsFullyContained = 0;
    int intersectingCells = 0;

    for (var cellIndex in containingIndices) {
      var rect = linearScalesRectangles[cellIndex.item1][cellIndex.item2];
      var rectStatus = isFullyContained(rect, polyBounds, concavePoints, muniBoundingBox);

      var block = blockCollection[gridArray[cellIndex.item1][cellIndex.item2]]!;

      if (rectStatus == RectStatus.inside) {
        countTopCellsFullyContained++;
        nodes.addAll(block.where((node) => node.isAmenity));
      } else if (rectStatus == RectStatus.intersect) {
        intersectingCells++;
        nodes.addAll(block.where((node) {
          if (!node.isAmenity) {
            return false;
          }
          for (int i = 0; i < polyBounds.length; i++) {
            if (jsonRepository.isPointInPolygon(LatLng(node.lat, node.lon), polyBounds[i])) {
              return true;
            }
          }
          return false;
        }));
      }
    }

    print("top-layer cells fully contained: ${countTopCellsFullyContained}");
    print("top-layer cells intersecting: ${intersectingCells}");

    return nodes;
  }
  List<Node> allNodesInRectangle(Rectangle rect){
    List<Node> nodesList  = [];
    nodes.forEach((node) {
      if(rect != null){
        if(node.lon >= rect.left &&
            node.lon <= rect.left + rect.width &&
            node.lat >= rect.top &&
            node.lat <= rect.top + rect.height){
          nodesList.add(node);
        }
      }
    });
    return nodesList;
  }
  List<List<LatLng>> getMunilist(List<String> municipalities){
    List<List<LatLng>> list = [];
    var muni = relations.where((element) => municipalities.contains(element.name));
    for (var boundary in muni) {
      if(boundary.isMulti){
        for (var coordList in boundary.multiBoundaryCoords!) {
          list.add(coordList);
        }
      }
      else{
        list.add(boundary.boundaryCoords);
      }
    }
    return list;

  }


  bool latLongInRect (LatLng point, Rectangle rect){
    return (point.longitude >= rect.left &&
        point.longitude <= rect.left + rect.width &&
        point.latitude >= rect.top &&
        point.latitude <= rect.top + rect.height);
  }



}enum RectStatus {inside, outside, intersect }