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

  late final Rectangle<num> bounds; //Bounding box of the country
  late List<MunicipalityRelation> relations;
  late List<Node> nodes;

  PGridFile1(this.bounds,this.relations,this.nodes ); //data kan vi bare tage fra repo

  void initializeGrid(){
    var cellSize = averageMunicipalitySize();
    double height = cellSize.item1;
    double width = cellSize.item2;

    //create linear scales - modified a bid, instead of 2 one-dimensional arrays we use 1 2-d list of rectangles
    linearScalesRectangles = partitionLinearScales(height, width);

    //initial repository - all with key 0 until the block collection has been created.
    gridArray =  List.generate(linearScalesRectangles.length, (index) => List.generate(linearScalesRectangles[0].length, (index) => 0), growable: false);

    //the collection of blocks - a map atm, would be faster in terms of growing data to have a B+ tree probably.
    blockCollection = initializeBlockCollection(linearScalesRectangles);

  }

// For each of the cells (rectangles), collect all nodes within the rectangles as a collection mapped to by a key.
// The repository (gridArray) entry matching the cell index of the linear scales is set to the key of the block (list of nodes).
  Map<int, List<Node>> initializeBlockCollection(List<List<Rectangle>> linearScalesRect) {
    Map<int, List<Node>> blockMap = {}; // Map to store block index and its list of nodes
    int blockCount = 0; // Counter for block index
    int x = 0;
    int y = 0;

    for (var columnList in linearScalesRect) { // Iterate through each column in the grid
      y = 0;
      for (var rowElement in columnList) { // Iterate through each row in the column
        var cellNodes = allNodesInRectangle(rowElement); // Get all nodes in the current rectangle
        blockMap[blockCount] = cellNodes; // Add the nodes to the map with the current block index as key
        gridArray[x][y] = blockCount; // Add the current block index as the value for the grid cell
        blockCount++; // Increment the block index
        y++; // Increment the column index
      }
      x++; // Increment the row index
    }

    return blockMap;
  }


// Partitions the country bounding box into a grid (one list of lists of rectangles) of rectangles based on average municipality size.
  List<List<Rectangle>> partitionLinearScales(double latPartitionSize, double longPartitionSize) {
    // Calculate the number of partitions in the latitude and longitude directions based on the size of each partition.
    var latPartitions = (bounds.height / latPartitionSize).ceil();
    var longPartitions = (bounds.width / longPartitionSize).ceil();

    // Initialize the list of scales with empty lists.
    List<List<Rectangle>> scales = [];

    var left = bounds.left;
    var top = bounds.top; // bottom is top in programming coordinates...

    // For each x cell.
    for (int x = 0; x < longPartitions; x++) {
      top = bounds.top; // top is the bottom left corner.

      // Add a new list for the current x cell.
      scales.add([]);

      // For each cell up.
      for (int y = 0; y < latPartitions; y++) {
        // Add a new rectangle from left, with top (bottom) and width height.
        scales[x].add(Rectangle(left, top, longPartitionSize, latPartitionSize));

        // As we start from bottom left corner, we have to add lat, so the bottom is always one larger.
        top += latPartitionSize;
      }

      // Same here, but left to right.
      left += longPartitionSize;
    }

    return scales;
  }

  // Calculate the average height and width of all municipalities in the list of relations
  Tuple2<double, double> averageMunicipalitySize() {
    double height = 0;
    double width = 0;

    // Iterate over all municipality relations in the list of relations
    for (var relation in relations) {
      // Add the height and width of the bounding box of the municipality relation to the running totals
      height += relation.boundingBox!.height;
      width += relation.boundingBox!.width;
    }

    // Calculate the average height and width of the municipalities and return as a tuple
    // The division by 6 is included to convert from degrees of latitude/longitude to kilometers
    return Tuple2((height / relations.length) / 6, (width / relations.length) / 6);
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