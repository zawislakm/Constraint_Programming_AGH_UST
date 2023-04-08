int: N;
array[1..N] of var 0..N: magic;
       
constraint forall([magic[i] = count_eq(magic,i-1) | i in 1..N]);
  
solve satisfy;
  
output [ "magic sequence = ", show(magic),";\n"];
