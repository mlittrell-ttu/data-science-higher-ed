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
# **mutate()** creates or changes columns. We fix the two problem types:
#   INSTITUTION_ID -> character (it's a label)
#   AWARD_LVL      -> ordered factor with readable labels
#
# AWARD_LVL is coded as numbers and its categories have a meaningful rank (a
# bachelor's > associate's etc.).
# We turn it into an ORDERED factor: factor() takes the levels in rank order,
# readable labels for each, and ordered = TRUE. This makes the codes
# human-readable (5 -> "Bachelor's") and preserves the hierarchy.
# An ordered factor shows as <ord> in glimpse() instead of <fct>.
#
inst_award_data_totals <- inst_award_data_totals |>
  mutate(
    INSTITUTION_ID = as.character(INSTITUTION_ID),
    AWARD_LVL = factor(
      AWARD_LVL,
      levels = c(11, 12, 2, 3, 5, 10, 7, 9),
      labels = c(
        "Cert <12wks",
        "Cert 12wks-1yr",
        "Cert 1-4yrs",
        "Associate's",
        "Bachelor's",
        "Postbacc cert",
        "Master's",
        "Doctoral"
      ),
      ordered = TRUE
    )
  )


# Inspect the results:
glimpse(inst_award_data_totals)

# See the levels:
levels(inst_award_data_totals$AWARD_LVL)

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
  filter(AWARD_LVL == "Bachelor's")

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
inst_award_data_totals <- inst_award_data_totals |>
  mutate(total_reported = ifelse(TOTAL < 5, NA, TOTAL))

# Confirm we created some missing values.
# `$` is the extract operator. It pulls columns out of data
sum(is.na(inst_award_data_totals$total_reported))

# To see missing values across the whole dataset at once, wrap colSums() around
# is.na(). This counts the NAs in every column so you can spot which variables
# have gaps and which are complete.
colSums(is.na(inst_award_data_totals))

#________________________________________________________
# **Group and summarize with the missing-value problem**
# **group_by()** splits the data into groups. **summarize()** collapses each group 
# to a single row. Together they answer "what is the average within each group?"
# Here we ask for the mean of total_reported by award level.
#
# Notice this results in any group with even one missing value returning as NA. 
# A single unknown value makes the true average unknowable, so R will not guess 
# unless we tell it to.
inst_award_data_totals |>
  group_by(AWARD_LVL) |>
  summarize(avg_reported = mean(total_reported))


#________________________________________________________
# **Handle missing with na.rm = TRUE**
# The fix is the na.rm argument ("NA remove"). Setting it to TRUE drops the
# missing values before calculating, so the average is taken over what remains.
inst_award_data_totals |>
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



#________________________________________________________
# **Rename and relocate columns**
# rename() changes a column's name with the syntax rename(new = old). Here we
# give TOTAL a clearer name. relocate() moves a column to a new position using
# .before or .after. Neither changes the data itself.
bachelors <- bachelors |>
  rename(completions = TOTAL) |>
  relocate(completions, .after = INSTITUTION_ID)

glimpse(bachelors)


#________________________________________________________
# **Find unique values with distinct()**
# distinct() returns only unique rows. Given one or more columns, it returns the
# unique combinations found in them. Here we confirm how many distinct award
# levels appear in the full dataset.
inst_award_data_totals |>
  distinct(AWARD_LVL)


#________________________________________________________
# **Combine tables with a join**
# Sometimes data are distributed amongst different tables. These can be merged
# with joins, where data are matched on a shared column.
# So far our data has institution ID numbers but no names. Institution names
# live in a different IPEDS table, dir_info2020. The join here combines two 
# tables by matching on the shared INSTITUTION_ID.

# See the columns available in the dataset
glimpse(dir_info2020)

# left_join() keeps every row of the first (left) table and attaches matching
# columns from the second. We first select just the name and state from the
# directory, then join them onto our bachelor's data.
dir_info <- dir_info2020 |>
  select(INSTITUTION_ID, INSTITUTION, STATE)

# The IDs must be the same type to match. We made INSTITUTION_ID a character
# earlier, so we align the directory's ID to character as well.
dir_info <- dir_info |>
  mutate(INSTITUTION_ID = as.character(INSTITUTION_ID))

bachelors_named <- bachelors |>
  left_join(dir_info, by = "INSTITUTION_ID")

glimpse(bachelors_named)


#________________________________________________________
# **Put it together: which schools grant the most bachelor's degrees?**
# Now that names are attached, we can sort and read the result plainly.
bachelors_named |>
  arrange(desc(completions)) |>
  slice(1:10)
