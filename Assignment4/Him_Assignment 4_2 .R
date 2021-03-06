#===================================================================
# ISM645 / IAF601   Principle of Predictive Analytics
# Assignment 4      Classification
# Due Date          November 16, 11:59 pm
#Vathana Him 11/14/2020
#===================================================================


library(tidyverse)
library(DescTools)
library(caTools)
library(caret)
library(broom)
library(yardstick)
library(cutpointr)
library(rpart)

# Import the customer_churn.csv and explore it.
# Drop all observations with NAs (missing values)
#====================== Write R code HERE ==========================


data = read.csv('customer_churn.csv')
data
head(data)
summary(data)




data = drop_na(data)
data



#===================================================================

#======= Question 1 (2 Point) =======
# Q1-1. Build a logistic regression model to predict customer churn by using predictor variables (You determine which ones will be included).
# Q1-2. Calculate the Pseudo R2 for the logistic regression.

#====================== Write R code HERE ==========================



data <- data %>% 
  mutate(churn_binary = if_else(Churn=='Yes', 1, 0))
data

#Q1-1
logistics_reg = glm(churn_binary~SeniorCitizen+tenure+MonthlyCharges+TotalCharges, data=data,family='binomial')
summary(logistics_reg)
#Q1-2
pseudor2 = logistics_reg %>% PseudoR2()
pseudor2
#===================================================================

#======= Question 2 (1 Point) =======
# Q2-1. Split data into 70% train and 30% test datasets.
# Q2-2. Train the same logistic regression on only "train" data.

#====================== Write R code HERE ==========================


#Q2-1
set.seed(645)
sample = sample.split(data, SplitRatio = 0.7)
train = subset(data, sample=TRUE)
test = subset(data, sample=FALSE)




#Q2-2
train_logistics_reg = glm(churn_binary~SeniorCitizen+tenure+MonthlyCharges+TotalCharges, data=train, family='binomial')
summary(train_logistics_reg)
pseudor2 = logistics_reg %>% PseudoR2()
pseudor2

#===================================================================



#======= Question 3 (2 Point) =======
# Q3-1. For "test" data, make prediction using the logistic regression trained in Question 2.
# Q3-2. With the cutoff of 0.5, predict a binary classification ("Yes" or "No") based on the cutoff value, 
# Q3-3. Create a confusion matrix using the prediction result.

#====================== Write R code HERE ==========================



#Q3-1
predict_test = train_logistics_reg %>% augment(newdata =test, type.predict ="response")
summary(predict_test)

#Q3-2
predict_test = predict_test %>% mutate(binary_classification_predict = if_else(.fitted>0.5, "Yes", "No"))
predict_test = predict_test %>% mutate(binary_class_predict = if_else(.fitted>0.5, 1, 0))

#Q3-3
confusionMatrix(as.factor(predict_test$churn_binary), as.factor(predict_test$binary_class_predict), positive='1')

#===================================================================



#======= Question 4 (1 Point) =======
# Q4. Based on prediction results in Question 3, draw a ROC curve and calculate AUC.

#====================== Write R code HERE ==========================


#Q4
roc = roc(predict_test, x = .fitted, class=churn_binary, pos_class=1, neg_class=0)
plot(roc)
auc(roc)


#===================================================================



#======= Question 5 (2 Point) =======
# Q5-1. For "train" data, build a decision tree to predict customer churn by using the same predictor variables as previous questions.
# Q5-2. For "test" data, draw a ROC curve and calculate AUC.

#====================== Write R code HERE ==========================


#Q5-1
churn_dtree = rpart(churn_binary ~ SeniorCitizen+tenure+MonthlyCharges+TotalCharges, data= train, method = 'class',  cp=0.005)

#Q5-2
churn_dtree_prob = churn_dtree %>%  predict(newdata=test, type='prob')
churn_dtree_class = churn_dtree %>%  predict(newdata=test, type='class')

churn_predict = test %>% mutate(.fitted = churn_dtree_prob[, 2]) %>% mutate(predict_class = churn_dtree_class)

roc = roc(churn_predict, x=.fitted, class=churn_binary, pos_class=1, neg_class=0)

plot(roc) + 
  geom_line(data = roc, color = "red") + 
  geom_abline(slope = 1) + 
  labs(title = "ROC Curve for Classification Tree")
auc(roc)




#===================================================================



#======= Question 6 (1 Point) =======
# Q6-1. Prune your decision tree (You can set the cp as appropriate. Pruning does not necessarily alter the tree).
# Q6-2. For "test" data, draw a ROC curve of the pruned decision tree and calculate AUC.

#====================== Write R code HERE ==========================
#Q6-1
churn_dtree_prune = prune(churn_dtree, cp=0.01)

churn_dtree_prune_prob = churn_dtree_prune %>% predict(newdata=test, type='prob')
churn_dtree_prune_class = churn_dtree_prune %>% predict(newdata=test, type='class')

#Q6-2
churn_prune_predict = test %>% mutate(.fitted = churn_dtree_prune_prob[, 2]) %>% mutate(predict_class = churn_dtree_prune_class)
roc = roc(churn_prune_predict, x=.fitted, class=churn_binary, pos_class=1, neg_class=0)
plot(roc) +geom_line(data = roc, color = "red") + 
  geom_abline(slope = 1) + 
  labs(title = "ROC Curve for Classification Tree")
auc(roc)


#===================================================================


#======= Question 7 (1 Point) =======
# Q7. Among predictive models you have developed above, which one is better in predicting (classifying) customer churn?
# Use comments to write your opinion (#).

#====================== Write R code HERE ==========================
#Based on the models that were created, the logistic regression model seem 
#to be a better classification model for predicting customer churn. 
#The predictors variables that were chosen were all continuous 
#which may explain why the logistics regression has a higher AUC value that the other models with a value of 0.81. 
#This AUC score was higher than the next two models that were created, 
#which shows an indictor that the logistic regression is the best model in this scenario. 
#===================================================================
