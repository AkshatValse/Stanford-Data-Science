title: "Assignment 1"
author: "STATS 101"
date: "2023-06-29"
output: pdf_document
---

In this assignment, we will compare COVID fatalities in Portugal and Colombia. We will use data of COVID cases from both countries on May 28, 2020.

The results may be **counterintuitive** and **staggering**.

Let's read in the data using `url`. This means, the data is available somewhere online, and we can read in the data without having to download it.

```{r read_data, eval=T, echo=T}
url_path = "https://raw.githubusercontent.com/dlsun/pods/master/data/covid/"

portugal_file_name = 'portugal_2020-05-28.csv'
colombia_file_name = 'colombia_2020-05-28.csv'

# append portugal_file_name to url_path (concatenating 2 strings in R)
portugal_url_name = paste0(url_path, portugal_file_name)
data_pt = read.table(url(portugal_url_name), sep=',', header=T)
head(data_pt)
```

## Exercise 1. Reading in the Colombia Data

Referencing the code above, create the url path for the Colombia dataset and load in the data.

```{r read_co_data, eval=T, echo=T}
### Your code here
colombia_url_name = NA
### End of your code

data_co = read.table(url(colombia_url_name), sep=',', header=T)
head(data_co)
```


Notice that the Colombia data is more "raw" than the Portugal data. We need to clean the data to make it look like the Portugal data.

The section below performs the data cleaning. Read the following code and run the cells below.

## Transforming a categorical variable

Each row represents a case, but there is no column that corresponds directly to fatality. We will transform the `Estado` (state) column into a fatality column. 

First, let's print out the unique values contained in the `Estado` column (a categorical variable).

```{r}
print(unique(data_co$Estado))
```

If a patient died, then their state is marked as "Fallecido" (deceased). 
There are other Estados (states), such as `Leve` (mild) and `Asintomático` (asymptomatic). 
We will replace these entries with `FALSE`s and store the result in a new column called `fatality`.

```{r cleanining_co_data, eval=T, echo=T}
# make a new column called fatality
# replace all 'Fallecido' by TRUE in this new column
# and all other values are replaced by FALSE in the new column. 
data_co$fatality = data_co$Estado == 'Fallecido'

# check results
head(data_co$fatality)
# print out the unique values in the `fatality` column
# should only contain TRUE and FALSE
print(unique(data_co$fatality))
```

## Transforming a Quantitative Variable Into a Categorical Variable

We also need to convert "Edad" (age), which is a quantitative variable in this data set, into age ranges, as in the Portugal data set. We need to first install the `tidyverse` package that has a nice function `cut` for doing so.

```{r bin_age, eval=T, echo=T}
require(tidyverse)

# convert age column in portugal dataset into a factor
data_pt$age = as.factor(data_pt$age)

# create a new age column
data_co = data_co %>% mutate(age = cut(Edad,
                             breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 120),
                             labels = c("0-9", "10-19", "20-29", "30-39", 
                                        "40-49", "50-59", "60-69", "70-79", 
                                        "80+") # new names for each of the levels
                             )
                   )
print(levels(data_co$age))
print(levels(data_pt$age))

head(data_pt)
head(data_co)
```

We see that they do indeed look consistent for both datasets after cleaning.


## Exercise 2. 

Calculate the overall fatality rate for Portugal. That is, calculate the distribution of fatality. Do the same for Colombia. What do you observe and how do they compare?

**Hint.** To compute fatality rate, we compute the number of deaths / total number of samples. Similarly, to compute the survival rate, we compute the number of survivals / total number of samples.

```{r exer2, eval=T, echo=T}
# compute fatality rate for portugal and print the results out

# compute fatality rate for colombia and print the results out

```

**YOUR EXPLANATION HERE.**



## Exercise 3a. 

Calculate the fatality rates **for each age group** for Portugal. Save the results as a new column named `fatality_rate_by_age` within a new table entitled `pt_fatality_rates`. 

**Hint.** What we want to do is to group by the age categorical variable. Check out the `group_by` function within the `tidyverse` package (link here: https://dplyr.tidyverse.org/reference/group_by.html). This might be a bit challenging, but worthwhile for you to spend time figuring out by yourself. 

**Remark.** What we are actually computing is the conditional distribution of $\mathbb{P}(\mathrm{fatality} | \mathrm{age})$; in words, this means the chance of dying conditioning on the fact (i.e. having observed that) a certain subject belongs to a particular age group. $\mathbb{P}(\mathrm{fatality} | \mathrm{age} \in [10, 19]$ means the chance of dying if the person is known to be between 10-19 years old.

```{r exer3a, eval=T, echo=T}
### Your code here

# compute fatality rate by age groups for portugal
pt_fatality_rates = NA

###
```


## Exercise 3b. 

Calculate the fatality rates **for each age group** for Colombia Save the results as a new column named `fatality_rate_by_age` within a new table entitled `co_fatality_rates`. 

```{r exer3b, eval=T, echo=T}
### Your code here

# compute fatality rate by age groups for colombia
co_fatality_rates = NA

###
```


## Exercise 4.

Make a bar plot comparing the fatality rates for each age group in Colombia and Portugal. Do you notice anything strange? Can you explain what is going on?

**Hint.**Take a look at your answer to Exercise 1.

```{r exer4, eval=T, echo=F}
# make a dataframe with both portugal and colombia data
data = as.data.frame(cbind(pt_fatality_rates$fatality_rate_by_age,
                           co_fatality_rates$fatality_rate_by_age))

# set row names for the data frame 
rownames(data) = co_fatality_rates$age
# set column names for the data frame
colnames(data) = c('co_fatality', 'pt_fatality')
# transpose the dataframe so we have age groups as x-axis and (colombia, portugal) as the two categories
data = t(data)
print(data)


### Your code here


## finally, add a legend with corresponding colors you picked for portugal and colombia 
legend('topleft', legend=c("Portugal", "Colombia"), 
       fill = c("blue","red")
)

###
```
