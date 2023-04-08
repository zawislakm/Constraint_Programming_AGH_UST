include "diffn.mzn";
include "cumulative.mzn";

int: nr;   % number of reclaimers
           % number of rails = nr for stages A,B,C,D,E
           % number of rails = (nr + 1) div 2 for stage F
set of int: RECLAIMER = 1..nr;
bool: stageF; % is this stage F data

int: ns; % number of stockpiles
set of int: STOCKPILE = 1..ns;
array[STOCKPILE] of int: size; % size in 10000 tonnes
array[STOCKPILE] of SHIP: ship; % which ship carries stockpile
 
int: maxtime; % time considered
set of int: TIME = 0..maxtime;          % x na wykresie ze zdjecia

int: nsh; % number of ships
set of int: SHIP = 1..nsh;
array[SHIP] of TIME: arrival; % when ship arrives in port

int: len; % length of pad
set of int: POSITION = 0..len;         % y na wykresie ze zdjecia

int: stack_time; % time required to stack a single unit (the same unit as in `size`)
int: reclaim_time; % time required to reclaim a single unit (the same unit as in `size`)
int: reclaim_speed; % how much time is required to move by one unit by reclaimer

array[STOCKPILE] of var POSITION: westend;
array[STOCKPILE] of var POSITION: eastend;
array[STOCKPILE] of var TIME: stack;
array[STOCKPILE] of var TIME: endstack;
array[STOCKPILE] of var TIME: reclaim;
array[STOCKPILE] of var TIME: finished;
array[STOCKPILE] of var RECLAIMER: which;

% Go crazy here

% Stage A - Packing Problem
% Two stockpiles can't overlap in "spacetime"

% 1) what's the relation between endstack and stack times
% 2) what's the relation between reclaim and endstack times
% 3) what's the relation between finished and reclaim times
% 4) how much time the stockpiles spend on the pad?
%    - create a new array and store this info - it will be useful :)
% 5) what's the relation between eastend and westend offsets // poczatek i koniec padu do ladowania chyba
% 6) packing problem
%    a) stockpiles should not overlap in "spacetime", treat them as rectangles
%    b) stockpiles can't use more space than there is available
%    c) we can't go beyond the time limit
 
constraint forall(i in STOCKPILE)(stack[i]<=endstack[i]); %(1
constraint forall(i in STOCKPILE)(endstack[i] = stack[i] + size[i] * stack_time); %(1

constraint forall(i in STOCKPILE)(endstack[i] <= reclaim[i]); %(2

constraint forall(i in STOCKPILE)(reclaim[i] <= finished[i]); %(3
constraint forall(i in STOCKPILE)(finished[i] = reclaim[i] + size[i] * reclaim_time); %(3

array[STOCKPILE] of var TIME: dwelltime; %(4
constraint forall(i in STOCKPILE)(dwelltime[i] = (reclaim[i]- endstack[i]));  % time in magazine


constraint forall(i in STOCKPILE)(eastend[i] = westend[i] + size[i]); %(5 
constraint forall(i in STOCKPILE) (westend[i] >= 0 /\ westend[i] <= len - size[i]);
  
 %(6
 constraint forall(i in STOCKPILE)(finished[i] <= maxtime); % keeping in time
 constraint forall(i in STOCKPILE)(westend[i] + size[i] <= len);  %keeping in range
 

constraint forall(i,j in STOCKPILE where i > j) (finished[i] <= stack[j] \/ finished[j] <= stack[i]  \/ westend[i] >= westend[j] + size[j] \/ westend[j] >= westend[i] + size[i]); % not overlaping squares

 
  
% Stage B 
% Two stockpiles reclaimed by the same reclaimer do not overlap in time
%
% Tip: write your first custom predicate, i.e.
% predicate not_overlap(var STOCKPILE: s1, var STOCKPILE: s2) =
% <something something> ;

predicate not_overlap(var STOCKPILE: i, var STOCKPILE: j) = let {var int: time = abs(westend[i]-westend[j])*reclaim_speed} in
finished[i] + time <= reclaim[j] \/ finished[j] + time <= reclaim[i]; %not overlaping during time

constraint forall(i,j in STOCKPILE where i > j) (which[i]==which[j] -> not_overlap(i,j)); % not overlaping during loading
constraint forall(i in STOCKPILE) (which[i] >=1 /\ which[i] <= nr); % reclamirm number
  

    
% Stage C
% 1) no stockpile can be reclaimed onto a ship before the arrival time of the ship
% 2) also no two stockpiles can be reclaimed onto the same ship at the same time. Make sure these reclaims do not overlap in time.
% TIP: reuse your "not_overlap" predicate

constraint forall(i in STOCKPILE)(reclaim[i] >= arrival[ship[i]]); %(1
constraint forall(i,j in STOCKPILE where i > j) (ship[i] == ship[j] -> not_overlap(i,j)); %2



% Stage D
% Add constraints to your model to ensure that if a reclaimer finishes reclaiming a stockpile with westend at x and then has to start reclaiming a stockpile with westend at y there is at least |y − x| ∗ reclaim speed time between these two events.
% TIP: just make your "not_overlap" predicate smarter
% TIP: you can introduce local variables in the constraints/predicates
% let {
%  <local variables>
% } in <then something>

%zostalo wykonane w predykacie


% Stage E
% Add a definition of the objective to your model and change the model to minimize this value.
% You may well need to significantly change your search strategy to get good solutions for the objective.

array[SHIP] of var TIME: lastLeave;

constraint forall(i in STOCKPILE)(lastLeave[ship[i]] = max(finished[i],lastLeave[ship[i]]));

% TIP: definetely change the line below
var int: obj;
constraint obj = sum([lastLeave[i] - arrival[i] | i in SHIP]);

% TIP: you may add some search annotations

solve :: int_search(finished, first_fail, indomain_median, complete) minimize obj;


% Stage F
% Add constraints in your model so that the two reclaimers on rail i numbered 2i − 1 and 2i for i ∈ 1..nr div 2 remain so the western one 2i − 1 is never east of the eastern one 2i. Note they can legitimately be in the same position (this is for simplicity, its not very real). 
% TIP: do some "channeling" and model reclaimers' positions explicitely with a new array of variables as below
% 1) when reclaiming, reclaimers position should equal to the westend of the stockpile being reclaimed
% 2) otherwise they should not move faster than the `reclaim_speed` allows
array[RECLAIMER, TIME] of var POSITION: reclaimers_positions;

% When stage F is not active, just make it full of 0 as it doesn't matter
constraint not stageF -> forall(r in RECLAIMER, t in TIME)( reclaimers_positions[r,t] == 0);



set of int: NUMrails = 1..(nr div 2); 
constraint stageF -> forall(r in NUMrails,t in TIME)( reclaimers_positions[2*r-1,t] <= reclaimers_positions[2*r,t]); 
\

constraint stageF -> forall(i in STOCKPILE,t in TIME)((t >= stack[i] /\ t <= finished[i]) -> reclaimers_positions[which[i],t] = westend[i]); %seting reclaimer to westside

constraint stageF -> forall(i in STOCKPILE,t1, t2 in TIME) (abs(reclaimers_positions[which[i],t1] -reclaimers_positions[which[i],t2]) <= reclaim_speed * abs(t1-t2));





% don't change the output
output 
["westend  = ", show(westend), ";\n"] ++
["eastend  = ", show(eastend), ";\n"] ++
["stack    = ", show(stack), ";\n"] ++
["endstack = ", show(endstack), ";\n"] ++
["reclaim  = ", show(reclaim), ";\n"] ++
["finish   = ", show(finished) , ";\n"] ++
["which    = ", show(which), ";\n"] ++
["obj = ",show(obj), ";\n"]
;
