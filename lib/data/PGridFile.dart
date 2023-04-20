import 'dart:core';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';
import '../models/node.dart';
import '../models/relation.dart';
import 'jsonRepository.dart';

//The Polygon-oriented Grid File
//An algorithm based on the classical spatial indexing technique, Grid File
//Partitions polygon-intersecting grid cells to sub-grids in order to reduce
//search time for highly dense areas in the space when searching for polygon formed areas.
//Well-suited for urban spatial indexing of areas such as cities, regions, municipalities and the like.
//@Author Carl Bruun and Rasmus Garbarsch

class PGridFile {
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

  PGridFile(this.bounds, this.relations,this.nodes); //data kan vi bare tage fra repo

  void initializeGrid(){
    print("PGridFile (subgrid)");
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


// Given a range query (rectangle), find all intersecting cells of the grid,
// find the block pointers of the cells in the directory, and return the nodes of the blocks that match.
  List<List<Node>> find(MunicipalityRelation query) {
    // Create a stopwatch to measure the performance of the function.
    Stopwatch stopwatch = new Stopwatch()..start();

    // Initialize variables for storing nodes, polygon boundaries, concave points, and containing indices.
    List<List<Node>> nodes = [];
    List<List<LatLng>> polyBounds = getQueryPolyBoundaryPoints(query);
    List<List<LatLng>> concavePoints = getConcavePointsOfPolygon(polyBounds);
    List<Tuple2<int, int>> containingIndices = [];

    // Create a stopwatch to measure the time it takes to find intersecting cells.
    Stopwatch stopwatch2 = new Stopwatch()..start();

    // Search the grid for cells that intersect the query rectangle and save their indices.
    for (int i = 0; i < linearScalesRectangles.length; i++) {
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
    print("PGrid File find intersecting cells time: ${stopwatch2.elapsed.inMilliseconds}");

    // Create a stopwatch to measure the time it takes to sort cell statuses.
    Stopwatch stopwatch3 = new Stopwatch()..start();

    // Sort cell statuses and return the resulting nodes.
    nodes = cellStatusSort(containingIndices, polyBounds, concavePoints, query.boundingBox!);
    print("SubGridCell Time: ${stopwatch3.elapsed.inMilliseconds}");

    // Print the total time it took to execute the function.
    print("PGrid File Total Find Time: ${stopwatch.elapsed.inMilliseconds}");

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

// Function to get sub-grid cells recursively
  List<List<Node>> cellStatusSort(
      List<Tuple2<int, int>> containingIndices,
      List<List<LatLng>> polyBounds,
      List<List<LatLng>> concavePoints,
      Rectangle muniBoundingBox
      ) {
    List<List<Node>> nodes = [[],[]]; // Initialize a list to store the nodes in two lists: one for fully contained nodes and the second for intersecting nodes
    int countTopCellsFullyContained = 0; // Initialize a counter for fully contained top-layer cells
    int intersectingCells = 0; // Initialize a counter for intersecting top-layer cells

    // Loop through each cell that intersect the municipality bounding box.
    for (var cellIndex in containingIndices) {
      // Get the rectangle for the cell
      var rect = linearScalesRectangles[cellIndex.item1][cellIndex.item2];

      // Check if the rectangle is fully contained, intersecting or outside of the municipality
      var rectStatus = isFullyContained(rect, polyBounds, concavePoints, muniBoundingBox);

      // Get the block of nodes for the current cell
      var block = blockCollection[gridArray[cellIndex.item1][cellIndex.item2]]!;;

      // If the cell is fully contained, add all amenities nodes to the first list
      if (rectStatus == RectStatus.inside) {
        countTopCellsFullyContained++;
        nodes[0].addAll(block.where((node) => node.isAmenity));
      }
      // If the cell is intersecting, recursively divide the cell into sub-cells and add amenities nodes fully contained to the first list and other intersecting nodes to the second.
      else if (rectStatus == RectStatus.intersect) {
        intersectingCells++;
        List<List<Node>> subGridNodes = subGridPartition(cellIndex.item1, cellIndex.item2, polyBounds, concavePoints, muniBoundingBox);
        nodes[0].addAll(subGridNodes.first);
        nodes[1].addAll(subGridNodes.last);
      }
    }

    // Print out the number of fully contained and intersecting cells (debug)
    print("Amount of top-layer cells: ${containingIndices.length}");
    print("top-layer cells fully contained: ${countTopCellsFullyContained}");
    print("top-layer cells intersecting: ${intersectingCells}");

    // Return the nodes
    return nodes;
  }


// This function takes in the x and y indices of a cell in a grid, as well as some lists of boundary and point data.
// It partitions the cell into smaller rectangles, and determines which sub-cells are fully contained within the given boundaries.
// The function then determines which nodes within the cell fall within the fully contained sub-cells, and returns two lists of nodes:
// one for nodes within fully contained sub-cells, and another for nodes within intersecting sub-cells.
  List<List<Node>> subGridPartition (int xIndex, int yIndex,  List<List<LatLng>> polyBounds, List<List<LatLng>> concavePoints, Rectangle muniBoundingBox ){
    List<List<Node>> returnNodes = [[],[]];

    // Get the rectangle for the source cell, as well as the list of nodes within the cell.
    Rectangle sourceRect = linearScalesRectangles[xIndex][yIndex];
    List<Node> sourceCellNodes = blockCollection[gridArray[xIndex][yIndex]]!;

    // Determine the number of partitions to make for the cell.
    const int numberOfNodesPerCell = 250;
    int amountNodes = sourceCellNodes.length;
    int numberOfPartitions =  (amountNodes/numberOfNodesPerCell).ceil();

    // Determine the number of partitions in each direction, as well as the size of each partition.
    int latPartitions = (numberOfPartitions/2).ceil();
    int longPartitions = (numberOfPartitions/2).ceil();
    double latPartitionsSize = (sourceRect.height/latPartitions);
    double longPartitionsSize = (sourceRect.width/longPartitions);

    // Determine which sub-cells are fully contained within the boundaries, and which are just intersecting them.
    List<Rectangle> containedSubCells = [];
    List<Rectangle> intersectingSubCells = [];
    var top = sourceRect.top;
    var left = sourceRect.left;
    for(int i = 0 ; i<longPartitions ; i++){
      top = sourceRect.top;
      for(int y = 0 ; y<latPartitions ; y++){
        Rectangle subCell = Rectangle(left, top, longPartitionsSize, latPartitionsSize);
        var rectStatus = isFullyContained(subCell,polyBounds,concavePoints, muniBoundingBox);
        if(rectStatus == RectStatus.inside){
          containedSubCells.add(subCell);
        }else if (rectStatus == RectStatus.intersect){
          intersectingSubCells.add(subCell);
        }
        top+= latPartitionsSize;
      }
      left+=longPartitionsSize;
    }

    // Determine which nodes fall within fully contained and intersecting sub-cells.
    for (var node in sourceCellNodes) {
      bool found = false;
      if(node.isAmenity) {
        for (var cell in containedSubCells) {
          if (pointInRect(node, cell)) {
            returnNodes[0].add(node);
            found = true;
            break;
          }
        }
        if (!found) {
          //label to break out of loop
          secondInnerLoop:
          for (var cell in intersectingSubCells) {
           if (pointInRect(node, cell)) {
              {
                  returnNodes[1].add(node);
                  break secondInnerLoop;
                }
              }
            }
        }
      }
    }
    //return the two lists of nodes: fully contained nodes, and intersecting nodes.
    return returnNodes;
  }

  bool pointInRect (Node node, Rectangle rect){
    return (node.lon >= rect.left &&
        node.lon <= rect.left + rect.width &&
        node.lat >= rect.top &&
        node.lat <= rect.top + rect.height);
  }
  bool latLongInRect (LatLng point, Rectangle rect){
    return (point.longitude >= rect.left &&
        point.longitude <= rect.left + rect.width &&
        point.latitude >= rect.top &&
        point.latitude <= rect.top + rect.height);
  }

  List<List<LatLng>> getQueryPolyBoundaryPoints(MunicipalityRelation queryMuni){
    List<List<LatLng>> list = [];
    if(queryMuni.isMulti){

      for (var coordList in queryMuni.multiBoundaryCoords!) {
        list.add(coordList);
      }
    }
    else{
      list.add(queryMuni.boundaryCoords);
    }
    return list;
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
  

}enum RectStatus {inside, outside, intersect }