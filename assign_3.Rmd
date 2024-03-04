---
title: "Assignment 3: Sampling variability and a taste of inference"
author: "Akshat Valse"
output:
  pdf_document: default
urlcolor: blue
---

**Due Saturday, July 15 at 8am**

Please upload the `PDF` that you obtain by knitting
the `Rmd` file that contains your `R` code and your text answering other questions. So this uploaded file will also show any output that `R` produces in addition to your code. 

You should not touch the starter code as it will print out the necessary data frames and results for grading purposes.

```{r}
set.seed(123)
```


## Part 1. Summary statistics and loss minimization
For this exercise, we will verify for ourselves some properties of the sample mean, sample median, and sample mode.

To start, let's download some data on baseball players, including their salary, on-base percentage, number of runs, hits, etc. Specifically, we will be looking into the `salary` column. 

```{r}
baseball_data = read.table(url('http://web.stanford.edu/class/stats191/data/baseball.table'), header=T)
baseball_data
```

### Exercise 1.1
Make a histogram of the `salary` column. Your plot should be appropriately titled and axes are appropriately labeled. You should not label each bin because the bin labels will make the plot unreadable. Briefly describe the data using the histogram.

```{r exer1.1}
par(mfrow=c(1,1))

### YOUR CODE HERE
hist(baseball_data$salary, main = "Baseball Player Salary", xlab = "Salary in USD", col = "darkseagreen")
### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
The plot is incredibly right skewed.

### Exercise 1.2
Now, write a function named `compute_mse` that computes the mean euclidean distance between each salary point and some input $x$. This means, your function should take in one argument, `x`, and output (you probably have to knit this file first to read the equation) 
\begin{align}
f(x) &= \frac{1}{n}\|\pmb{s}_i - x\|_2^2\\
&= \frac{1}{n} \sum_{i=1}^n  (\mathrm{s}_i - x)^2 
\end{align}
where $\pmb{s} \in \mathbb{R}^n$ denotes the vector of salaries, and $s_i$ denotes the $i$th player's salary.

This function is also called the **mean squared error** because it measure the average of the squared errors. (In this sense, the mean squared error is an empirical risk, meaning it is the  average loss on an observed dataset; the loss function in this case is the squared error loss/euclidean distance.)


```{r exer1.2}
### YOUR CODE HERE
mse = 0
compute_mse <- function(x){
  for(i in 1:length(baseball_data$salary)){
    mse = mse+(baseball_data$salary[i] - x)^2
  }
  mse = mse/length(baseball_data$salary)
  return(mse)
}
compute_mse(mean(baseball_data$salary))
### END OF YOUR CODE
```

### Exercise 1.3
Now, you will write another function named `compute_mad` that computes the mean absolute deviation between each salary point and some input $x$. This means, your function should take in one argument `x` and output this time:
\begin{align}
f(x) &= \frac{1}{n}\|\pmb{s}_i - x\|_1\\
&= \frac{1}{n} \sum_{i=1}^n  |\mathrm{s}_i - x| 
\end{align}

```{r exer1.3}
### YOUR CODE HERE
mad = 0
compute_mad <- function(x){
    for(i in 1:length(baseball_data$salary)){
    mad = mad+abs(baseball_data$salary[i] - x)
    }
  mad = mad/length(baseball_data$salary)
  return(mad)
}

compute_mad(median(baseball_data$salary))
### END OF YOUR CODE
```

### Exercise 1.4
Our goal is to create two plots: one visualizing the mean squared error (MSE) as a function of $x$ and the mean absolute deviation (MAD) as a function of $x$. To choose our input $x$, we will evenly grid an interval as follows:
You will create a sequence, starting from 0 and ending at 5000 that is evenly gridded by 50,000 points. Name this vector `x_vec`.

```{r exer1.4a}
### YOUR CODE HERE
x_vec = seq(from = 0, to = 5000, length.out = 50000)
### END OF YOUR CODE
```

Now, we will get the MSE and MAD evaluated for each one of those x's in `x_vec` by calling the `compute_mse` and `compute_mad` functions you wrote in Exercise 1.3. 

**Hint.** `compute_mse` expects the input to be a number instead of a vector. To compute the MSE for each of the `x` values in `x_vec`, check out the `sapply` function.

```{r exer1.4b}
### YORU CODE HERE
?sapply
MSE = sapply(x_vec, compute_mse)
MAD = sapply(x_vec, compute_mad)
### END OF YOUR CODE
```

### Exercise 1.5
Before we create our plots, there is just one more thing remaining: we will compute the mean and median of `salary` and store them respectively in `mean_salary` and `med_salary`.

Then, having created our vectors of $x$ and $y$ values, we can now plot side-by-side two line plots. Your x-axis should be values in `x_vec`, and your y-axis should be the MSE and MAD that you computed, respectively. You should title and label the axes accordingly. We will overlay the MSE plot with a vertical line at `mean_salary` and the MAD plot with a vertical line at `med_salary`. You should color both vertical lines **red**.

**Hint.** To overlay the plot with a line, check out the `abline` function.

What do you notice in the plots?

```{r exer1.5}
### YOUR CODE HERE
par(mfrow=c(1,2))
mean_salary = mean(baseball_data$salary)
med_salary = median(baseball_data$salary)
#Plots the graphs
plot(x_vec, MSE, xlab = "Values", ylab = "Mean Standard Error")
abline(v = mean_salary, col = 'red')
plot(x_vec, MAD, xlab = "Values", ylab = "Mean Absoute Deviation")
abline(v = med_salary, col = 'red')
### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
The MSE plot grows much faster than the MAD plot as the distances are being squared.

### Exercise 1.6
Recall that if the average sales price of 10 homes is one million dollars, then each of the 10 houses was sold on average for one million dollars.

On the other hand, if the median sales price of 10 homes is one million dollars, then we know that at least 5 homes sold for one million dollars **or more**, and at least 5 homes sold for one million dollars **or less**. 

From the histogram of the data, do you think it is more reasonable that we use the **mean** or the **median** as the summary statistic to describe our data?

**YOUR EXPLANATION HERE.**

We should use the median as it is more robust to skewed data.



## Part 2. A central limiting phenominon

### Exercise 2.1

In this problem, we will explore a puzzling phenomenon that underpins the theory of "normal approximation" and the central limit theorem. The central limit theorem is a cornerstone to the field of statistics. We will see this theorem in action. 

We begin by generating some samples from the chi-squared distribution with 2 degrees of freedom (denoted $\chi^2_2$, the subscript represents the degrees of freedom which is in our case 2). But before that, let us first see what the probability density function (pdf) of a chi-squared random variable (abbreviated r.v. henceforth) looks like.

You will generate a evenly spaced sequence, starting from 0, ending at 10; the length of this sequence should be 1000. Name this sequence `x`.

```{r}
par(mfrow=c(1,1))
### YOUR CODE HERE
x = seq(from = 0, to = 10, length.out = 1000)
### END OF YOUR CODE

## compute the pdf of chisq rv on the grid generated above
plot(x, dchisq(x, df=2), type='l', main='pdf of the chi-squared r.v.',
     xlab='x', ylab='density') # df is degrees of freedom
```

Briefly describe the density using the terminologies from the lecture on **Describing the Data**.

**YOUR EXPLANATION HERE.**
The data is right skewed and the density curve reflects that. The density curve is still unimodal however.

### Exercise 2.2

Below, you will generate $n=4$ data points from the chi-squared distribution with 2 degrees of freedom. Store your generated samples in the vector `cs_samples`. Then, plot a histogram of your samples. Your plot should be appropriately titled; your axes should also be appropriately labeled. Finally, compute the mean of your samples, print it out, and store it in a variable called `cs_samples_mean`.

**Hint.** The `rchisq` function could be of use.

```{r exer2.2}
?par(mfrow=c(1,1))
### YOUR CODE HERE
## generate n=4 samples from a chisq dist. with 2 df
cs_samples = rchisq(4, df = 2)
### END OF YOUR CODE

print(cs_samples)

### YOUR CODE HERE
## plot a histogram of your samples
hist(cs_samples, main = "Histogram of Chi Squared Samples", xlab = "Chi Squared Samples", col = "royalblue")

### END OF YOUR CODE

### YOUR CODE HERE
## compute mean of your samples
mean(cs_samples)
### END OF YOUR CODE
```

### Exercise 2.3

Now, you will write a function that performs the tasks outlined in Exercise 2.2. Your should name your function `simulate_chisq`. This function should take in $1$ argument, $n$, that governs the size of the sample to be generated. This function should return one thing: the sample mean of $n$ samples. 


```{r exer2.3}
### YOUR CODE HERE
simulate_chisq <- function(n){
  nmean = mean(rchisq(n, df = 2))
  return(nmean)
}
### END OF YOUR CODE

simulate_chisq(n = 10)
```

### Exercise 2.4

Having written the function, let's repeat the procedure in Exercise 2.2 10,000 times. You will write a function called `simulate_means` that takes in one argument `n` (the sample size) and returns 3 things: the 10,000 sample means themselves, the average of the 10,000 sample means, and the standard deviation of the sample means. Inside `simulate_means`, you will write a `for` loop that, in each iteration, calls the `simulate_chisq` function that you wrote in Exercise 2.3. 

Then, test your function by executing the function with $n=4$, same $n$ as that used in Exercise 2.2.

Finally, plot a histogram of the empirical distribution of the **sample averages** with appropriately chosen axes labels and title, and **100 bins**.

Describe what you see in the histogram using terminologies from the lecture on "Describing the Data".

**Hint.** To create a numeric vector of a fixed length, check out the `numeric` function.

**Hint.** For returning multiple values at once, look into [**lists**](https://statisticsglobe.com/r-return-multiple-objects-in-function).


```{r exer2.4}
par(mfrow=c(1,1))
### YOUR CODE HERE
n = 4
simulate_means = function(n) {
  means = numeric(10000)
  for (i in 1:10000){
    means[i] <- simulate_chisq(n)
  }
    return(list(means, mean(means), sd(means)))
}
hist1 = simulate_means(4)
hist(hist1[[1]], breaks = 100, main = "Empirical Distribution of Sample Averages", xlab = "Values", col = "royalblue")
### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
Thw data is once again right skewed due to the outliers. The data is still unimodal.

### Exercise 2.5
Now, you will call the function `simulate` that you wrote in Exercise 2.4, except for this time, your sample size for each of the 10,000 trials will be $n=100$ instead.

Then, plot the histograms visualizing the empirical distributions of your generated sample averages from Exercise 2.4 and Exercise 2.5 side-by-side, each with 100 bins. As always, your plots should be appropriate titled and labeled.

What do you notice in the histogram?

```{r, exer2.5}
### YOUR CODE HERE
## generate a vector of length 10,000 of sample means
simulate_means(100)

### END OF YOUR CODE

par(mfrow=c(1,2))

### YOUR CODE HERE
## plot the 2 histograms below
hist2 = simulate_means(100)
hist(hist2[[1]], breaks = 100, main = "Empirical Distributions of Sample Averages", xlab = "Values (n=100)", col = "royalblue")
hist1 = simulate_means(4)
hist(hist1[[1]], breaks = 100, main = "Empirical Distributions of Sample Averages", xlab = "Values (n=4)", col = "royalblue")
### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
The increased n value yielded a more normalized histogram while the smaller n still contained skew.

### Exercise 2.6
Repeat the sampling procedure outlined in Exercise 2.4 for $n = 4, 9, 16, 25, 36, 100, 400, 900, 1600$.

You will output three things:

1. Save your resulting mean and standard deviations in a 9 x 3 matrix; each row of this matrix stores the corresponding **n, mean, sd** values to that `n`. For example, the first row should be **4, mean of 10,000 averages of samples each of sample size 4, sd of 10,000 averages of samples each of sample size 4**. The second row should be **9, mean of 10,000 averages of samples each of sample size 9, sd of 10,000 averages of samples each of sample size 9**. So, put it another way: the first column should be **4, 9, 16, 25, 36, 100, 400, 900, 1600**. The second column should be the corresponding means of 10,000 averages. The third column should be the corresponding standard deviations of 10,000 averages. The matrix `sample_result` has been created for you already; you will only need to fill in the entries.
2. For each $n$, generate a histogram of the 10,000 sample means. You should title your plot $n = 4/9/16/25/36/100/400/900/1600$ (the appropriate value of $n$ corresponding to the plot) and label your axes appropriately. Your histogram should have 100 bins.
3. Save the samples for each $n$ in a list called `all_samples`. You can read more about lists [here](https://www.tutorialspoint.com/r/r_lists.htm).

**Hint.** You will use a `for` loop and populate the matrix iteratively. To create a vector, use the `c()` command; for example, if I want to create a vector with entries 2, 3, I would write `c(2, 3)`. To concatenate a string with a integer, look into the `paste` or `sprintf` functions.

```{r exer2.6}
par(mfrow=c(3, 3))

sample_result = matrix(0, nrow=9, ncol=3)
all_samples = list()


### YOUR CODE HERE
index = c(4, 9, 16, 25, 36, 100, 400, 900, 1600)
for (i in 1:9){
  sample_result[i, 1] = index[i] 
  sample_result[i, 2] = simulate_means(index[i])[[2]]
  sample_result[i, 3] = simulate_means(index[i])[[3]]
}
for (j in 1:9){
  all_samples[[j]] = simulate_means(index[j])[[1]]
}
#print(all_samples)

### END OF YOUR CODE

colnames(sample_result) = c('n', 'mean', 'sd')
print(sample_result)

hist(simulate_means(4)[[1]], breaks = 100, main = "Sample Means", xlab = "Values (n=4)", col = "royalblue")
hist(simulate_means(9)[[1]], breaks = 100, main = "Sample Means", xlab = "Values (n=9)", col = "royalblue")
hist(simulate_means(16)[[1]], breaks = 100, main = "Sample Means", xlab = "Values (n=16)", col = "royalblue")
hist(simulate_means(25)[[1]], breaks = 100, main = "Sample Means", xlab = "Values (n=25)", col = "royalblue")
hist(simulate_means(36)[[1]], breaks = 100, main = "Sample Means", xlab = "Values (n=36)", col = "royalblue")
hist(simulate_means(100)[[1]], breaks = 100, main = "Sample Means", xlab = "Values (n=100)", col = "royalblue")
hist(simulate_means(400)[[1]], breaks = 100, main = "Sample Means", xlab = "Values (n=400)", col = "royalblue")
hist(simulate_means(900)[[1]], breaks = 100, main = "Sample Means", xlab = "Values (n=900)", col = "royalblue")
hist(simulate_means(1600)[[1]], breaks = 100, main = "Sample Means", xlab = "Values (n=1600)", col = "royalblue")
```

### Exercise 2.7

In theory, we know that what the true mean of a chi-squared r.v. should be. The expected value (or the theoretical mean) of a chi-squared r.v. is equal to its degrees of freedom. So, for our chi-squared r.v. with 2 degrees of freedom, we know that the theoretical mean should be 2. If you are curious, you can read more about the chi-squared distribution [here](https://en.wikipedia.org/wiki/Chi-squared_distribution).

Make 3 line plots overlayed with the points using the columns of the matrix `sample_result`. As always, you should label the axes accordingly. The plots will be respectively:

1. **y-axis**: `mean` of sample averages against **x-axis** sample size `n`.

2. **y-axis**: `sd` of sample averages against **x-axis** sample size `n`.

3. **y-axis**: `sd` of sample averages against **x-axis** `mean` of sample averages.

Comment on what you observe (whether or not you observe a clear pattern; if so, what is the pattern?) for each plot as we increase the sample size from $n=4$ to $n=1600$. 

**Hint.** You can overlay a plot with points using the `points` function. You probably have to sort your values for one of the plots in order for the line segments to be connected correctly. To sort all the rows of a data frame according to values specified in a column, you can use the `order` function and apply it directly to the rows of a data frame like `data[order(something), ]`.

**Remark.** Recall that each of the summary statistics (mean, sd) is calculated on the same number of trials, 10,000. The difference here is that the sample size of the individual samples for which we calculated the mean is different.

```{r}
par(mfrow=c(1,3))

### YOUR CODE HERE
plot(sample_result[,1], sample_result[,2],type = "l")
points(sample_result[,1], sample_result[,2])

plot(sample_result[,3], sample_result[,2],type = "l")
points(sample_result[,3], sample_result[,2])

plot(sample_result[,3], sample_result[,1],type = "l")
points(sample_result[,3], sample_result[,1])
### END OF YOUR CODE
```

### Exercise 2.8

Now, we will first see what the pdf of a normal distribution looks like.
Then, for each of your samples corresponding to different $n$'s, you will standardize the samples by first subtracting 2 from all the samples, and then dividing each sample by $1/\sqrt(n)$ for their respective $n$. 

Then, you will overlay the density plots of the **standardized samples** corresponding to $n = 4, 36, 100, 1600$ on top of the density plot of the normal distribution, which has been created already for you. This means, you will create **one** plot with the normal pdf and the densities for $n=4, 36, 100, 1600$.

You should use the colors `chocolate1`, `chocolate2`, `chocolate3`, and `chocolate4` corresponding each to $n = 4, 36 , 100, 1600$, respectively. For clarity, you will set `lwd=2` for each of the density plots so that the lines are thicker. 

What do you observe from the plot? As a refresher, you can revisit Exercise 2.1 in which we visualized the distribution of a chi-squared r.v. with 2 degrees of freedom - the distribution we sampled from.

**Hint.** You should not `for` loop again. All of your samples have been saved in `all_samples`.


```{r, exer2.8}
par(mfrow=c(1,1))
x = seq(-5, 5, length.out=1000)
y = dnorm(x, mean = 0, sd = sqrt(2*2))
plot(x, y, type='l', col='black', 
     main='Visualizing limiting dist.', 
     lwd=3,
     ylim = c(0, 0.5))
samples = list()
### YOUR CODE HERE

lines(density((simulate_means(4)[[1]] - 2)*sqrt(4)), col = "chocolate1", lwd = 2)
lines(density((all_samples[[5]] - 2)*sqrt(36)), col = "chocolate2", lwd = 2)
lines(density((all_samples[[6]] - 2)*sqrt(100)), col = "chocolate3", lwd = 2)
lines(density((all_samples[[9]] - 2)*sqrt(1600)), col = "chocolate4", lwd = 2)

### END OF YOUR CODE

legend('topleft', 
       lty=1,
       lwd=2,
       legend=c('normal', 'n=4', 'n=36', 'n=100', 'n=1600'),
       col=c('black', 'chocolate1', 'chocolate2', 'chocolate3', 'chocolate4'))
```

**YOUR EXPLANATION HERE.**
Increasing n leads to a density curve that is more than more close to a perfect normal distribution curve due to the CLT.

## Part 3. A bootstrapped confidence interval

In this exercise, we will work with the Claridge data found in the `boot` library. You will first install the `boot` library. Then, we will look up what the `claridge` dataset is and load in the data. 

```{r}
require(boot)
?claridge
data("claridge")
```


### Exercise 3.1

This exercise concerns the **sample correlation** of the variables in this dataset. 
Recall that the sample correlation is a measure of how dependent two variables are. 

(The difference between the **sample correlation** and the **population correlation** is that: we can assume that the `claridge` data is a **sample** from a much larger **population** that has **population correlation** $\rho$, and we will estimate the true population correlation coefficient $\rho$ using the sample correlation (denoted $\hat{\rho}$). Usually in Statistics, we put a $\hat{}$ to denote estimators.

Upon looking up the `claridge` dataset, you will see that there are two columns in the dataset: `dnan` and `hand`. 

You will start by computing the sample Pearson correlation coefficient between `dnan` and `hand` using the `cor` function and print it out.

```{r exer3.1}
### YOUR CODE HERE
cor(claridge$dnan, claridge$hand, method = 'pearson')
### END OF YOUR CODE
```

### Exercise 3.2

Now we want to form an interval that gives us a sense of how much variability there is for the sample correlation using repeated sampling. 

We can do so using the bootstrap procedure. You will start by creating a vector filled with `NA`s called `boot_cor_vec` with length 10,000 using the `rep` function. It is important that we populate this vector with `NA`s so if any entry is not updated, we will get a warning.
Then, you will obtain 10,000 bootstrap resamples of the `claridge` data. For each bootstrap resample, you will compute the sample correlation and store that in `boot_cor_vec`.

When you create the bootstrap sample, you should resample with replacement **entire rows** of the `claridge` data. Briefly explain the reason why resampling `dnan` and `hand` independently will produce the incorrect distribution for the correlation coefficient.


**Hint.** Each one of your bootstrap sample should have the same number of samples as the original dataset.

```{r exer3.2}
set.seed(123)

### YOUR CODE HERE
boot_cor_vec = rep(NA, length.out = 10000)
for (i in 1:10000){
  bootstrap_sample <- claridge[sample(1:nrow(claridge), nrow(claridge), replace = TRUE), ]
  boot_cor_vec[i] <- cor(bootstrap_sample$dnan, bootstrap_sample$hand, method = 'pearson')
}
 
### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
The re sampling would create direct x and y vectors whose cos(theta) of their dot products would not yield the same value as the dot product of the vectors re sampled together.

### Exercise 3.3

The central limit theorem (CLT) does not always apply to our data. Even when it does, the sample size that is required for the CLT to be an adequate approximation could vary a lot depending on the statistic being computed. 

Recall that we can use the bootstrapped samples to estimate the standard error of our sampling distribution. Let us suppose for a moment that the CLT does indeed apply and is a good approximation for the sampling distribution of the sample Pearson correlation coefficient. If that is the case, we can use the bootstrapped standard error and the CLT to form a 95\% confidence interval for the population correlation. 

**Hint.** In order to find the 97.5\% quantile of a normal distribution, you can use the `qnorm` function.

```{r exer3.3}
### YOUR CODE HERE
boot_mean = mean(boot_cor_vec)
boot_se = (sd(boot_cor_vec)/sqrt(length(boot_cor_vec)))
upper_interval = boot_mean+(qnorm(0.975)*boot_se)
lower_interval = boot_mean-(qnorm(0.975)*boot_se)
upper_interval
lower_interval

### END OF YOUR CODE
```

### Exercise 3.4

First, before we form a confidence interval for the population correlation using the bootstrapped samples, we will plot a histogram of `boot_cor_vec`, the bootstrapped samples. Your plot should be adequately titled with appropriate axes labels.

From the histogram, does the sampling distribution look normal?

```{r exer3.4}
### YOUR CODE HERE
hist(boot_cor_vec, main = "Bootstrapped Sample Distribution", xlab = "Values", col = "royalblue")

### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
The sampling distribution does not look normal as it has a left skew.

### Exercise 3.5

Now, we will form a confidence interval for the population correlation using the **bootstrap quantiles**. Below, compute a 95\% confidence interval by finding the 2.5\% and 97.5\% quantiles of `boot_cor_vec`, the bootstrapped distribution of the sample correlation coefficient. You can find the quantile using the `quantile` function.

Briefly describe how this interval compares to your answer in Exercise 3.3. From the histogram of the sampling distribution of the sample correlation coefficients, which interval do you think is more reasonable and why?

```{r exer3.5}
### YOUR CODE HERE
hint = quantile(boot_cor_vec, 0.975)
lint = quantile(boot_cor_vec, 0.025)
hint
lint

### END OF YOUR CODE
```

**YOUR EXPLANATIONS HERE.**
This interval is much larger as the data is more spread out. In this case, this interval is most reasonable as the previous one is too small to account for such a large percent of the 


