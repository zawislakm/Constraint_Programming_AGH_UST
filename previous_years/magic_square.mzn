% Use this editor as a MiniZinc scratch book
include "alldifferent.mzn";
int: N;

array[1..N,1..N] of var 1..N*N: magic;

array[1..N] of var int: rows;
array[1..N] of var int: cols;
array[1..2] of var int: p;

constraint forall(i in 1..N)(rows[i] = sum([magic[i,j] | j in 1..N]));
constraint forall(j in 1..N)(cols[j] = sum([magic[i,j] | i in 1..N]));

constraint forall(j in 1..N)(alldifferent([magic[i,j] | i in 1..N])); 
constraint forall(i in 1..N)(alldifferent([magic[i,j] | j in 1..N]));

constraint forall(i,j in 1..N where i > j)(rows[i] = rows[j]);
constraint forall(i,j in 1..N where i > j)(cols[i] = cols[j]);

constraint (p[1] = sum([magic[i,i] | i in 1..N]));
constraint (p[2] = sum([magic[i,N-i+1] | i in 1..N]));

constraint (p[1] = p[2]);

constraint alldifferent([magic[i,j] |i,j in 1..N ]);
