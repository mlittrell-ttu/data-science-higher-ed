#________________________________________________________
# Title:    Exploratory Data Analysis
# Purpose:  Clean, reshape, and explore a small student dataset
#________________________________________________________


#________________________________________________________
# **Setup**
# We use the tidyverse (which includes dplyr, tidyr, and ggplot2) throughout.
library(tidyverse)


#________________________________________________________
# **Load the student data**
# We read the dataset straight from the resource's GitHub repository -- no
# download needed. read_csv() accepts a web address just as it accepts a file
# path. It is a small, made-up dataset of 50 students with a few deliberate
# problems and patterns to discover.
students <- read_csv("https://raw.githubusercontent.com/mlittrell-ttu/data-science-higher-ed/main/data/chp_6_student.csv")

glimpse(students)

glimpse(students)
