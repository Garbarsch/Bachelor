import 'dart:core';
import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';

import '../models/node.dart';
import '../models/relation.dart';
import 'jsonRepository.dart';

class GridFile {
  //gridArray is a two-dimensional grid/matrix of all cells of our grid
  //Each cell element holds a pointer to the bucket/block/data page that contains the data points of that cell
  //Multiple cells can point to the same block
  //The gridArray is also known as the directory.
  //
  // We ourselves must propose some grid scheme to best utilize the cells. Based on our predefined queries, we always query exactly 1
  // Municipality. Thus, it would make sense to align the cell scheme to that fact. We shall make each cell the size of the average municipality bounding box, such that
  // our range queries somewhat match the size of the cells in which we are most likely to benefit the most from our partition (if we partitioned large cells, we would have to search a lot
  // which makes the index less useful, if the cells are too small, we have to traverse a lot of cells to find our data)

  // Another thing to consider is disk utility, we want to match a capacity on disk pages aligning to "buckets" of cells
  // So as of this moment i see two possibilities - align by disk page size, or align by range query size. I dont rly understand the need to consider disk page size.. hmm
  late final List<List<int>> gridArray;

  //The linear scales 1-d arrays defines the partitions of each of the domains.
  //List<num> linearScalesLattitude;//partition on average muni lat
  //List<num> linearScalesLongitude;//partition on average muni long
  late final List<List<Rectangle>> linearScalesRectangles;

  //Collection of blocks - map is well suited for a small collection, but is it scalable? it is for now at least.
  late final Map<int, List<Node>> blockCollection; //b-tree or quadtree.

  late int blockCapacity; //Block/Bucket capacity; how many records (nodes) fits here - some value we "assume".
  late final Rectangle<num> bounds; //Bounding box of the country
  jsonRepository jRepo;

  GridFile(this.bounds, this.blockCapacity, this.jRepo); //data kan vi bare tage fra repo

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
  Map<int, List<Node>> initializeBlockCollection(List<List<Rectangle>>linearScalesRect){
    Map<int, List<Node>> blockMap = {};
    int blockCount = 0;
    int x = 0;
    int y = 0;
    for (var columnList in linearScalesRect) { //columns
      y=0;
      for (var rowElement in columnList) { //each row rectangle
        var cellNodes = jRepo.allNodesInRectangle(rowElement); //all nodes in that rectangle
        //if(blockMap.containsKey(blockCount)){ //if we have initialized a block of this key
         // if(blockMap[blockCount]!.length + cellNodes.length >= blockCapacity){ //if the block will not overflow
           // blockCount++; //count to get a new block id
         // }else{
            blockMap[blockCount] = cellNodes; //block will not overflow: add nodes (IF WE CHANGE THIS, WE HAVE TO DO AN ADD ALL HERE)
            gridArray[x][y] = blockCount; //add key to directory
        blockCount++;
          //}
       // }else{
          //blockMap[blockCount] = cellNodes; //if we have no blocks at this id, add a new list of the cell nodes
          //gridArray[i][y] = blockCount; //add key to directory
       // }
        y++;
      }
      x++;
    }
    return blockMap;
  }

  //partitions the country bounding box into a grid (one list of lists of rectangles) of rectangles based on average municipality size.
  List<List<Rectangle>> partitionLinearScales (double latPartitionSize, double longPartitionSize){
    //NOTE THAT RECTANGLES IN CS ARE UPSIDE DOWN - so we are index [0][0] is left bottom of the rect of denmark
    var latPartitions = (bounds.height/latPartitionSize).ceil();
    var longPartitions = (bounds.width/longPartitionSize).ceil();

    //print(latPartitions);
    //print(longPartitions);

    List<List<Rectangle>> scales = [];//List.generate(latPartitions, (index) => List.generate(longPartitions, (index) => null));

    var left = bounds.left;
    var top = bounds.top; //bottom is top in programming coordinates...


    //for each x cell
    for(int i = 0 ; i<longPartitions ; i++){
      top = bounds.top; //top is the bottom left corner
      scales.add([]); //add a new list
      for(int y = 0 ; y<latPartitions ; y++){ //for each cell up
        scales[i].add(Rectangle(left, top, longPartitionSize, latPartitionSize)); //add a new rectangle from left, with top (bottom) and width height
        top+= latPartitionSize; //as we start from bottom left corner, we have to add lat, so the bottom is always one larger
      }
      left+=longPartitionSize; //same here, but left to right
    }
    //print(scales.length);
    //print(scales[0].length);
    return scales;
  }


  Tuple2<double, double> averageMunicipalitySize(){
    double height = 0;
    double width = 0;
    for (var element in jRepo.relations) {
        height += element.boundingBox!.height;
        width += element.boundingBox!.width;
    }
    //average height, average width
    return Tuple2((height/(jRepo.relations.length)/6), (width/(jRepo.relations.length)/6));
  }


  //Given a range query (rectangle), find all intersecting cells of the grid
  //find the block pointers of the cells in the directory
  //return the blocks that match.
  List<Node> find (MunicipalityRelation query){
    Stopwatch stopwatch = new Stopwatch()..start();
    List<Node> nodes = [];

    List<Tuple2<int, int>> containingIndices = [];

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

    //Get the block pointers from the directory (gridFile) of the cells
    Set<int> blockKeys = {};
    containingIndices.forEach((element) {
      blockKeys.add(gridArray[element.item1][element.item2]);
    });

    var bounds = jRepo.getMunilist([query.name]);
    //grab all nodes of one or more each blocks.
    blockKeys.forEach((element) {
      //returns all nodes of the block that is amenity and within the polygon
      var blockNodes = blockCollection[element]!;
      for (var node in blockNodes) {
        if(node.isAmenity){
          if(pointInRect(node, query.boundingBox!)){
            for (int i = 0; i < bounds.length; i++) {
              if (jsonRepository.isPointInPolygon(LatLng(node.lat, node.lon), bounds[i])) {
                nodes.add(node);
                break;
              }
            }
          }
        }
      }
    });
    print("Grid File Find Time: ${stopwatch.elapsed.inMilliseconds}");
    return nodes;
   }

  bool pointInRect (Node node, Rectangle rect){
    return (node.lon >= rect.left &&
        node.lon <= rect.left + rect.width &&
        node.lat >= rect.top &&
        node.lat <= rect.top + rect.height);
  }
}