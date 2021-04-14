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

set POS_SCHOOL; #get this from table read, set of positive samples
set NEG_SCHOOL; #get this from table read, set of negative samples

set GROUPS; #index for each group, will define in .dat
set FEATURES; #index for each feature, will define in .dat

set BRANCH_NODES; #index for each branch node, define in .dat file
set POS_LEAF_NODES; #index for each left (positive) leaf node, define in .dat file
set NEG_LEAF_NODES; #index for each right (negative) leaf node, define in .dat file

#     param N > 0; number of samples (NOT NEEDED, UNLESS WE NEED a?)

param C > 0; #weight to account for imbalance, will define in .dat
param a{j in FEATURES, 0..N}>= 0; #unsure of how to define this. Reading this in from a table? 
# maybe param a, maybe read in data

param member_check{i in FEATURES, j in GROUPS} >= 0; #defined in .dat, =1 if feat i in group j
param leaf_nodes_p_left{i in BRANCH_NODES, j in POS_LEAF_NODES} >= 0; #defined in .dat
# =1 if branch node i branches left to reach positive leaf node j
param leaf_nodes_n_left{i in BRANCH_NODES, j in NEG_LEAF_NODES} >= 0; #defined in .dat
# =1 if branch node i branches left to reach negative leaf node j

var c_pos{i in POS_LEAF_NODES, j in POS_SCHOOL} >= 0; # =1 if correctly classified
var c_neg{i in NEG_LEAF_NODES, j in NEG_SCHOOL} >= 0; # =1 if correctly classified
var v{g in GROUPS, k in BRANCH_NODES} >= 0; # = 1 if group G chosen for branch k
var z{f in FEATURES, i in BRANCH_NODES} >= 0; # =1 if feature f goes left on branch k

maximize Correct_Classification:
sum{i1 in POS_LEAF_NODES, j1 in POS_SCHOOL} c_pos[i1, j1] 
+ C*sum{i2 in NEG_LEAF_NODES, j2 in NEG_SCHOOL} c_neg[i2, j2];
# Logic: counts the number of samples classified correctly
# weights to account for |POS_SCHOOL| \neq |NEG_SCHOOL|
# *****OBJECTIVE FINALIZED*****

subject to 1_branch_feature {k in BRANCH_NODES}:
sum {i in G} v[i, k] = 1;
# logic: single group chosen for branching at each branch node
# *****CONSTRAINT FINALIZED*****

subject to feature_in_group {j in BRANCH_NODES, f in FEATURES, g in GROUPS}:
member_check[f, g] = 1 ==> z[f, j] <= v[g, j];
# logic: check if feature f in group g, if TRUE, z(f, j) <= v(g,j)
# Follows since cant branch on z if we dont branch on g
# *****CONSTRAINT FINALIZED*****

subject to left_split_pos {i in POS_SCHOOL, b in POS_LEAF_NODES, k in BRANCH_NODES}:
leaf_nodes_p_left[k, b] = 1 ==> c_pos[b, i] <= sum{j in F} a[j, i]*z[j, k];
# logic: leaf_nodes_p_left checks to see if branch node k branches left to reach leaf node b
# if it does then we derive a constriant from it
# equivalent to c <= L(i,k)
# this handles c_pos
# *****CONSTRAINT FINALIZED*****

subject to right_split_pos {i in POS_SCHOOL, b in POS_LEAF_NODES, k in BRANCH_NODES}:
1 - leaf_nodes_p_left[k, b] = 1 ==> c_pos[b, i] <= 1 - (sum{j in F} a[j, i]*z[j, k]);
# logic: 1-leaf_nodes_p_left checks to see if branch node k branches right to reach leaf node b
# if it does then we derive a constriant from it
# equivalent to c <= R(i,k)
# this handles c_pos
# *****CONSTRAINT FINALIZED*****

subject to left_split_neg {i in NEG_SCHOOL, b in NEG_LEAF_NODES, k in BRANCH_NODES}:
leaf_nodes_n_left[k, b] = 1 ==> c_neg[b, i] <= sum{j in F} a[j, i]*z[j, k];
# logic: leaf_nodes_n_left checks to see if branch node k branches left to reach leaf node b
# if it does then we derive a constriant from it
# equivalent to c <= L(i,k)
# this handles c_neg
# *****CONSTRAINT FINALIZED*****

subject to right_split_neg {i in NEG_SCHOOL, b in NEG_LEAF_NODES, k in BRANCH_NODES}:
1 - leaf_nodes_n_left[k, b] = 1 ==> c_neg[b, i] <= 1 - (sum{j in F} a[j, i]*z[j, k]);
# logic: 1-leaf_nodes_n_left checks to see if branch node k branches right to reach leaf node b
# if it does then we derive a constriant from it
# equivalent to c <= R(i,k)
# this handles c_neg
# *****CONSTRAINT FINALIZED*****

subject to 1_assigned_node_pos {i in pos_I}:
sum {b1 in POS_LEAF_NODES}c_pos[b1, i] + sum{b2 in NEG_LEAF_NODES} c_pos[b2, i] = 1;
# logic: makes sure c_pos is assigned to only 1 node
# *****CONSTRAINT FINALIZED*****

subject to 1_assigned_node_neg {i in neg_I}:
sum {b1 in POS_LEAF_NODES}c_neg[b1, i] + sum{b2 in NEG_LEAF_NODES} c_neg[b2, i] = 1;
# logic: makes sure c_neg is assigned to only 1 node
# *****CONSTRAINT FINALIZED*****
