int: nodesNumber; 
array[1..nodesNumber, 1..nodesNumber] of bool: edges;  


array[1..nodesNumber] of var int: nodes; 
var int: colorsNumber = max([nodes[i] | i in 1..nodesNumber]);  


constraint forall([nodes[i] > 0 | i in 1..nodesNumber]); 
constraint forall([nodes[i] <= nodesNumber | i in 1..nodesNumber]); 
constraint forall(i in 1..nodesNumber, j in 1..nodesNumber)(if edges[i,j] = true then nodes[i] != nodes[j] else true endif);
 
constraint nodes[1] = 1; 


solve minimize colorsNumber; 


output [show(colorsNumber), " colors\n",] ++
       [show(nodes[i]) ++ " " | i in 1..nodesNumber]
