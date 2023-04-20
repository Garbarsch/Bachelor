import 'dart:core';
import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';

import '../models/node.dart';
import '../models/relation.dart';
import 'jsonRepository.dart';

class GridFileFlex {
  late final List<List<int>> gridArray;

  //The linear scales 1-d arrays defines the partitions of each of the domains.
  //List<num> linearScalesLattitude;//partition on average muni lat
  //List<num> linearScalesLongitude;//partition on average muni long
  late final List<List<Rectangle>> linearScalesRectangles;

  //Collection of blocks - map is well suited for a small collection, but is it scalable? it is for now at least.
  late final Map<int, List<Node>> blockCollection; //b-tree or quadtree.

 //Block/Bucket capacity; how many records (nodes) fits here - some value we "assume".
  late int cellCapacity;
  late final Rectangle<num> bounds; //Bounding box of the country
  late List<MunicipalityRelation> relations;
  late List<Node> nodes;

  GridFileFlex(this.bounds, this.relations,this.nodes, this.cellCapacity); //data kan vi bare tage fra repo

  void initializeGrid(){
    print("Grid File Flex");
    var cellSize = averageMunicipalitySize();
    double height = cellSize.item1;
    double width = cellSize.item2;
    initializeScalesAndBlockCollection(height, width, cellCapacity);
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
        }/*else if(cellNodes.length < cellCapacity*0.80 && y-1 >= 0 && scales[x][y-1].width == cellRect.width && (block[blockCount-1]!.length + cellNodes.length < cellCapacity)){ //if the cell is less than 90 percent full


          var mergeRect = scales[x][y - 1];
          scales[x].removeAt(y);
                scales[x][y-1] = Rectangle(
                    cellRect.left, mergeRect.top, cellRect.width,
                    cellRect.height + mergeRect.height);
                y--;
        }*/
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
  List<List<Node>> find (MunicipalityRelation query){
    Stopwatch stopwatch = new Stopwatch()..start();
    List<List<Node>> nodes = [[],[]];

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
    print("Grid File Flex find intersecting cells time: ${stopwatch2.elapsed.inMilliseconds}");
    //Get the block pointers from the directory (gridFile) of the cells
    Set<int> blockKeys = {};
    containingIndices.forEach((element) {
      blockKeys.add(gridArray[element.item1][element.item2]);
    });

    var bounds = getMunilist([query.name]);
    //grab all nodes of one or more each blocks.
    blockKeys.forEach((element) {
      if(element != 0){
        var blockNodes = blockCollection[element]!;
        for (var node in blockNodes) {
          if(node.isAmenity){
            if(pointInRect(node, query.boundingBox!)){
                  nodes[1].add(node);

            }
          }
        }
      }
      //returns all nodes of the block that is amenity and within the polygon

    });
    //print("Grid File Find Time: ${stopwatch.elapsed.inMilliseconds}");
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


  bool pointInRect (Node node, Rectangle rect){
    return (node.lon >= rect.left &&
        node.lon <= rect.left + rect.width &&
        node.lat >= rect.top &&
        node.lat <= rect.top + rect.height);
  }
}