set POS_SCHOOL; #get this from table read, set of positive samples
set NEG_SCHOOL; #get this from table read, set of negative samples

set FEATURES; #index for each feature, will define in .dat
set GROUPS; #index for each group, will define in .dat

set BRANCH_NODES; #index for each branch node, define in .dat file
set POS_LEAF_NODES; #index for each left (positive) leaf node, define in .dat file
set NEG_LEAF_NODES; #index for each right (negative) leaf node, define in .dat file

param SAMPLES_NEG > 0; #number of samples of negative instances (NOT NEEDED, UNLESS WE NEED a?)
param SAMPLES_POS > 0; #number of samples of positive instances (NOT NEEDED, UNLESS WE NEED a?)

param a_neg{s in 1..SAMPLES_NEG, f in FEATURES} >=0;
param a_pos{s in 1..SAMPLES_POS, f in FEATURES} >= 0; 
#param a{s in SAMPLETOT, f in FEATURES}; #get from table read, set of all features for all samples

param C > 0; #weight to account for imbalance, will define in .dat
#param a{j in FEATURES, k in SampleTot}>= 0; #unsure of how to define this. Reading this in from a table? 
# maybe param a, maybe read in data

param member_check{GROUPS, FEATURES} >= 0; #defined in .dat, =1 if feat i in group j
param leaf_nodes_p_left{i in POS_LEAF_NODES, j in BRANCH_NODES} >= 0; #defined in .dat
# =1 if branch node i branches left to reach positive leaf node j
param leaf_nodes_n_left{i in NEG_LEAF_NODES, j in BRANCH_NODES} >= 0; #defined in .dat
# =1 if branch node i branches left to reach negative leaf node j
param leaf_nodes_p_right{i in POS_LEAF_NODES, j in BRANCH_NODES} >= 0; #defined in .dat
# =1 if branch node i branches right to reach positive leaf node j
param leaf_nodes_n_right{i in NEG_LEAF_NODES, j in BRANCH_NODES} >= 0; #defined in .dat
# =1 if branch node i branches right to reach negative leaf node j

var c_pos{POS_LEAF_NODES, 1..SAMPLES_POS} >= 0, <= 1; # =1 if correctly classified
var c_neg{NEG_LEAF_NODES, 1..SAMPLES_NEG} >= 0, <= 1; # =1 if correctly classified
var v{g in GROUPS, k in BRANCH_NODES} >= 0, <= 1; # = 1 if group G chosen for branch k
var z{f in FEATURES, i in BRANCH_NODES} >= 0, <= 1; # =1 if feature f goes left on branch k

maximize Correct_Classification:
sum{i1 in POS_LEAF_NODES, j1 in 1..SAMPLES_POS} c_pos[i1, j1] 
+ C*sum{i2 in NEG_LEAF_NODES, j2 in 1..SAMPLES_NEG} c_neg[i2, j2];
# Logic: counts the number of samples classified correctly
# weights to account for |POS_SCHOOL| \neq |NEG_SCHOOL|
# *****OBJECTIVE FINALIZED*****

subject to 1_branch_feature {k in BRANCH_NODES}:
sum {i in GROUPS} v[i, k] = 1;
# logic: single group chosen for branching at each branch node
# *****CONSTRAINT FINALIZED*****

subject to feature_in_group {j in BRANCH_NODES, f in FEATURES, g in GROUPS}:
member_check[g, f] = 1 ==> z[f, j] <= v[g, j];
# logic: check if feature f in group g, if TRUE, z(f, j) <= v(g,j)
# Follows since cant branch on z if we dont branch on g
# *****CONSTRAINT FINALIZED*****

subject to left_split_pos {i in 1..SAMPLES_POS, b in POS_LEAF_NODES, k in BRANCH_NODES}:
leaf_nodes_p_left[b, k] = 1 ==> c_pos[b, i] <= sum{j in FEATURES} a_pos[i, j]*z[j, k];
# logic: leaf_nodes_p_left checks to see if branch node k branches left to reach leaf node b
# if it does then we derive a constriant from it
# equivalent to c <= L(i,k)
# this handles c_pos
# *****CONSTRAINT FINALIZED*****

subject to right_split_pos {i in 1..SAMPLES_POS, b in POS_LEAF_NODES, k in BRANCH_NODES}:
leaf_nodes_p_right[b, k] = 1 ==> c_pos[b, i] <= 1 - (sum{j in FEATURES} a_pos[i, j]*z[j, k]);
# logic: leaf_nodes_p_right checks to see if branch node k branches right to reach leaf node b
# if it does then we derive a constriant from it
# equivalent to c <= R(i,k)
# this handles c_pos
# *****CONSTRAINT FINALIZED*****

subject to left_split_neg {i in 1..SAMPLES_NEG, b in NEG_LEAF_NODES, k in BRANCH_NODES}:
leaf_nodes_n_left[b, k] = 1 ==> c_neg[b, i] <= sum{j in FEATURES} a_neg[i, j]*z[j, k];
# logic: leaf_nodes_n_left checks to see if branch node k branches left to reach leaf node b
# if it does then we derive a constriant from it
# equivalent to c <= L(i,k)
# this handles c_neg
# *****CONSTRAINT FINALIZED*****

subject to right_split_neg {i in 1..SAMPLES_NEG, b in NEG_LEAF_NODES, k in BRANCH_NODES}:
leaf_nodes_n_right[b, k] = 1 ==> c_neg[b, i] <= 1 - (sum{j in FEATURES} a_neg[i, j]*z[j, k]);
# logic: leaf_nodes_n_right checks to see if branch node k branches right to reach leaf node b
# if it does then we derive a constriant from it
# equivalent to c <= R(i,k)
# this handles c_neg
# *****CONSTRAINT FINALIZED*****

subject to 1_assigned_node_pos {i in 1..SAMPLES_POS}:
sum {b1 in POS_LEAF_NODES}c_pos[b1, i] = 1;
# logic: makes sure c_pos is assigned to only 1 node
# *****CONSTRAINT FINALIZED*****

subject to 1_assigned_node_neg {i in 1..SAMPLES_NEG}:
sum{b2 in NEG_LEAF_NODES} c_neg[b2, i] = 1;
# logic: makes sure c_neg is assigned to only 1 node
# *****CONSTRAINT FINALIZED*****
