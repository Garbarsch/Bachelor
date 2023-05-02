import 'dart:core';
import 'dart:math';
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

class PGridFile1Flex {
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

  PGridFile1Flex(this.bounds,this.relations,this.nodes ); //data kan vi bare tage fra repo

  void initializeGrid(){
    print("PGridFile1 Flex");
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
    List<List<LatLng>> polyBounds = getMunilist([query.name]);
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
    // print("PGrid File1 find intersecting cells time: ${stopwatch2.elapsed.inMilliseconds}");

    // Create a stopwatch to measure the time it takes to sort cell statuses.
    Stopwatch stopwatch3 = new Stopwatch()..start();

    // Sort cell statuses and return the resulting nodes.
    nodes = cellStatusSort(containingIndices, polyBounds, concavePoints, query.boundingBox!);
    //print("cellStatusSort Time: ${stopwatch3.elapsed.inMilliseconds}");

    // Print the total time it took to execute the function.
    // print("PGrid File1 Total Find Time: ${stopwatch.elapsed.inMilliseconds}");

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
    //print("Get concave points time: ${stopwatch.elapsed.inMilliseconds}");
    return concavePoints;
  }


  List<List<Node>> cellStatusSort(List<Tuple2<int, int>> containingIndices, List<List<LatLng>> polyBounds, List<List<LatLng>> concavePoints, Rectangle muniBoundingBox) {
    List<List<Node>> nodes = [[],[]];
    //print("Amount of top-layer cells: ${containingIndices.length}");
    int countTopCellsFullyContained = 0;
    int countTopCellsOutsidePolygon = 0;
    int intersectingCells = 0;

    for (var cellIndex in containingIndices) {
      var rect = linearScalesRectangles[cellIndex.item1][cellIndex.item2];
      var rectStatus = isFullyContained(rect, polyBounds, concavePoints, muniBoundingBox);

      var block = blockCollection[gridArray[cellIndex.item1][cellIndex.item2]]!;

      if (rectStatus == RectStatus.inside) {
        countTopCellsFullyContained++;
        nodes[0].addAll(block.where((node) => node.isAmenity));
      } else if (rectStatus == RectStatus.intersect) {
        intersectingCells++;
        nodes[1].addAll(block.where((node) {
          if (!node.isAmenity) {
            return false;
          } else{
            return true;
          }
        }));
      }else{
        countTopCellsOutsidePolygon++;
      }

    }
    print("Cells in boundingbox but not polygon: ${countTopCellsOutsidePolygon}" );
    print("top-layer cells fully contained: ${countTopCellsFullyContained}");
    //print("top-layer cells intersecting: ${intersectingCells}");

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