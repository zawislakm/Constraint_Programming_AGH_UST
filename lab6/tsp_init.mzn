include "globals.mzn";

int: Nodes;
set of int: NUM = 1..Nodes;
array[NUM,NUM] of int: Dist;
array[NUM] of var NUM: route;

var int: total_distance;

/*
TODO: 
- it's exactly the same as `tsp_naive.mzn` but just "satisfies" the constraints
*/

constraint alldifferent(route);
constraint (route[1]=1);
total_distance = sum(i in 2..Nodes)(Dist[route[i-1],route[i]])+ Dist[route[Nodes], route[1]];

solve satisfy;

output ["total distance: \(total_distance)\nroute = \(route)"];