#________________________________________________________
# Title:    Exploratory Data Analysis
# Purpose:  Clean, reshape, and explore a small student dataset
#________________________________________________________


#________________________________________________________
# **Setup**
# We use the tidyverse (which includes dplyr, tidyr, and ggplot2) throughout.
library(tidyverse)
library(skimr) #Also install skimr if you have not.


#________________________________________________________
# **Load the student data**
# We read the dataset straight from the website's GitHub repository -- no
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



# Two things look potentially off. gpa has a maximum of 5.20, but GPA we know from our 
# hypothetical contextual knowledge, it should max out at 4.0.

# And hours_studied has a negative minimum, which from our contextual knowledge,
# we know that negative hours would not be recorded.
# Possibly these are data-entry errors to fix.

#________________________________________________________
# **A closer look with skimr**
# The skimr package offers skim(), which gives a fuller summary than summary().
# For each variable it reports missing counts, means, standard deviations, and
# even small inline histograms. It is a helpful way to see the state of the data
# after our fixes, including how many missing values we now have.
skim(students)



#________________________________________________________
# **See the issues visually*
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
# **Find the values with issues**
# Before fixing anything, we look at the potentially problematic rows so we know what we're
# dealing with. filter() keeps rows meeting a condition. Here, the ones outside the range
# of what we know could be entered.
students |> filter(gpa > 4.0)

students |> filter(hours_studied < 0)


#________________________________________________________
# **Fix the values**
# How you fix a value is largely context dependent. 
# Perhaps you know the true value and correct it, but you may not. 
# One approach may be to mark it as missing (NA) and fix it along with any other
# missing values. 
#
# Here we treat both values outside the range as unknown and set them to NA. We use
# mutate() to change the columns, and ifelse() to target only the values with issues.
# Ifelse works on a condition. If it is True do the firs thing (set it to NA),
# Else, do the second thing keep the original value found in gpa.

students <- students |>
  mutate(
    gpa = ifelse(gpa > 4.0, NA, gpa),
    hours_studied = ifelse(hours_studied < 0, NA, hours_studied)
  )

# Confirm the missing values
summary(students)


#________________________________________________________
# **Handling missing values**
# Our two fixes converted values outside our expected range into NA, so those
# join any missing values that were already present. Handling missing data
# is a judgment that depends on the context and goals of the work. There is
# no single correct choice, and different approaches carry different trade-offs.
#
# One common approach is imputation, which means filling in a missing value with
# an estimate. Here we look at two simple options and what each one does to the
# data.

# First, we see which gpa values are missing.
students |> filter(is.na(gpa))



#________________________________________________________
# **Mean imputation**
# Mean imputation replaces each missing value with the mean of the values that
# are present. It is simple and keeps every row, but it also pulls values toward
# the center. This can make the data look less variable than it really is.
#
# We compute the mean of the present gpa values with na.rm = TRUE so the missing
# values are ignored in the calculation, then use it to fill the gaps.
gpa_mean <- mean(students$gpa, na.rm = TRUE)

students_mean_imp <- students |>
  mutate(gpa = ifelse(is.na(gpa), gpa_mean, gpa))

# The missing gpa values are now filled with the mean.
skim(students_mean_imp)


#________________________________________________________
# **Median imputation**
# Median imputation fills the gaps with the median instead of the mean. Because
# the median is less affected by extreme values, this can be a better fit when
# the data are skewed. Like mean imputation, it keeps every row, and it also
# reduces the natural variation in the data.
gpa_median <- median(students$gpa, na.rm = TRUE)

students_median_imp <- students |>
  mutate(gpa = ifelse(is.na(gpa), gpa_median, gpa))

skim(students_median_imp)


#________________________________________________________
# **Which one?**
# Neither imputation is automatically right. Each one changes the data to serve
# a purpose, and the better choice depends on the context, the variable, and
# what you plan to do next. Whatever you choose, it is worth noting that the
# values were imputed, since the filled-in numbers are estimates rather than
# observations. You can see them in your environment and compare the value that
# was used, as info on which might be helpful.
gpa_mean
gpa_median

#For this demonstration we will go ahead and assign the mean value to our main
# dataset:

students <- students |>
  mutate(gpa = ifelse(is.na(gpa), gpa_mean, gpa))

# The missing gpa values are now filled with the mean.
skim(students)



#________________________________________________________
# **Reshaping to solve summary and join problems**
# Reshaping is something we when the shape of some data gets in the way of the work. 
# A common case is when data arrives in a
# shape that will not summarize or join cleanly onto what we already have.


#________________________________________________________
#pivot_longer()
# **Case 1: wide data we need to make long for summary**
# Suppose we receive attendance counts for three campus events, with each event
# as its own column. The event is really a variable, but here it is stuck in the
# column names. We only have data for a few students for this example.
events_wide <- tibble(
  student_id  = c(1, 2, 3, 4),
  orientation = c(1, 0, 1, 1),
  career_fair = c(0, 1, 1, 0),
  study_night = c(1, 1, 0, 1)
)

events_wide

# The problem: to summarize attendance by event, or to store one attendance
# record per student-event, we need the event names in the data, not in the
# column headers. pivot_longer() moves them into the data.

# What pivot_longer() does:
#   - Takes a wide dataset (many columns) and makes it long (more rows)
#   - Column names become values in a new column
#   - Cell values go into another new column
#   - Columns you dont pivot get repeated for each new row

# Use cases?
#   - When a variable is stored in the column names instead of the data
#   - Common with data recorded one column per time period, term, or category
#   - When you want to group, summarize, or plot across those columns

events_long <- events_wide |>
  pivot_longer(
    cols = orientation:study_night,   # the event columns to gather
    names_to = "event",               # event names go into a new "event" column
    values_to = "attended"            # the 0/1 values go into an "attended" column
  )

events_long

# Now the data is in a tidy one-row-per-student-per-event shape. We can summarize
# attendance by event, which may not have suited our needs in the wide layout.
events_long |>
  group_by(event) |>
  summarize(times_attended = sum(attended))


#________________________________________________________
#pivot_wider
# **Case 2: long data we need to make wide, then join**
# Now suppose we receive survey responses in a long shape, with one row per
# student per question. To join a student's answers onto our one-row-per-student
# data, we need each question to be its own column. Again, we only have a few
# students here.

#
# What pivot_wider() does:
#   - Takes a long dataset (many rows) and makes it wide (more columns)
#   - Values from one column become new column names
#   - Values from another column fill those new columns
#   - Opposite of pivot_longer()

# Use cases?
#   - When one observation is scattered across multiple rows
#   - Common with survey data, evaluation forms, repeated measures
#   - When you want to compare values side-by-side

survey_long <- tibble(
  student_id = c(1, 1, 2, 2, 3, 3),
  question   = c("belonging", "advising", "belonging", "advising",
                 "belonging", "advising"),
  rating     = c(4, 5, 3, 4, 5, 5)
)

survey_long

# The problem is this shape has multiple rows per student, so it will not join
# cleanly onto our one-row-per-student data. pivot_wider() spreads the questions
# into their own columns, giving one row per student.
survey_wide <- survey_long |>
  pivot_wider(
    names_from = question,   # the question names become column names
    values_from = rating     # the ratings fill those new columns
  )

survey_wide


#________________________________________________________
# **Join the reshaped data onto students**
# Both reshaped tables now have one row per student, keyed by student_id, so
# they will join cleanly. We attach the survey answers here. A left_join keeps
# all of our students and adds the new columns, leaving NA where a student has
# no matching survey response.
students <- students |>
  left_join(survey_wide, by = "student_id")

glimpse(students)


#________________________________________________________
# **Exploring with dplyr**
# The same verbs we used to clean the data can also help us explore it. Cleaning
# and exploring are not separate toolkits. We use filter, arrange, and summarize
# to ask questions of the data and start building a sense of what is there.


#________________________________________________________
# **Sorting to see the extremes**
# arrange() orders rows by a column. Sorting by gpa lets us see the students at
# the low and high ends, which is often where interesting cases sit. desc()
# sorts from high to low.
students |>
  arrange(desc(gpa)) |>
  print(n = Inf)

# Sorting the other direction shows the lowest values.
students |>
  arrange(gpa) |>
  print(n = Inf)


#________________________________________________________
# **Filtering to a group of interest**
# filter() keeps rows meeting a condition, which lets us focus on a subset for
# a closer look. Here we look at students carrying a light credit load, who an
# advisor might want to check in with.
students |>
  filter(credits <= 6)

#________________________________________________________
# **Filtering and sorting together**
# The verbs combine in a pipe, so we can filter to a subset and then order it in
# one flow. Here we keep the students carrying a light credit load, then sort
# them by gpa so an advisor could scan from lowest to highest while deciding who
# to check in with first.
students |>
  filter(credits <= 6) |>
  arrange(gpa)


#________________________________________________________
# **Summarizing the whole dataset**
# summarize() collapses many rows into summary values. Here we compute a few
# measures of center and spread for gpa across all students. Because we already
# handled the missing values, we do not need na.rm here.
students |>
  summarize(
    mean_gpa   = mean(gpa),
    median_gpa = median(gpa),
    sd_gpa     = sd(gpa)
  )


#________________________________________________________
# **Summarizing by group**
# The real utility of summarize() shows when paired with group_by(). This
# splits the data into groups and computes the summary within each one. Here we
# look at how credit load differs by major, which is a question the numbers can
# begin to answer.
students |>
  group_by(major) |>
  summarize(
    n_students  = n(),
    mean_credits = mean(credits),
    median_credits = median(credits)
  )


#________________________________________________________
# **Focusing the view with select()**
# When a table has many columns, select() narrows to the ones we care about for
# a given question. Here we look at just the identifying and academic columns,
# which makes a wide table easier to read.
students |>
  select(student_id, major, gpa, credits)


#________________________________________________________
# **Building a new column with mutate()**
# mutate() adds a column computed from existing ones. Here we create a simple
# flag for full-time status, treating 12 or more credits as full-time. This
# turns a raw number into a label we can group and filter on.
students |>
  mutate(status = ifelse(credits >= 12, "full-time", "part-time")) |>
  select(student_id, major, credits, status)


#________________________________________________________
# **Pulling the top rows with slice_max()**
# slice_max() returns the rows with the highest values of a column. It answers
# "which are the top few?" without needing to sort the whole table by hand. Here
# we pull the five students with the highest gpa.
students |>
  slice_max(gpa, n = 5)


#________________________________________________________
# **Counting categories with count()**
# count() is a shortcut for grouping by a column and tallying how many rows fall
# in each group. Here we count how many students are in each major.
students |>
  count(major)


#________________________________________________________
# **Combining verbs to answer a question**
# The verbs are useful together. Here we ask a fuller question in one flow:
# among part-time students, how does gpa compare across majors? We build the
# status flag, keep the part-time students, group by major, and summarize.
students |>
  mutate(status = ifelse(credits >= 12, "full-time", "part-time")) |>
  filter(status == "part-time") |>
  group_by(major) |>
  summarize(
    n_students = n(),
    mean_gpa   = mean(gpa)
  )


#________________________________________________________
# **Seeing the data with ggplot2**
# Numbers describe the data, and pictures let us inspect it visually. 
# We build plots with
# ggplot2, layering a few pieces: the data, an aesthetic mapping that connects 
# columns to parts of the plot, and a geom that draws the shape. 
# The front matter covers the pieces in more detail. Here we put a few to work 
# on our students data.


#________________________________________________________
# **A histogram to see a distribution's shape**
# A histogram groups a numeric variable into bins and counts each one, which
# shows the shape of the distribution. Here we look at hours_studied to see how
# study time is spread across students. Notice the warning in the console about
# the missing value we created earlier.
ggplot(students, aes(x = hours_studied)) +
  geom_histogram(bins = 8) # change this number to see different bin sizes

# The shape leans to the right. Most students cluster at lower study hours, with
# a few reaching much higher.


#________________________________________________________
# **A box plot to compare groups**
# A box plot summarizes a numeric variable and is good for comparing
# groups side by side. Here we compare gpa across majors. Each box shows the
# middle half of that major's values, the line marks the median, and dots mark
# points that sit far from the rest.
ggplot(students, aes(x = major, y = gpa)) +
  geom_boxplot()

# Comparing the boxes gives a quick read on how gpa differs across majors, both
# in typical value and in spread.


#________________________________________________________
# **From a picture to the numbers with real data**
# Exploratory work moves back and forth between pictures and numbers. A picture
# can surface something unexpected, and the numbers let us investigate it. To
# see this, we return to the admissions data from the IPEDS package that we used
# for the earlier plot examples.
library(IPEDS)
admissions <- adm2020


#________________________________________________________
# **The picture**
# We plot applications received against students admitted. Each point is one
# institution.
ggplot(admissions, aes(x = APPLCN, y = ADMSSN)) +
  geom_point(alpha = 0.4)

# Most points fall along a rising band where institutions that receive more
# applications tend to admit more students. But a few points sit apart from that
# band and are worth a closer look.
#
# In the far upper right, one institution sits high above the rest, with a very
# large number of both applications and admissions. In the lower right, a few
# institutions received many applications but admitted comparatively few.


#________________________________________________________
# **Add institution names**
# The admissions data identifies schools by an ID number, not a name, which
# makes any result hard to read. The names live in a different IPEDS table,
# dir_info2020. We join the name onto the admissions data by the shared
# INSTITUTION_ID, so our later results are readable.
names_lookup <- dir_info2020 |>
  select(INSTITUTION_ID, INSTITUTION)

admissions <- admissions |>
  left_join(names_lookup, by = "INSTITUTION_ID")

#________________________________________________________
# **Identify the point highest on the y-axis**
# One point sits far up the vertical axis, admitting a very large number of
# students. That is the institution with the most admissions, so slice_max() on
# ADMSSN returns it.
admissions |>
  slice_max(ADMSSN, n = 1) |>
  select(INSTITUTION, APPLCN, ADMSSN)



#________________________________________________________
# **Identify the point farthest right on the x-axis**
# A different point sits far to the right, receiving the most applications, yet
# it does not sit as high, because it admits a smaller share. That is the
# institution with the most applications, found with slice_max() on APPLCN.
admissions |>
  slice_max(APPLCN, n = 1) |>
  select(INSTITUTION, APPLCN, ADMSSN)



#________________________________________________________
# **Looking at the whole far-right group**
# Rather than a single point, a cluster of institutions sits to the far right of
# the plot, each receiving a very large number of applications. We can pull the
# whole group at once by filtering to institutions above a high application
# count, then sorting them from most applications to least. This lets us see who
# these large schools are and compare them side by side.
admissions |>
  filter(APPLCN > 70000) |>
  select(INSTITUTION, APPLCN, ADMSSN) |>
  arrange(desc(APPLCN))

# Notice these large schools do not all behave the same way. Some admit a large
# share of their many applicants while others admit far fewer, so size alone
# does not tell us about selectivity. The plot grouped them together by
# application count, and the numbers reveal the variety within that group.



#________________________________________________________
# **Investigating the selective points**
# Some points received many applications but admitted comparatively few, a sign
# of high selectivity. These are not just the points farthest right as a school
# can sit mid-range on applications and still admit a small share. To find them,
# we build a simple admit rate with mutate(), keep institutions with many applications, and
# sort by the lowest rates.
admissions |>
  mutate(admit_rate = ADMSSN / APPLCN) |>
  filter(APPLCN > 20000) |>
  arrange(admit_rate) |>
  select(INSTITUTION, APPLCN, ADMSSN, admit_rate) |>
  slice_head(n = 10)

# The picture pointed us toward these institutions, and the numbers named and
# described them. Notice that "largest" and "most selective" are different
# questions with different answers. The school with the most applications is not
# the same as the school that admits the smallest share. A single plot can hold
# several stories, and which one we see depends on the question we bring to it.
