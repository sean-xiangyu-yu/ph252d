temp = merged[[1]] # for every merged dataset
library(data.table)
library(tidyverse)
library(sl3)
library(tmle3)
library(origami)
library(doMC)

# ----------------------------------------
# SL set up
# ----------------------------------------

lrn_elastic <- Lrnr_glmnet$new(alpha = 0.5)
lrn_earth <- Lrnr_earth$new()
lrn_rf <- Lrnr_ranger$new()
lrn_rpart <- Lrnr_rpart$new()

discrete_sl_metalrn <- Lrnr_cv_selector$new()

sl_stack <- make_learner(Stack, 
                         lrn_elastic,
                         lrn_earth,
                         lrn_rf,
                         lrn_rpart)

# ----------------------------------------
# TMLE set up
# ----------------------------------------

node_list <- list(W = c("X1","X2","X3","X4","X5","X6","X7", "X8","X9",
                        "post","n.patients","V1_avg","V2_avg","V3_avg",
                        "V4_avg","V5_A_avg","V5_B_avg","V5_C_avg"),
                  Y = "Y", A = "Z")
tmle_spec = tmle_ATT(treatment_level = 1, control_level = 0)

lrnr_sl_a <- make_learner(Lrnr_sl,
                          learners = sl_stack,
                          outcome_type = 'binomial',
                          metalearner= discrete_sl_metalrn)
lrnr_sl_y <- make_learner(Lrnr_sl,
                          learners = sl_stack,
                          outcome_type = 'continuous',
                          metalearner = discrete_sl_metalrn)
learner_list <- list(Y = lrnr_sl_y, A = lrnr_sl_a)

tmle_fit <- tmle3(tmle_spec, temp, node_list, learner_list)
