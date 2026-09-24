#________________________________________________________
# Title:    Exploratory Data Analysis
# Purpose:  Clean, reshape, and explore a small student dataset
#________________________________________________________


#________________________________________________________
# **Setup**
# We use the tidyverse (which includes dplyr, tidyr, and ggplot2) throughout.
library(tidyverse)
library(skimr)


#________________________________________________________
# **Load the student data**
# We read the dataset straight from the resource's GitHub repository -- no
# download needed. read_csv() accepts a web address just as it accepts a file
# path. It is a small, made-up dataset of 50 students with a few deliberate
# problems and patterns to discover.
students <- read_csv("https://raw.githubusercontent.com/mlittrell-ttu/data-science-higher-ed/main/data/chp_6_student.csv")

#glimpse() shows us the structure and data types
glimpse(students)


#________________________________________________________
# **First look: what's in here and what's off?**
# glimpse() gave us the structure. Now we scan for issues. summary() reports
# the min, max, mean, and quartiles of each numeric column, which is a fast way
# to spot values that shouldn't exist.
summary(students)



# Two things look wrong. gpa has a maximum of 5.20, but GPA we know for our 
# context, it should max out at 4.0.

# And hours_studied has a negative minimum, which is from our contextual knowledge
# we know that negative hours would not be recorded.
# Possibly these are data-entry errors to fix.


#________________________________________________________
# **See the problems, don't just read them**
# The summary tells us something is off, but a picture makes it obvious. A box
# plot draws the middle half of the data as a box and flags unusual points as
# dots far from it. We plot hours_studied to see the impossible negative value.
# (More on how ggplot works in the front matter; for now, notice the shape.)
ggplot(students, aes(y = hours_studied)) +
  geom_boxplot()

# The lone dot well below the box is our negative value -- visually obvious in a
# way the number alone was not. This is the back-and-forth of EDA: the summary
# raised a flag, the plot confirmed and located it.




#________________________________________________________
# **Find the bad values**
# Before fixing anything, we look at the offending rows so we know what we're
# dealing with. filter() keeps rows meeting a condition -- here, the impossible
# ones.
students |> filter(gpa > 4.0)

students |> filter(hours_studied < 0)


#________________________________________________________
# **Fix the bad values**
# How you fix a bad value is a judgment call. Sometimes you can correct it if
# you know the true value; often you don't, so you mark it missing (NA) and
# handle it like any other missing value later.
#
# Here we treat both impossible values as unknown and set them to NA. We use
# mutate() to change the columns, and ifelse() to target only the bad values:
# where the condition is TRUE, insert NA; otherwise keep the original value.
students <- students |>
  mutate(
    gpa = ifelse(gpa > 4.0, NA, gpa),
    hours_studied = ifelse(hours_studied < 0, NA, hours_studied)
  )

# Confirm the fix: the impossible values are gone from the summary.
summary(students)
