% Parameters
int: n_students;
int: n_days;
int: n_classes;
int: n_groups;
int: n_time_units_in_hour;
int: exclusion = -1;

set of int: Student = 1..n_students;
set of int: Class = 1..n_classes;
set of int: Group = 1..n_groups;
set of int: Day = 1..n_days;
set of int: Time = 0..n_time_units_in_hour * 24;
set of int: WorkTime = 0..max(Time)*n_days;
set of int: Preference = exclusion..max([student_prefers[s,g] | s in Student, g in Group]);

array[Student] of 0..5: student_break_importance;
array[Student, Group] of int: student_prefers;

array[Class] of Time: class_duration;
array[Class] of int: class_size;

array[Group] of Class: group_class;
array[Group] of Time: group_start;
array[Group] of Day: group_day;
array[Group, Group] of bool: groups_conflicts;

% helper function
function var int: ceil_div(var int: x, var int: y) =
  x div y + ((x mod y) > 0);
  

%przypisanie zajec dla studentów
set of int: biggerGroup = -1..n_groups;
array[Student,Class] of var biggerGroup: Enroll;
array[Student, Class] of var bool: student_attends_class;
constraint forall(s in Student, c in Class) (
  student_attends_class[s,c] = (sum(g in Group)( group_class[g] = c /\ student_prefers[s,g] > -1) > 0));

%constraint forall(i in Student, k in Group)(student_prefers[i,k] >0 -> student_prefers[i,Enroll[i,group_class[k]]] >= student_prefers[i,k]);
constraint forall(i in Student,j in Class)(student_attends_class[i,j]  -> group_class[Enroll[i,j]] = j );
constraint forall(i in Student,j in Class)(not student_attends_class[i,j] -> Enroll[i,j]=-1);

%new
constraint forall(i in Student,j in Class)(student_attends_class[i,j] -> student_prefers[i,Enroll[i,j]] != -1);


%nachodzenie grup
constraint forall(i in Student, j,k in Class) 
((student_attends_class[i,j] /\ student_attends_class[i,k] /\ j != k) ->  not groups_conflicts[Enroll[i,j],Enroll[i,k]]);


%licznosci grup
constraint forall(g in Group)(class_size[group_class[g]] >= sum(i in Student, j in Class)(Enroll[i,j]=g));


%preference disappointment
array[Student,Class] of var int: MostWanted;
constraint forall(i in Student,k in Group)(student_attends_class[i,group_class[k]] -> MostWanted[i,group_class[k]] >= student_prefers[i,k]);
constraint forall(i in Student,k in Group)(not student_attends_class[i,group_class[k]] -> MostWanted[i,group_class[k]] =0 );

array[Student,Class] of var int: Received;
constraint forall(i in Student,k in Group)(student_attends_class[i,group_class[k]] -> Received[i,group_class[k]] = student_prefers[i,Enroll[i,group_class[k]]]);
constraint forall(i in Student,k in Group)(not student_attends_class[i,group_class[k]] -> Received[i,group_class[k]] = 0);

array[Student] of var int: PrefDisa;
constraint forall(s in Student)(PrefDisa[s] = sum(j in Class)(MostWanted[s,j] - Received[s,j]));

%break disappointment
array[Student,Day] of var int: FirstDay;

constraint forall(s in Student,d in Day)(FirstDay[s,d] = min ([if d = group_day[Enroll[s,c]] /\ student_attends_class[s,c] then group_start[Enroll[s,c]] else 1000000 endif | c in Class]));

array[Student,Day] of var int: LastDay;
constraint forall(s in Student,d in Day)(LastDay[s,d] = max ([if d = group_day[Enroll[s,c]] /\ student_attends_class[s,c] then group_start[Enroll[s,c]] + class_duration[c] else 0 endif | c in Class]));

array[Student,Day] of var int: TimeInClass;
constraint forall(s in Student,d in Day)(TimeInClass[s,d] = sum(c in Class where d = group_day[Enroll[s,c]] )(class_duration[c]));

array[Student,Day] of var int: ClassDay;
constraint forall(s in Student,d in Day) (ClassDay[s,d] = sum(c in Class)(d = group_day[Enroll[s,c]]));


array[Student,Day] of var int: WastedDay;
constraint forall(s in Student,d in Day)(ClassDay [s,d] != 0 -> WastedDay[s,d] = max(ceil_div(LastDay[s,d]-FirstDay[s,d] - TimeInClass[s,d],n_time_units_in_hour),0));
constraint forall(s in Student,d in Day)(ClassDay [s,d] = 0 -> WastedDay[s,d] = 0);

array[Student] of var int: BreakDisa;
constraint forall(s in Student)(BreakDisa[s] = sum(d in Day)(WastedDay[s,d]));

%total disappointment

array[Student] of var int: TotalDisa;

constraint forall(s in Student)(TotalDisa[s] =  ceil_div(student_break_importance[s]*BreakDisa[s] + (10-student_break_importance[s]) * PrefDisa[s],10) );

array[Student] of var int: TotalDisaSqr;
constraint forall(s in Student)(TotalDisaSqr[s] = TotalDisa[s]*TotalDisa[s]);


var int: total_break_disappointment = sum(BreakDisa);
var int: total_preference_disappointment = sum(PrefDisa);
var int: objective = sum(TotalDisaSqr);



%where Enroll[s,c] != -1
%constraint forall(s in Student)(assignment[s] = {i | c in Class where Enroll[s,c] != -1} Enroll[s,c]);S


solve minimize(objective);
  
output 
["assignment = [" ++ join(",", ["{" ++ join(",", [show(Enroll[s,c]) |  c in Class where fix(Enroll[s,c] != -1) ]) ++ "}" | s in Student]) ++ "];\n"] ++

["total_break_disappointment = ", show(total_break_disappointment), ";\n"] ++
["total_preference_disappointment = ", show(total_preference_disappointment), ";\n"] ++
["objective = ", show(objective), ";\n"]





