---
title: "Assignment 2: Visualization and Summary Statistics"
author: "STATS 101"
output:
pdf_document: default
urlcolor: blue
---

## Part 1. A disguising plot

In this exercise, we will be comparing three types of plots for the same set of data.
You will explore how different visualization techniques display the data, and describe your conclusions on which plot you think makes the most sense for this specific illustrating dataset.

We will beginning by generating some data from a Gaussian mixture model For those who are curious, you can read more about what the Gaussian mixture model is [here](https://brilliant.org/wiki/gaussian-mixture-model/).

```{r exer_1_setup, echo=T, eval=T}
## set the seed for reproducibility
set.seed(123)
n = 300
num_in_cluster_1 = rbinom(1, size=n, prob=.3)
num_in_cluster_2 = n - num_in_cluster_1
data_cluster1 = rnorm(num_in_cluster_1, mean=-3, sd=1)
data_cluster2 = rnorm(num_in_cluster_2, mean=15, sd=2)
data = c(data_cluster1, data_cluster2)
head(data)
```

### Exercise 1a.

Visualize `data` using a density histogram with 50 equally sized bins. You should give your plot appropriate title and axis labels. Briefly describe the data using a couple of sentences (i.e. what patterns do you observe?).

```{r exer_1a, echo=T, eval=T}
### YOUR CODE HERE
densityHistogram = hist(data, main = 'Gaussian Mixture Model',xlab = 'Set 1', labels = FALSE,
     col = 'blue', freq = FALSE, ylim = c(0,0.17), breaks = 50)
### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
#The data is bimodal and each section is rougly symetric.

### Exercise 1b.

Now, add a density curve for `data` overlaying on top of your histogram using the default value for the bandwidth parameter either by not explicitly specifying the `bw` argument or passing in `bw = nrd0` using the `gaussian` kernel. 

```{r exer_1b, echo=T, eval=T}
### YOUR CODE HERE
hist(data, main = 'Gaussian Mixture Model',xlab = 'Numbers', labels = FALSE,
     col = 'blue', 
     freq = FALSE, 
     ylim = c(0,0.17), 
     breaks = 50) 
lines(density(data, kernel = 'gaussian'), main = 'Gaussian Mixture Model', lwd = 2, col = 'red')
### END OF YOUR CODE
```


### Exercise 1c.

Instead of using the default bandwidth as in (b), we will now input a specific value for the bandwidth parameter. Create a new density histogram plot using `data` with 50 bins and overlay it with a density curve with the `gaussian` kernel and bandwidth set to 0.5.

Describe what you observe from comparing the resulting plots from (b) and (c).

```{r exer_1c, echo=T, eval=T}
#R CODE HERE
densityHistogram = hist(data, main = 'Gaussian Mixture Model',xlab = 'Numbers', labels = FALSE,
     col = 'blue', freq = FALSE, ylim = c(0,0.17), breaks = 50) 
lines(density(data, kernel = 'gaussian', bw=0.5), main = 'Gaussian Mixture Model', lwd = 2, col = 'red')
### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
#Reducing the bandwidth helps capture more of the peaks and fits the data a bit better.

### Optional reading: comparing density estimation fits

How do we quantify which of these density curves fit to the data better? 
We can evaluate how "fitting" a kernel density estimator (the density curve that you plotted) is using some goodness of fit test, for example, the two-sample Kolmogorov-Smirnov test. The null hypothesis of Kolmogorov-Smirnov test states that there is no difference between the two distributions; in our case, this means the fit of the KDE is adequate.

We will first generate some samples from the kernel density estimator (KDE) we fitted to our data.

```{r exer1_explanation, eval=T, echo=T}
## extract default bw
kde_gauss = density(data, kernel='gaussian')
default_bw = kde_gauss$bw
custom_bw = 0.5

gauss_kernel <- function(n, bw) {
    rnorm(n, sd=bw)
}

bootstrap_sample = sample(data, n, replace=T)
kde_sample_default_bw = bootstrap_sample + gauss_kernel(n, default_bw)
kde_sample_custom_bw = bootstrap_sample + gauss_kernel(n, custom_bw)
```

Let's print the resulting $p$-values from the Kolmogorov-Smirnov test comparing the default bandwidth KDE generated samples to our actual data:
```{r}
ks.test(data, kde_sample_default_bw)
```

Since the $p$-value is $0.034 < 0.05=\alpha$, we reject the null hypothesis that the fit is adequate with $95\%$ confidence.

Let's now print the resulting  $p$-values from the Kolmogorov-Smirnov test comparing the generated samples from a KDE with custom bandwidth=0.4 to our actual data:

```{r}
ks.test(data, kde_sample_custom_bw)
```

Since the $p$-value is $0.721 > 0.05=\alpha$, we fail reject the null hypothesis and conclude that the fit is adequate  with $95\%$ confidence.

Thus, it seems like our customly chosen $0.5$ bandwidth fits to the data better according to the Kolmogorov-Smirnov test than the default bandwidth of $2.4$.

### Exercise 1d.

In the last subpart of Exercise 1, we will visualize this dataset using a boxplot. 

Visualize `data` below using a boxplot. You should give your plot appropriate title and axis labels. 
Briefly describe what you observe from the histogram from (a) and the boxplot from (d). Which plot do you think is more reasonable for this data and why?

```{r exer_1d, echo=T, eval=T}
### YOUR CODE HERE
boxplot(data, main = "Gaussian Mixture Model", xlab = "Set 1", ylab = "Numbers", col = 'blue')
### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
# The boxplot is unable to emhasize the bimodality of the distribution and as a result the histogram would be a better representation as we can more clearly see the distribution.


## Part 2. Some more density curves

### Exercise 2a. Prelude

In this warm up exercise, you will directly visualize the importance of choosing an suitable bandwidth for the density curve. First, we will start by generating 1000 samples from a Student t's distribution with 3 degrees of freedom. You will be using the function, `rt`. You should avoid naming your samples `x` due to naming conflicts with the starter code.

**Hint.** You can begin by looking up the helper page for `rt`.

Next, we will plot the density of actual Student t's distribution with 3 degrees of freedom. 
This is already done for you in the starter code.

Finally, you will plot the smoothed density curve from your generated samples using a suitable bandwidth parameter selected by you. You will overlay this density curve on top of the plot generated by the starter code displaying the true distribution. Your curve should be in another color for discernibility; set `lwd = 2` for your curve to make the line thicker. 

**Remark.** You can read more about bandwidth selection for density curves [here](https://aakinshin.net/posts/kde-bw/).

```{r exer_2a, echo=T, eval=T}
?rt
num_samples = 1000

### YOUR CODE HERE
samples = rt(num_samples, 3)
### END OF YOUR CODE

## plotting density of t dist
x = seq(-5, 5, length.out = num_samples)
y = dt(x, df=3)
graph = plot(x, y, type='l', lwd=2,
     main='True vs. estimated density for t dist.',
     xlab='x',
     ylab='density')
###

### YOUR CODE HERE
lines(density(samples, kernel = 'gaussian', bw = bw.nrd0(samples)), col = 'red', lwd = 2)
### END OF YOUR CODE
```

### Exercise 2b. 

Compute the mean, median, and standard deviation of your generated samples in (a) and include them below. Is the observed sample mean close to the observed sample median? What does that tell you? Does your intuition align with the density plot you generated?

```{r exer_2b, echo=T, eval=T}
### YOUR CODE HERE
print('Mean:') 
mean(samples)
print('Median:') 
median(samples)
print('Standard Deviation:') 
sd(samples)
### END OF YOUR CODE
```

**YOUR EXPLANATION HERE.**
The sample mean and median are very close together which indicates that the graph has no strong skew and is roughly symmetric. This intuition is consistent with the graph.

### Exercise 2c. How many clusters of galaxies?

Now, once we are all warmed up, we are ready to proceed with into subsequent steps analyzing galaxy data. The galaxy data from Roeder (1990) [Density Estimation With Confidence Sets Exemplified by Superclusters and Voids in the Galaxies](https://www.jstor.org/stable/2289993?seq=1#page_scan_tab_contents) is available in the `R` library `MASS`. 

First, we will install the `MASS` library e.g. via `install.packages()` or simply saving this file and clicking on the `install` pop-up message.

The data are the measured velocities in km/second of 82 galaxies from the Corona Borealis region. 

```{r exer_2_setup, echo=T, eval=T}
require(MASS)
gal <- galaxies/1000
plot(x = c(0, 40), y = c(0, 0.15), type = "n", bty = "l",
     main='Clusters of galaxies',
     xlab = "Velocity of galaxy (1000km/s)", ylab = "Density")

## add a 'rug' (ticks along x axis)
rug(gal)                                   

## lty controls y's appearance
lines(density(gal, bw = 6), lty = 3)      
lines(density(gal, bw = 4), lty = 2)       
lines(density(gal, bw = 2), lty = 1)    
```

A theory of how the universe formed predicts the existence of clusters of galaxies. If galaxies travel at similar speeds, then the galaxies are clumped. This suggests that multimodal data corresponds to multiple clusters of galaxies. A unimodal distribution, by contrast, is what one would expect if there were no clusters and the data were just an artifact of how the galaxies were sampled.

Therefore, we are specifically interested in the number of modes (i.e. local maxima of the density) in this data. 

The plot above includes 3 different density estimates for the data, using 3 different levels of smoothing as controlled by the bandwidth parameter.

Which bandwidth provides the clearest evidence that the galaxies are clustered? 
Which bandwidth would you choose to best represent the data and why?

**YOUR EXPLANATION HERE.**
#The line with bandwidth of 2 best indicates that the galaxies are clustered.
#I would choose bandwidth 2 in this case to reflect the data as it more acurately captures the spread without having excessive variability.

### Exercise 2d. How many clusters of galaxies, continued.

Adapt the code above and add 4th density curve that is less 'smooth' than any of present ones in the plot. Your density curve should be in red for discernibility. 

```{r exer_2d, echo=T, eval=T}
plot(x = c(0, 40), y = c(0, 0.15), type = "n", bty = "l",
     main='Clusters of galaxies',
     xlab = "Velocity of galaxy (1000km/s)", ylab = "Density")
rug(gal)                                   
lines(density(gal, bw = 6), lty = 3)      
lines(density(gal, bw = 4), lty = 2)       
lines(density(gal, bw = 2), lty = 1)

### YOUR CODE HERE
lines(density(gal,bw = 1), lty = 4, col = 'red')
### END OF YOUR CODE 
```



## Part 3. Groundhog Day

On Groundhog Day, February 2, a famous groundhog in Punxsutawney, PA is used to predict whether a winter will be long or not based on whether or not it sees its shadow. 

**Optional: an aside.** According to Wikipedia, "[This tradition] derives from the Pennsylvania Dutch superstition that if a groundhog emerges from its burrow on this day and sees its shadow, it will retreat to its den and winter will go on for six more weeks; if it does not see its shadow, spring will arrive early. This is often due to the weather being cloudy or clear allowing for the groundhog to actually have a shadow or not." 
You can read more about the tradition and view historical data [here](http://www.stormfax.com/ghogday.html).
A subset of the data on whether he saw his shadow or not is in this [table](http://stats191.stanford.edu/data/groundhog.table).

Although the groundhog (named Phil) is on the East Coast, we are interested in whether this information says anything about whether or not we will experience a rainy winter out here in California. For this, we will be looking at the rainfall data, stored in a table [here](http://stats191.stanford.edu/data/rainfall.csv).

### Excerise 3a.

To answer the question, we will first visualize the data accordingly and identify any patterns of possible interest to us.

We will make a 2 side-by-side boxplots of the average monthly precipitation (total annual rainfall / 12) in Northern California for 1) years in which Phil sees its shadow, versus 2) years in which Phil does not see its shadow.

**Hint.** 
To compute the average precipitation, check out either the `rowSums` function or the `apply` function. 
To join the two dataframes together, check out the `left_join` function from the `dplyr` library. You should be very careful which dataset comes first in the `left_join` arguments and on which columns you perform the joining operation.   
To plot multiple boxplots side-by-side, check out the `~` operator. 

```{r exer_3a, echo=T, eval=T}
require(dplyr)
shadow_url="http://web.stanford.edu/class/stats191/data/groundhog.table" 
rain_url="http://web.stanford.edu/class/stats191/data/rainfall.csv"

shadow_data = read.table(shadow_url, header=TRUE, sep=',')
## see which columns are in the shadow dataset
names(shadow_data)
head(shadow_data)
## convert `shadow` into a factor
shadow_data$shadow = as.factor(shadow_data$shadow)

### YOUR CODE HERE
#Make the rain data set
rain_data = read.csv(rain_url, header = TRUE, sep = ',')
names(rain_data)
head(rain_data)
#create average rainfall column
rain_data$avg = rowMeans(rain_data[,2:13])

#Combine the data sets
combined_data = dplyr::left_join(shadow_data, rain_data, by = join_by(year==WY))
combined_data
#Plot combined data set based on average vs. groundhog prediction.
boxplot(combined_data$avg ~ combined_data$shadow, main = "Rain Data vs. Groundhog Shadow", ylab = 'Mean Rainfall (in)', xlab = 'Groundhog Prediction (Y = Yes Shadow, N = No Shadow)', col = 'darkseagreen')
### END OF YOUR CODE
```

### Excerise 3b.

Describe your findings from your resulting plot in (a) in the context of the question, "whether this information says anything about whether or not we will experience a rainy winter out here in California".

**YOUR EXPLANATION HERE.**
#There is no significant difference in the average rainfall in a year regardless of whether or not the groundhog sees its shadow as the varition bars (spread) has an overlap

(Question 3 is adapted from Jonathan Taylor's STATS 191 course.)

