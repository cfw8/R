# Setup
library(h2o)
library(RCurl)

                 
# Load the Wisconsin Breast Cancer Dataset
UCI_data_URL <- getURL('https://archive.ics.uci.edu/ml/machine-learning-databases/breast-cancer-wisconsin/wdbc.data')

names <- c('id_number', 'class', 'radius_mean', 
           'texture_mean', 'perimeter_mean', 'area_mean', 
           'smoothness_mean', 'compactness_mean', 
           'concavity_mean','concave_points_mean', 
           'symmetry_mean', 'fractal_dimension_mean',
           'radius_se', 'texture_se', 'perimeter_se', 
           'area_se', 'smoothness_se', 'compactness_se', 
           'concavity_se', 'concave_points_se', 
           'symmetry_se', 'fractal_dimension_se', 
           'radius_worst', 'texture_worst', 
           'perimeter_worst', 'area_worst', 
           'smoothness_worst', 'compactness_worst', 
           'concavity_worst', 'concave_points_worst', 
           'symmetry_worst', 'fractal_dimension_worst')
BreastCancer <- read.table(textConnection(UCI_data_URL), sep = ',', col.names = names)


# Use  all other features to predict whether a tumor is malignant or benign.
y <- 'class'
x <- setdiff(names(BreastCancer), c(y, 'id_number'))

BreastCancer[, x] <- sapply(BreastCancer[, x], as.numeric)
BreastCancer[, y] <- as.factor(BreastCancer[, y])

# First, start an H2O instance.
# H2O requires that objects are in a specific format.
# Then convert R data frame into an H2O object.
h2o.init()
BreastCancer <- as.h2o(BreastCancer)

# Split into training and test data.
split <- h2o.splitFrame(data = BreastCancer, ratios = 0.75, seed=1)

train <- split[[1]]
test <- split[[2]]

# Run AutoML
aml <- h2o.automl(x = x, y = y,
                  training_frame = train,
                  seed = 1)

# Display the leaderboard of results
lb <- aml@leaderboard
head(as.data.frame(lb), style = "rmarkdown")


aml@leader

pred <- h2o.predict(aml, test)
head(as.data.frame(pred), style = "rmarkdown")


pred <- h2o.predict(aml@leader, test)
head(as.data.frame(pred), style = "rmarkdown")

# shutdown  h2o instance
h2o.shutdown()
