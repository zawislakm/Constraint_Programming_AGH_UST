% Use this editor as a MiniZinc scratch book
int: N;
array[1..N] of var 0..N-1: music;

array[1..N-1] of var 1..N-1: difs;

constraint forall(i in 1..N-1)(difs[i] = abs(music[i]-music[i+1]));
constraint forall(i in 1..N-1)(difs[i] >0);
constraint forall(i in 1..N-1)(difs[i] <N);

solve satisfy;