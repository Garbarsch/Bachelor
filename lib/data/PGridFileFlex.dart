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

class PGridFileFlex {
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

  PGridFileFlex(this.bounds, this.relations,this.nodes); //data kan vi bare tage fra repo


  void initializeGrid(){
    print("PGridFile Flex");
    var cellSize = averageMunicipalitySize();
    double height = cellSize.item1;
    double width = cellSize.item2;
    initializeScalesAndBlockCollection(height, width, 4000);
  }

//okay so as in the paper (p.15) we must define splitting and merging policies, that is, for
// - the two-disk-access principle for point queries,
// - efficient processing of range queries in large linearly ordered domains and so on (p.5)
  //So we our grid partitioning here goes from a starting point - the average muni size - then if the cell is above a block capacity, we split, if it is below we merge.
  //OKAY - another thing then, cell capacity vs. block capacity, two thresholds, the block capacity will be given, but the cell capacity we must analyze and find the most appropriate.
  //for each x cell
  void initializeScalesAndBlockCollection(double latPartitionSize, double longPartitionSize, int cellCapacity){
    var latPartitions = (bounds.height/latPartitionSize).ceil();
    var longPartitions = (bounds.width/longPartitionSize).ceil();

    List<List<Rectangle>> scales = [];//List.generate(latPartitions, (index) => List.generate(longPartitions, (index) => null));

    var left = bounds.left;
    var top = bounds.top; //bottom is top in programming coordinates...

    //for each x cell
    for(int i = 0 ; i<longPartitions ; i++){
      //gridArray.add([]);
      top = bounds.top; //top is the bottom left corner
      scales.add([]); //add a new list
      for(int y = 0 ; y<latPartitions ; y++){ //for each cell up
        scales[i].add(Rectangle(left, top, longPartitionSize, latPartitionSize)); //add a new rectangle from left, with top (bottom) and width height
        top+= latPartitionSize; //as we start from bottom left corner, we have to add lat, so the bottom is always one larger
      }
      left+=longPartitionSize; //same here, but left to right
    }
    flexGrid(cellCapacity, longPartitions, latPartitions, scales);

  }
  void flexGrid(int cellCapacity, int longPartitions, int latPartitions,  List<List<Rectangle>> scales){
    Map<int,List<Node>> block = {};
    gridArray = [];
    int longPartitionsInner = longPartitions;


    int blockCount = 1;
    for(int x = 0 ; x<longPartitionsInner ; x++){ //latPartitions
      gridArray.add([]);
      bool ySplit = true;
      for(int y = 0 ; y<scales[x].length ; y++){ //for each cell up

        var cellRect = scales[x][y];
        var cellNodes = allNodesInRectangle(cellRect);

        if(cellNodes.length == 0){ //if there are no cells in the node, we dont want to save and search through an empty cell.
          scales[x].removeAt(y);
          y--;
        }else if(cellNodes.length > cellCapacity){
          if(!ySplit && scales.length-1 > x && scales[x+1].length>=y){
            //We check whether the x values is less than the last element, as we must check if we can insert a new cell in the next list.
            //And whether we can insert the new cell between or at the end of the next list.
            var rect1 = Rectangle(cellRect.left, cellRect.top, cellRect.width/2, cellRect.height);
            var rect2 = Rectangle(cellRect.left + (cellRect.width/2), cellRect.top, cellRect.width/2, cellRect.height);
            scales[x][y] = rect1;
            if(x+1 == scales.length){ //We check if there is another x element after, if not we must create a new x-list.
              scales.add([]);
              longPartitionsInner++;
            }
            scales[x+1].add(rect2);
            //we go one back to check the if one of the cells we just created are still above the cell-capacity.
            y--;
            ySplit  = true;

          }else{//ySplit
            var rect1 = Rectangle(cellRect.left, cellRect.top, cellRect.width, cellRect.height/2);
            var rect2 = Rectangle(cellRect.left, cellRect.top+(cellRect.height/2), cellRect.width, cellRect.height/2);
            scales[x][y] = rect1;
            scales[x].insert(y+1, rect2);
            y--;
            ySplit = false;
          }
        }
        else{
          block[blockCount] = cellNodes;
          gridArray[x].add(blockCount);
          blockCount++;
        }
      }
    }
    blockCollection = block;
    linearScalesRectangles = scales;
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
    return Tuple2((height / relations.length) / 4, (width / relations.length) / 4);
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
    int subGridCount = 0;

    // Loop through each cell that intersect the municipality bounding box.
    for (var cellIndex in containingIndices) {
      // Get the rectangle for the cell
      var rect = linearScalesRectangles[cellIndex.item1][cellIndex.item2];

      // Get the block of nodes for the current cell
      List<Node> block = List.from(blockCollection[gridArray[cellIndex.item1][cellIndex.item2]]!.where((node) => node.isAmenity));

      if(block.length > 4){
      // Check if the rectangle is fully contained, intersecting or outside of the municipality
      
      var rectStatus = isFullyContained(rect, polyBounds, concavePoints, muniBoundingBox);


      //print("Top-layer-cell amount nodes ${block.length}");

      // If the cell is fully contained, add all amenities nodes to the first list
      if (rectStatus == RectStatus.inside) {
        countTopCellsFullyContained++;
        nodes[0].addAll(block);
      }
      // If the cell is intersecting, recursively divide the cell into sub-cells and add amenity nodes fully contained to the first list and other intersecting nodes to the second.
      else if (rectStatus == RectStatus.intersect) {
        intersectingCells++;
        if(block.length > 100){
          subGridCount++;
          List<List<Node>> subGridNodes = subCellPartitionRecursive(rect, block, polyBounds, concavePoints, muniBoundingBox);
          nodes[0].addAll(subGridNodes.first);
          nodes[1].addAll(subGridNodes.last);
        }else{
          nodes[1].addAll(block);
        }
      }
      }else{
        nodes[1].addAll(block);
      }

    }

    // Print out the number of fully contained and intersecting cells (debug)
    print("Amount of top-layer cells: ${containingIndices.length}");
    print("top-layer cells fully contained: ${countTopCellsFullyContained}");
    print("top-layer cells intersecting: ${intersectingCells}");
    print("Top layer cells called subgrid: ${subGridCount}");

    // Return the nodes
    return nodes;
  }

  //Partitions the cell into smaller rectangles recursively - 4 at a time -, and determines which sub-cells are fully contained within the given boundaries.
  // The function then determines which nodes within the cell fall within the fully contained sub-cells, and returns two lists of nodes:
  // one for nodes within fully contained sub-cells, and another for nodes within intersecting sub-cells.
  List<List<Node>> subCellPartitionRecursive(
      Rectangle sourceRect,
      List<Node> sourceCellNodes,
      List<List<LatLng>> polyBounds,
      List<List<LatLng>> concavePoints,
      Rectangle muniBoundingBox) {

    // Initialize the variables to store the nodes in the sub-cells
    List<List<Node>> returnNodes = [[],[]];

    // Initialize lists to store sub-cells that are fully contained or intersecting the source rectangle
    List<Rectangle> containedSubCells = [];
    List<Rectangle> intersectingSubCells = [];
    List<List<Node>> intersectingSubcellNodes = [];

    List<List<Node>> rectangleNodes = [[],[],[],[]];
    // Define the sub-cells of the source rectangle
    var rectangles = [Rectangle(sourceRect.left, sourceRect.top, sourceRect.width/2, sourceRect.height/2),
      Rectangle(sourceRect.left, sourceRect.top+(sourceRect.height/2), sourceRect.width/2, sourceRect.height/2),
      Rectangle(sourceRect.left+(sourceRect.width/2), sourceRect.top, sourceRect.width/2, sourceRect.height/2),
      Rectangle(sourceRect.left+(sourceRect.width/2), sourceRect.top+(sourceRect.height/2), sourceRect.width/2, sourceRect.height/2)  ];

    for(var node in sourceCellNodes){
      for (int i = 0 ; i<rectangles.length ; i++) {
        if(pointInRect(node, rectangles[i])){
          rectangleNodes[i].add(node);
          break;
        }
      }
    }

    // Classify the sub-cells as fully contained or intersecting the municipality polygon
    for (int i = 0 ; i<rectangles.length ; i++) {
      if(rectangleNodes[i].length > 4){ //We do not want to check the four corners of a rectangles if there is less than 4 nodes in the cell anyway
        var rectStatus =  isFullyContained(rectangles[i], polyBounds, concavePoints, muniBoundingBox);
        if(rectStatus == RectStatus.inside){
          returnNodes[0].addAll(rectangleNodes[i]);
          //containedSubCells.add(rectangles[i]);
        }else if(rectStatus == RectStatus.intersect){
          intersectingSubCells.add(rectangles[i]);
          //intersectingSubcellNodes.add([]);
        }
      }else{
        returnNodes[1].addAll(rectangleNodes[i]);
      }

    }
    for (int i = 0 ; i<intersectingSubCells.length ; i++) {
      if(rectangleNodes[i].length > 100){

        var subPartitions = subCellPartitionRecursive(intersectingSubCells[i], rectangleNodes[i], polyBounds, concavePoints, muniBoundingBox);
        returnNodes[0].addAll(subPartitions[0]);
        returnNodes[1].addAll(subPartitions[1]);
      }else{
        returnNodes[1].addAll(rectangleNodes[i]);
      }
    }


/*
    // Iterate through the nodes in the source cell and assign them to the sub-cells
    for (var node in sourceCellNodes) {
      bool found = false;
        // Check if the node is in a fully contained sub-cell
        for (var cell in containedSubCells) {
          if (pointInRect(node, cell)) {
            returnNodes[0].add(node);
            found = true;
            break;
          }
        }
        // If the node is not in a fully contained, add it to the intersecting sub-cell that contains it
        if (!found) {
          for (int i = 0 ; i< intersectingSubCells.length ; i++) {
            if (pointInRect(node, intersectingSubCells[i])) {
              intersectingSubcellNodes[i].add(node);
              //returnNodes[1].add(node);
              break;
            }
          }
        }

    }*/

    // Recursively partition the intersecting sub-cells if they contain more than X nodes
    /*for (int i = 0 ; i<intersectingSubCells.length ; i++) {
      if(intersectingSubcellNodes[i].length > 400){
        print("HAlllooo");
        var subPartitions = subCellPartitionRecursive(intersectingSubCells[i], intersectingSubcellNodes[i], polyBounds, concavePoints, muniBoundingBox);
        returnNodes[0].addAll(subPartitions[0]);
        returnNodes[1].addAll(subPartitions[1]);
      }else{
        returnNodes[1].addAll(intersectingSubcellNodes[i]);
      }
    }*/

    // Return the nodes in the sub-cells
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