#####################################
#		MDC - Machine Learning		#
#				UNICAMP				#
#			Linear Regression		#
#####################################

########################################
# Auxiliary code for Linear Regression #
########################################




# Cost function J(x,y,theta)
cost <- function(X, y, theta) {
  sum( (X %*% theta - y)^2 ) / (2*length(y))
}


########### Gradient Descent
# -- Inputs
# X: matrix MxN (M examples and N features)
# y: target value for each sample - matrix Mx1 (M examples)
# learningRate
# nIter: number of iterations to perform GD
# plotCost: plot the cost value in each iteration
#
# -- Output
# theta: the weights of intercept + each feature (matrix 1 x N+1)
# cost_history: the values of the cost function in each iteration
GD <- function(X, y, learningRate=0.1, nIter=1000, plotCost=FALSE){
	X = cbind(1, X) # add a collum for the intercept in X
	
	nFeatures = dim(X)[2]

	theta = matrix(runif(nFeatures), nrow=nFeatures)

	#store the cost function values to plot later
	cost_history = matrix(0, ncol=nIter, nrow=1)
	

	#### ---> Perform GD
	for (i in 1:nIter) {
	  error = (X %*% theta - y)
	  delta_J = t(X) %*% error / length(y)
	  theta = theta - learningRate * delta_J  #Update all thetas at once
	  
	  #Storing the cost function value for current iteration
	  cost_history[i] = cost(X, y, theta)
	}

	return(list(theta=theta, cost_history=cost_history))
} 




########### Normal Equations
# -- Inputs
# X: matrix MxN (M examples and N features)
# y: target value for each sample - matrix Mx1 (M examples)
# -- Outputs
# theta: the weights of intercept + each feature (matrix 1 x N+1)
NE <- function(X, y){
	X = cbind(1,X)
	invXX = solve(t(X) %*% X) 
	theta = invXX %*% (t(X) %*% y)
	return(theta)
}




########## Prediction
# -- Inputs
# X: matrix MxN (M examples and N features)
# theta: weights of the intercept + features
# -- Outputs
# prediction: the estimated target value for X
predict <- function(X, theta){
	X = cbind(1,X)
	prediction = X %*% theta
	return(prediction)
}

########## MSE
# -- Inputs
# prediction: the estimated target value for X
# y: ground truth for target value
# -- Outputs
# MSE
MSE <- function(prediction, y){
	return(sum((prediction - y)**2) / (length(y)))
}

