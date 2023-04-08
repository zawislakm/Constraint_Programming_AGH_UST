% number of queens
int: N;
array[1..N] of var 1..N: rows;

constraint forall (i,j in 1..N where i<j) (rows[i] != rows[j]);
constraint forall (i,j in 1..N where i<j) (i + rows[i] != j + rows[j]);
constraint forall (i,j in 1..N where i<j) (i - rows[i] != j - rows[j]);



solve satisfy; 
  

output [ if fix(rows[j]) == i then "|Q" else "|_" endif ++
  if j == N then "\n" else "" endif | i,j in 1..N];
