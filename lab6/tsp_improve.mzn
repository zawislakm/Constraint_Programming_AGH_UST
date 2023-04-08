include "globals.mzn";

int: Nodes;
set of int: NUM = 1..Nodes;
array[NUM,NUM] of int: Dist;
array[NUM] of var NUM: route;
array[NUM] of 0..Nodes: initial_route;

var int: total_distance;

/*
TODO: 
- it's the same as `tsp_naive.mzn` but uses the `initial_route` like sudoku
  the zeros in `initial_route` mark variables that are "free" to be optimized
  the rest is fixed
*/
constraint alldifferent(route);
constraint (route[1]=1);

total_distance = sum(i in 2..Nodes)(Dist[route[i-1],route[i]])+ Dist[route[Nodes], route[1]];

constraint forall(i in NUM)(initial_route[i] != 0 -> initial_route[i] = route[i] );

solve minimize(total_distance);


output ["total distance: \(total_distance)\nroute = \(route)"];