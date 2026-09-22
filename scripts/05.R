#________________________________________________________
# Title:    Preprocessing with dplyrr
# Purpose:  Load, inspect, and clean IPEDS degree completions data
#________________________________________________________


#________________________________________________________
# We need some data to work with in this chapter. One source of data can come 
# from packages themselves. We will install the **IPEDS** package and use data 
# that are built in there. These data are a product of the surveys discussed in 
# Chapter 2. After installing and loading the package, simply call the dataset 
# with its name. 

# **Install and load packages**
install.packages("IPEDS")   # only once
library(IPEDS)              # each session
library(tidyverse)

# See what datasets come with the package
data(package = "IPEDS")


#________________________________________________________
# **Bring in the data**
# IPEDS data are built in, so we can call them by name with no file path.
# A good habit to develop is assigning data directly to an object in your device's 
# memory leaving the original untouched.
inst_award_data <- complete2020

# Inspect the data visually in RStudio's data browser
View(inst_award_data)


#________________________________________________________
# **Know the unit of analysis (UOA)**
# An important understanding to grasp for any dataset is what is represented as 
# the **unit of analysis** (UOA). This knowledge helps determine the questions 
# that can be asked and how data are to be handled. The UOA in the complete2020 
# is not the institution or the student—as one might expect—but is combination 
# of the institution and award level. Each row representes one award level 
# (e.g., bachelor's degree) at one institution. This explains why institution 
# IDs are repeated in the first column, once for each award level. You can 
# inspect visually with `view(inst_award_data)`.



#________________________________________________________
# **Know what the variables mean**
# Variable meanings can be opaque in large official datasets. See the full
# key with: ?complete2020
#
#   Variable(s)          What it represents
#   INSTITUTION_ID       Unique institution ID (repeats, one row per award level)
#   AWARD_LVL            Degree level, coded as a number
#                        (3 = associate, 5 = bachelor, 7 = master, 9 = doctoral)
#   TOTAL                Total completions for that institution-award level
#   TOTAL_M, TOTAL_W     Completions by gender
#   TOTAL_<race>         Each race column per group (e.g. TOTAL_ASIAN)
#   AGE<band>            Each age column per band(e.g. AGE18_24)


#________________________________________________________
# **Look at the structure**
# Looking at the data with glimpse() is often helpful.
# glimpse() shows dimensions, every column, its type, and sample values.
# Here we have 15,937 rows with 19 variables. Every variable is <int>, which is 
# likely not not helpful. INSTITUTION_ID is a label and AWARD_LVL is 
# a category, not numbers we'd do math on.
glimpse(inst_award_data)


#________________________________________________________
# **Select the columns to work with**
# Perhaps we are only interested in a certain subset of the data.
# **select()** picks columns by name and excludes the rest. We narrow to the two
# identifiers plus TOTAL, saving to a new object so the full data persists 
# separately.
inst_award_data_totals <- inst_award_data |>
  select(INSTITUTION_ID, AWARD_LVL, TOTAL)

glimpse(inst_award_data_totals)


#________________________________________________________
# **Fix the data types with mutate()**
# **mutate()** creates or changes columns. We pair it with the as.*() conversion
# functions from the previous chapter to fix the two problem types:
#   INSTITUTION_ID -> character (it's a label)
#   AWARD_LVL      -> factor    (it's fixed categories)
# Assigning it back to the data with `<-` makes the change remain in dataset.
inst_award_data_totals <- inst_award_data_totals |>
  mutate(
    INSTITUTION_ID = as.character(INSTITUTION_ID),
    AWARD_LVL = as.factor(AWARD_LVL)
  )

# Confirm the types.
glimpse(inst_award_data_totals)


#________________________________________________________
# **Summarize to spot problems**
# **summary()** gives a quick overview of each column. For numbers it shows min,
# max, mean, and quartiles. For factors, it shows counts per level. Here we have 
# a quick way to catch impossible values or check the spread of a variable.
summary(inst_award_data_totals)


#____________________________
# Two potential issues stand out. TOTAL ranges from 1 to 24,676, and its mean (313.8) is
# far above its median (68). Possibly some very large institutions are stretching the
# average. And AWARD_LVL shows the counts are spread across many levels, so this
# TOTAL summary is mixing bachelor's, master's, associate's, and more together.
# To make TOTAL meaningful, we could look at one award level at a time.

#> summary(inst_award_data_totals)
#>    INSTITUTION_ID    AWARD_LVL        TOTAL        
#>  Length   :15937   2      :3649   Min.   :    1.0  
#>  N.unique : 6124   12     :2702   1st Qu.:   19.0  
#>  N.blank  :    0   3      :2464   Median :   68.0  
#>  Min.nchar:    6   5      :2366   Mean   :  313.8  
#>  Max.nchar:    6   7      :1931   3rd Qu.:  247.0  
#>                    9      :1076   Max.   :24676.0  
#>                    (Other):1749 



#________________________________________________________
# **Filter to one award level with filter()**
# **filter()** keeps only rows meeting a condition. We keep just bachelor's degrees
# (level "5" as AWARD_LVL is now a factor). Now every row is one
# institution's bachelor's completions, so TOTAL is comparable across rows. 
bachelors <- inst_award_data_totals |>
  filter(AWARD_LVL == "5")

glimpse(bachelors)

# Re-summarize now that we're looking at a single level.
summary(bachelors)



#________________________________________________________
# **Sort rows with arrange()**
# **arrange()** orders rows by a column. By default it sorts ascending (smallest
# first). Wrap a column in desc() to sort in descending order. Here we see the
# institutions granting the most bachelor's degrees.

# We then pass the result to slice(), a non-core verb that selects rows by their
# row number (aka postion). The sequence operator ":" builds a sequence of
# numbers. 1:10 means 1, 2, 3 ... 10—giving us the top 10 rows once the
# data is sorted largest-first.

bachelors |>
  arrange(desc(TOTAL)) |>
  slice(1:10)


#________________________________________________________
# **Create a variable with missing values**
# **NA** is R's way of marking missing or unknown values.
# Institutional data can be incomplete on purpose, where if group data is very
# small, institutions may suppress the count so no individual can be identified
# as mentioned for the FERPA privacy concern from Chapter 2. We can simulate 
# that here to see how missing data behaves, as inspecting data for missing values
# is essential to preprocessing. Building realistic fake data for learning like 
# this is called simulation and it is covered more completely in a later chapter.
#
# We do it with an **if-else statement**, which asks a yes-or-no question of each
# value and returns one result for yes and another for no. The ifelse()
# function takes three arguments in order: the condition, the value if TRUE,
# and the value if FALSE. Here, wherever TOTAL is under 5, we insert NA to
# mark it suppressed. Otherwise, we keep TOTAL.
inst_award_data <- inst_award_data |>
  mutate(total_reported = ifelse(TOTAL < 5, NA, TOTAL))

# Confirm we created some missing values.
sum(is.na(inst_award_data$total_reported))



#________________________________________________________
# **Group and summarize with the missing-value problem**
# **group_by()** splits the data into groups. **summarize()** collapses each group 
# to a single row. Together they answer "what is the average within each group?"
# Here we ask for the mean of total_reported by award level.
#
# Notice this results in any group with even one missing value returning as NA. 
# A single unknown value makes the true average unknowable, so R will not guess 
# unless we tell it to.
inst_award_data |>
  group_by(AWARD_LVL) |>
  summarize(avg_reported = mean(total_reported))


#________________________________________________________
# **Handle missing with na.rm = TRUE**
# The fix is the na.rm argument ("NA remove"). Setting it to TRUE drops the
# missing values before calculating, so the average is taken over what remains.
inst_award_data |>
  group_by(AWARD_LVL) |>
  summarize(avg_reported = mean(total_reported, na.rm = TRUE))


#________________________________________________________
# Use`na.rm = TRUE` thoughtfully, not automatically. Dropping missing is often 
# acceptable when they occur randomly, but misleading when they are not.

# MCAR (missing completely at random): MCAR NAs are unrelated to anything known. 
# For example, courses dropped at random for no known contextual reason. 
#
# MAR (missing at random): MAR NAs depend on something you can know, like one
# campus recording a field less reliably. This can be addressed but ignoring can 
# bias comparisons.
#
# MNAR (missing not at random): MNAR NAs are values that are missing because of 
# what the value would have been if it were included. Our suppressed counts demonstrate 
# this as it reflected small programs. In this instance, dropping the observations 
# with NAs might delete all the small programs, pushing averages up and only
# accounting for larger programs.
