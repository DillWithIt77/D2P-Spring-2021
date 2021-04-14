set Item;

param A{Item}>=0;
param B_1{Item}>=0;
param C_1{Item}>=0;
param D{Item}>=0;
param E{Item}>=0;
param F_1{Item}>=0;
param G_1{Item}>=0;
param H{Item}>=0;
param I_1{Item}>=0;
param J{Item}>=0;
param Result{Item}>=-1;

set pos_I;
set pos_b;
set neg_I;
set neg_b;

set POS_SCHOOL; #get this from table read
set NEG_SCHOOL; #get this from table read
set BRANCH_NODES; #get from set describing tree structure? 
set POS_LEAF_NODES; #define in .dat file
set NEG_LEAF_NODES; #defin in .dat file

param N > 0; #number of samples
param B > 0; #number of leaf nodes
set F; #number of features
param K > 0; #number of branch nodes
param C > 0; #weight to account for imbalance
set G; #number of groups
param a{F, 0..N}>= 0; #unsure of how to define this. Reading this in from a table? 
param member_check{i in F, j in G} >= 0; #defined in .dat
# maybe param a, maybe read in data

var c_pos{i in POS_LEAF_NODES, j in POS_SCHOOL} >= 0;
var c_neg{i in NEG_LEAF_NODES, j in NEG_SCHOOL} >= 0;
var v{g in G, k in BRANCH_NODES} >= 0;
var z{f in F, i in BRANCH_NODES} >= 0; 

maximize Correct_Classification:
sum{i1 in POS_LEAF_NODES, j1 in POS_SCHOOL} c_pos[i1, j1] 
+ C*sum{i2 in NEG_LEAF_NODES, j2 in NEG_SCHOOL} c_neg[i2, j2];

subject to 1_branch_feature {k in BRANCH_NODES}:
sum {i in G} v[i, k] = 1;

subject to feature_in_group {j in BRANCH_NODES, k in F, h in G}:
member_check[k, h] = 1 ==> z[k, j] <= v[h, j];

#subject to feature_in_group {j in BRANCH_NODES, k in feats, h in 0..G}:
#z[k,j] <= v[k,h,j];

subject to left_split {i in 0..N, b in 0..B, k in BRANCH_NODES}:
c_pos[b, i] <= sum{j in F} a[j, i]*z[j, k];
#need to account for Left splits

subject to right_split {i in 0..N, b in 0..B, k in BRANCH_NODES}:
c_neg[b, i] <= 1 - (sum{j in F} a[j, i]*z[j, k]);
#need to account for Right splits


subject to 1_assigned_node_pos {i in pos_I}:
sum {b1 in POS_LEAF_NODES}c_pos[b1, i] + sum{b2 in NEG_LEAF_NODES} c_pos[b2, i] = 1;

subject to 1_assigned_node_neg {i in neg_I}:
sum {b1 in POS_LEAF_NODES}c_neg[b1, i] + sum{b2 in NEG_LEAF_NODES} c_neg[b2, i] = 1;
