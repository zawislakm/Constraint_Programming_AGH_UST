include "alldifferent.mzn";

int: N;
set of int: indexes = 1..N;

array[indexes] of var indexes: rows;

constraint alldifferent(rows);
constraint alldifferent([rows[i] + i | i in indexes]);
constraint alldifferent([rows[i] - i | i in indexes]);


%me add
array[1..N, 1..N] of var bool: qb;
constraint forall(i in 1..N)(qb[i,rows[i]] = true); %prefactor to bool arrays

constraint forall ([qb[i,j] <-> rows[i]=j | i in 1..N, j in 1..N]);
array[int] of var bool: qb0 = array1d(qb);
array[int] of var bool: qb1 = [ qb[j,i] | i,j in 1..N ];
array[int] of var bool: qb2 = [ qb[i,j] | i in reverse(1..N), j in 1..N ];
array[int] of var bool: qb3 = [ qb[j,i] | i in 1..N, j in reverse(1..N) ];
array[int] of var bool: qb4 = [ qb[i,j] | i in 1..N, j in reverse(1..N) ];
array[int] of var bool: qb5 = [ qb[j,i] | i in reverse(1..N), j in 1..N ];
array[int] of var bool: qb6 = [ qb[i,j] | i,j in reverse(1..N) ];
array[int] of var bool: qb7 = [ qb[j,i] | i,j in reverse(1..N) ];

%prevent symmetries
constraint lex_lesseq(array1d(qb),array1d(qb0));
constraint lex_lesseq(array1d(qb),array1d(qb1));
constraint lex_lesseq(array1d(qb),array1d(qb2));
constraint lex_lesseq(array1d(qb),array1d(qb3));
constraint lex_lesseq(array1d(qb),array1d(qb4));
constraint lex_lesseq(array1d(qb),array1d(qb5));
constraint lex_lesseq(array1d(qb),array1d(qb6));
constraint lex_lesseq(array1d(qb),array1d(qb7));




solve satisfy; 


output [ if fix(rows[j]) == i then "|Q" else "|_" endif ++
  if j == N then "\n" else "" endif | i,j in 1..N];