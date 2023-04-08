include "diffn.mzn";
include "cumulative.mzn";


% Parameters
%%%%%%%%%%%
int: n;                      % How many squares do we have?
set of int: SQUARES = 1..n;  % Set of the available squares

% Variables
%%%%%%%%%%%
var n..sum([i | i in SQUARES]): height;    % height of the container
var n..sum([i | i in SQUARES]): width;     % width of the conainer
var sum([pow(i,2) | i in SQUARES])..sum([i | i in SQUARES])*n: area = height * width; % container's area
array[SQUARES] of var 0..sum([i | i in 2..n]): x; % squares' coordinates in the container
array[SQUARES] of var 0..sum([i | i in 2..n]): y; % squares' coordinated in the container
  
% Constraints 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Constraint 1: Squares should fit inside the container
constraint forall(i in SQUARES)(x[i]+i <= width);
constraint forall(i in SQUARES)(y[i]+i <= height);


% Constraint 2: Squares should not overlap
%constraint forall(i,j in SQUARES where i > j)(x[i] + i <= x[j] \/ y[i] >= y[j]+j \/ x[j] + j <= x[i] \/ y[j] >= y[i]+i);

array[SQUARES] of 1..n: sizes = [i | i in SQUARES];
constraint diffn(x, y, sizes, sizes);

%redundant constraints
constraint width >= height;
constraint cumulative(x, [i | i in SQUARES],[i | i in SQUARES], height);
constraint cumulative(y,[i | i in SQUARES],[i | i in SQUARES],width);

% Goal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solve ::  int_search(SQUARES, first_fail,indomain_max) minimize area; 
% pack bigger first

% Boring output  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output [ show(i) ++ " > (" ++ show(x[i]) ++ "," ++ show(y[i]) ++ ")\n" | i in 1..n] ++
  ["area = " ++ show(width) ++ " * " ++ show(height) ++ " = " ++ show(area)];