library(tidyverse)
library(e1071)

#source("text_matrix_processing.R")
air_unk_matrix = readRDS('~/Dropbox/UMich/Fall2019/Biostat625/Project/rds/air_unk_matrix.rds')
air_unk_matrix_cov = readRDS('~/Dropbox/UMich/Fall2019/Biostat625/Project/rds/air_unk_matrix_cov.rds')
air_outcome  = readRDS(file = "~/Dropbox/UMich/Fall2019/Biostat625/Project/rds/air_outcome.rds")

# Train without covariates -------------------------------------------------
# use air_unk_matrix (41177 x 3512)
# split to train and test
# fraction of data for training 

train_frac = 0.01

train_id = sample(1:nrow(air_unk_matrix),floor(train_frac*nrow(air_unk_matrix)), replace = F)
test_id = setdiff(1:nrow(air_unk_matrix), train_id)

X = cbind.data.frame('outcome' = air_outcome$recommended, air_unk_matrix)

X_train = X[train_id,]
X_test = X[test_id,]


system.time({
  # Find out how many cores are available: 
  # detectCores()
  # Create cluster with desired number of cores: 
  cl = makeCluster(4)
  # Register cluster: 
  registerDoParallel(cl)
  # Find out how many cores are being used
  getDoParWorkers()
  
  f <- reformulate(setdiff(colnames(X_train), "outcome"), response="outcome")
  
  air_nb = e1071::naiveBayes(formula = f, 
                       data = X_train) 
                       
  
  stopCluster(cl)
  registerDoSEQ()
  
})

# model test data -------------------------------------------------
y_pred = predict(air_nb, X_test)
# confusion matrix -------------------------------------------------
con.matrix = confusionMatrix(y_pred, X_test$outcome)
print(con.matrix)
# save the model to disk
saveRDS(air_nb, "nb_model.rds")


#  Train with covariates -------------------------------------------------
# use air_unk_matrix_cov (41177 x 3512)
# split to train and test
# fraction of data for training 

train_frac = 0.75

X_cov = cbind.data.frame('outcome' = air_outcome$recommended, air_unk_matrix_cov)

X_train_cov = X_cov[train_id,]
X_test_cov = X_cov[test_id]


system.time({
  # Find out how many cores are available: 
  # detectCores()
  # Create cluster with desired number of cores: 
  cl = makeCluster(4)
  # Register cluster: 
  registerDoParallel(cl)
  # Find out how many cores are being used
  getDoParWorkers()
  
  f <- reformulate(setdiff(colnames(X_train_cov), "outcome"), response="outcome")
  
  air_nb_cov = e1071::naiveBayes(formula = f, 
                           data = X_train_cov)
                           
  
  stopCluster(cl)
  registerDoSEQ()
  
})

# model test data -------------------------------------------------
y_pred_cov = predict(air_nb, X_test_cov)
# confusion matrix -------------------------------------------------
con.matrix = confusionMatrix(y_pred_cov, X_test_cov$outcome)
print(con.matrix)
# save the model to disk
saveRDS(air_nb_cov, "nb_model_cov.rds")