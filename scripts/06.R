#________________________________________________________
# Title:    Exploratory Data Analysis
# Purpose:  Clean, reshape, and explore a small student dataset
#________________________________________________________


#________________________________________________________
# **Setup**
# We use the tidyverse (which includes dplyr, tidyr, and ggplot2) throughout.
library(tidyverse)


#________________________________________________________
# **Build a small dataset to work with**
# Instead of loading a file, we will create a small student dataset by hand.
# This lets us plant a few realistic problems and patterns to discover. We use
# `set.seed()` so the random parts come out the same every time you run it. More
# details are covered for this function and others in the simulation module.


# Our data has 50 students across three majors, with a GPA, credits enrolled,
# and hours studied per week. We deliberately build in some things:
#   - a cluster of part-time students in one major (low credits)
#   - a right-skewed "hours studied" variable (most study a little, a few a lot)
#   - a couple of impossible values to catch and fix later
#   - a few missing values
set.seed(1234)

# Don't worry much about any complexity here that you have yet to cover if you 
# are following straight through the resource modules.
# Basically, 
students <- tibble(
  student_id = 1:50,
  major = sample(c("Biology", "Business", "Nursing"), 50, replace = TRUE),
  gpa = round(rnorm(50, mean = 3.0, sd = 0.4), 2),
  credits = sample(c(3, 6, 9, 12, 15), 50, replace = TRUE),
  hours_studied = round(rexp(50, rate = 0.15))
)

# Plant a part-time cluster: make Nursing students mostly low-credit.
students$credits[students$major == "Nursing"] <- sample(c(3, 6), sum(students$major == "Nursing"), replace = TRUE)

# Plant two impossible values: a GPA above 4.0 and a negative hours value.
students$gpa[3] <- 5.2
students$hours_studied[7] <- -4

# Plant a few missing values in gpa.
students$gpa[c(10, 22, 35)] <- NA

# Look at what we built.
glimpse(students)