include "cumulative.mzn";



array[1..N, 1..N] of var int: puzzle; 


array[int,int] of int: board; 
set of int: PuzzleRange = index_set_1of2(board); 
int: N = max(PuzzleRange); 
int: S = floor(sqrt(N)); 

constraint assert(index_set_2of2(board) = PuzzleRange, "The board should be a square array");  
constraint assert(S * S == N, "The board size should be a square of a natural number"); 
constraint assert(min(board) = 0, "The board should contain at least one empty space and no negative values"); 
constraint assert(max(board) <= N, "The board shouldn't contain values bigger than the board size"); 

constraint forall(i in 1..N, j in 1..N)(if board[i,j] != 0 then puzzle[i,j] = board[i,j] else true endif); 
constraint forall([puzzle[i,j] > 0 | i in 1..N, j in 1..N]); 
constraint forall([puzzle[i,j] <= N | i in 1..N, j in 1..N]); 
constraint forall(j in 1..N)(alldifferent([puzzle[i,j] | i in 1..N])); 
constraint forall(i in 1..N)(alldifferent([puzzle[i,j] | j in 1..N])); 
constraint forall(i in 1..S, j in 1..S) (alldifferent([puzzle[(i - 1) * S + k , (j - 1) * S + l] | k in 1..S, l in 1..S]));



solve satisfy;



output [ show(puzzle[i,j]) ++ " " ++
  if j mod S == 0 then " " else "" endif ++ if j == N /\ i != N then
  if i mod S == 0 then "\n\n" else "\n" endif else "" endif
    | i,j in PuzzleRange ] ++ ["\n"];
