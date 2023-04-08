include "alldifferent.mzn";
% parameters
int: nodesNumber;
array [1..nodesNumber, 1..nodesNumber] of bool: edges;
 
% decision variables
var 1..nodesNumber: colorsNumber;
array [1..nodesNumber] of var 1..nodesNumber: nodes;

% constraints
constraint colorsNumber = max(nodes);
constraint forall (i,j in 1..nodesNumber where i < j /\ edges[i,j])(nodes[i] != nodes[j]);

%previous task
constraint forall([nodes[i] > 0 | i in 1..nodesNumber]);  
constraint forall([nodes[i] <= nodesNumber | i in 1..nodesNumber]); 
constraint forall(i in 1..nodesNumber, j in 1..nodesNumber)(if edges[i,j] = true then nodes[i] != nodes[j] else true endif);   
 %constraint nodes[1]=1;

%me add clique
int: minColorsNumber;
array [1..minColorsNumber] of int: maxClique;
%constraint forall(i in 1..minColorsNumber)(alldifferent([nodes[maxClique[i]]]));
constraint forall([nodes[maxClique[i]] = i | i in 1..minColorsNumber]);
constraint alldifferent([nodes[maxClique[i]] | i in 1..minColorsNumber]);

% goal
solve minimize colorsNumber;

% output
output [show(colorsNumber), " colors\n",] ++
       [show(nodes[i]) ++ " " | i in 1..nodesNumber]