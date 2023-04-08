

int: N;

array[1..N+2,1..N+2] of var bool: life;

constraint forall(i in 1..N+2)(life[1,i] = 0);
constraint forall(i in 1..N+2)(life[N+2,i] = 0);
constraint forall(i in 1..N+2)(life[i,1] = 0);
constraint forall(i in 1..N+2)(life[i,N+2] = 0);

var int: sumAlive;

array[1..N,1..N] of var int: alive;

constraint forall(i,j in 1..N)(alive[i,j] = life[i,j] + life[i+1,j] + life[i+2,j]+life[i+2,j+1]+life[i+2,j+2]+life[i+1,j+2]+life[i,j+2]+life[i,j+1]);

constraint forall(i,j in 1..N)(alive[i,j] = 2);


constraint (sumAlive = sum([life[i,j] | i,j in 1..N+2]));

solve maximize(sumAlive);