include "distribute.mzn";

int: N ;
set of int: Indexes = 0..N-1;

array[Indexes] of var Indexes: magic;

constraint distribute(magic, array1d(Indexes, Indexes), magic);
% Alternatively:  
% constraint forall(i in Indexes)(
%   magic[i] = sum([magic[j] = i | j in Indexes])
% or even
%   magic[i] = count(magic, i)
% );

constraint forall([magic[i-1] = count_eq(magic,i-1) | i in 1..N]);
constraint sum(magic) = N; 
constraint sum([magic[i-1] * (i-1) | i in 1..N]) = N;

solve satisfy;
  
output [ "magic sequence = ", show(magic),";\n",];
