include "globals.mzn";
include "alldifferent.mzn";

int: Nodes;
set of int: NUM = 1..Nodes;
array[NUM,NUM] of int: Dist;
array[NUM] of var NUM: route;

var int: total_distance;

/*
TODO: 
- the cities in the route should not repeat
- the first city in the route should be fixed to 1
- calculate the total distance based on the route
*/

constraint alldifferent(route);
constraint (route[1]=1);

constraint total_distance = sum(i in 2..Nodes)(Dist[route[i-1],route[i]])+ Dist[route[Nodes], route[1]];
solve minimize total_distance;


output ["total distance: \(total_distance)\nroute = \(route)"];