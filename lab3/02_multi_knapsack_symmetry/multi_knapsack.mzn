include "at_most.mzn";
include "lex_less.mzn";


predicate knapsack(array[int] of var int: Weights, array[int] of var 0..1: Taken, int: Capacity) =
           sum(i in index_set(Weights))( Weights[i] * Taken[i]) <= Capacity
;

int: items_n;
int: knapsacks_n; 
int: capacity;

array[1..items_n] of int: values;
array[1..items_n] of int: weights;
array[1..knapsacks_n, 1..items_n] of var 0..1: taken;

constraint sum([taken[i,j] * weights[j] | i in 1..knapsacks_n, j in 1..items_n]) <= capacity*knapsacks_n; %sum lower than given
constraint sum([taken[i,j] * weights[j] | i in 1..knapsacks_n, j in 1..items_n]) >= 0; % bigger than 0
constraint sum([taken[i,j] * values[j] | i in 1..knapsacks_n, j in 1..items_n]) >= 0; % cost bigger than 0
constraint forall(i in 1..knapsacks_n) (sum([taken[i,j]*weights[j] | j in 1..items_n]) <= capacity); % weight
constraint forall (j in 1..items_n) (sum([taken[i,j] | i in 1..knapsacks_n]) <= 1); %taking itmes only once
constraint forall(i in 1..knapsacks_n-1) (lex_lesseq([taken[i, j] | j in 1..items_n],[taken[i+1, j] | j in 1..items_n]));%sorting in lex


solve maximize sum(i in 1..knapsacks_n, j in 1..items_n) (taken[i,j] * values[j]);

output [if j == 1 then show(i) ++ ") " else "" endif ++ show(taken[i,j]) ++ if j = items_n then "\n" else "" endif  | i in 1..knapsacks_n, j in 1..items_n] 
