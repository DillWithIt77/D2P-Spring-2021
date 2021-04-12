set TOYDATA;
table ToyData IN "ODBC" "toy_dataset.csv"
	#[Group_1_1], Group_1_2, Group_1_3, Group_2_1, Group_2_2, Group_2_3, Group_2_4, Group_3_1, Group_3_2, Group_3_3, Result;
read table ToyData;

param N > 0; #number of samples
param B > 0; #number of leaf nodes
param F > 0; #number of features
param G > 0; #number of groups
param K > 0; #number of branch nodes
param C > 0; #weight to account for imbalance
# maybe param a, maybe read in data

var c{0..B, 0..N} >= 0;
var v{0..G, 0..K} >= 0;
var z{0..F, 0..K} >= 0; 

maximize Correct_Classification:
sum{i1 in pos_I, b1 in pos_b} c[b1, i1] 
+ C*sum{i2 in neg_I, b2 in neg_b} c[b2, i2];

subject to 1_branch_feature {i in 0..K}:
sum {t in 0..G} v[t, i] = 1

subject to feature_in_group {i in 0..F, j in 0..K}:
z[i, j] <= v[ ,j]

subject to left_split {i in 0..N, b in 0..B, k in 0..K}:
c[b, i] <= sum{j in 0..F} a[j, i]*z[j, k]
#need to account for Left splits

subject to right_split {i in 0..N, b in 0..B, k in 0..K}:
c[b, i] <= 1 - (sum{j in 0..F} a[j, i]*z[j, k])
#need to account for Right splits

subject to 1_assigned_node {i in 0..N}:
sum {b in 0..B} c[b, i] = 1 