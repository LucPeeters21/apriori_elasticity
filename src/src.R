# import libraries
library(dplyr)
library(arules)
library(arulesViz)
library(lubridate)
library(ggplot2)

#####################
## data generation ##
#####################

# Create a sequence of dates for the whole year
dates <- seq(as.Date("2018-01-01"), as.Date(Sys.time()), by = "day")

#### generate transaction data ####

# Define the interval for the random number of transactions per day
min_transactions <- 50  # Minimum number of transactions per day
max_transactions <- 150 # Maximum number of transactions per day

# Generate random number of transactions per day
num_transactions <- sample(min_transactions:max_transactions, length(dates), replace = TRUE)

# generate transaction data
transaction_data <- data.frame(
  Date = rep(dates, num_transactions),  # Random transactions per day
  Transaction_ID = 1:(sum(num_transactions)),      # Unique transaction IDs
  Q_A = sample(0:1, sum(num_transactions), replace = TRUE),  # Random quantities of Product A (0 to 1)
  Q_B = sample(0:1, sum(num_transactions), replace = TRUE),  # Random quantities of Product B (0 to 1)
  Q_C = sample(0:1, sum(num_transactions), replace = TRUE),  # Random quantities of Product C (0 to 1)
  Q_D = sample(0:1, sum(num_transactions), replace = TRUE),  # Random quantities of Product D (0 to 1)
  Q_E = sample(0:1, sum(num_transactions), replace = TRUE),  # Random quantities of Product E (0 to 1)
  Q_F = sample(0:1, sum(num_transactions), replace = TRUE),  # Random quantities of Product F (0 to 1)
  Quarter = quarter(rep(dates, num_transactions)),           # Quarter of the year
  DayOfWeek = weekdays(rep(dates, num_transactions))          # Day of the week
)

# Create a basket column based on product frequency in each transaction
transaction_data$Basket <- apply(transaction_data[, c("Q_A", "Q_B", "Q_C", "Q_D", "Q_E", "Q_F")], 1, function(x) {
  products <- c(rep("A", x["Q_A"]), rep("B", x["Q_B"]), rep("C", x["Q_C"]), rep("D", x["Q_D"]), rep("E", x["Q_E"]), rep("F", x["Q_F"]))
  paste(products, collapse = "")
})

# Remove trailing whitespace from the 'basket' column
transaction_data$Basket <- gsub("\\s", "", transaction_data$Basket)

#### generate price data ####
price_data <- data.frame(
  Date = dates,                                                # Dates for the whole year
  P_A = sample(8:12, length(dates), replace = TRUE),      # Random prices for Product A (8 to 12)
  P_B = sample(18:22, length(dates), replace = TRUE),     # Random prices for Product B (18 to 22)
  P_C = sample(13:17, length(dates), replace = TRUE),      # Random prices for Product C (13 to 17)
  P_D = sample(9:12, length(dates), replace = TRUE),      # Random prices for Product A (9 to 12)
  P_E = sample(15:16, length(dates), replace = TRUE),     # Random prices for Product B (15 to 16)
  P_F = sample(11:13, length(dates), replace = TRUE),      # Random prices for Product C (11 to 13)
  Quarter = quarter(dates),                                    # Quarter of the year
  DayOfWeek = weekdays(dates)                                  # Day of the week
)

# Add the total amount spent to the transaction data
merged_data <- merge(transaction_data, price_data, by = "Date", all.x = TRUE)
merged_data$TotalAmountSpent <- (merged_data$Q_A * merged_data$P_A) +
  (merged_data$Q_B * merged_data$P_B) +
  (merged_data$Q_C * merged_data$P_C) +
  (merged_data$Q_D * merged_data$P_D) +
  (merged_data$Q_E * merged_data$P_E) +
  (merged_data$Q_F * merged_data$P_F) 
transaction_data$TotalAmountSpent <- merged_data$TotalAmountSpent

# Add the total demand per product per day to the price data
sales_per_day <- aggregate(cbind(Q_A, Q_B, Q_C, Q_D, Q_E, Q_F) ~ Date, data = transaction_data, sum)
price_data <- merge(price_data, sales_per_day, by = "Date", all.x = TRUE)
price_data <- price_data %>% select(Date, DayOfWeek, Quarter, P_A, Q_A, P_B, Q_B, P_C, Q_C, P_D, Q_D, P_E, Q_E, P_F, Q_F)

# remove sales_per_day and merged_data
rm(sales_per_day, merged_data)



######################
##     apriori      ##
######################
# Turn basket column into a list
baskets <- strsplit(as.character(transaction_data$Basket), "")

# Convert the baskets into a transaction object, which is required for apriori
trans <- as(baskets, "transactions")

# Summary statistics and frequency
summary(trans)
itemFrequencyPlot(trans, topN = 6)

# Example of generating association rules
rules <- apriori(trans, parameter = list(support = 0.1, confidence = 0.5, minlen = 2))
summary(rules)

# Sort rules by some criteria, e.g., by confidence
sorted_rules <- sort(rules, by = "confidence", decreasing = TRUE)

# Visualize top N rules
plot(sorted_rules, method = "graph", control = list(type = "items"))

itemsets_df <- as(rules, "data.frame")
print(itemsets_df)



# When interpreting association rules generated from the Apriori algorithm, it's essential to understand the key metrics associated with each rule. Here's how you can interpret the aspects you mentioned:
  
# Rules: This represents the association rules generated by the Apriori algorithm. Each rule consists of an antecedent (left-hand side) and a consequent (right-hand side) separated by an arrow (->). For example, A -> B represents a rule where A is the antecedent and B is the consequent.

# Support: Support indicates the proportion of transactions in the dataset that contain the items present in the rule. It is calculated as the number of transactions containing both the antecedent and consequent divided by the total number of transactions. High support values mean that the rule is applicable to a significant portion of the dataset.

# Confidence: Confidence measures the probability that a transaction containing the antecedent will also contain the consequent. It is calculated as the number of transactions containing both the antecedent and consequent divided by the number of transactions containing the antecedent. High confidence values suggest a strong relationship between the antecedent and consequent.

# Coverage: Coverage indicates the proportion of transactions that contain the antecedent (both with and without the consequent). It is calculated as the number of transactions containing the antecedent divided by the total number of transactions. High coverage values mean that the antecedent appears frequently in the dataset.

# Lift: Lift measures how much more likely the antecedent and consequent are to occur together compared to if they were statistically independent. Lift greater than 1 indicates a positive correlation between the antecedent and consequent. A lift of 1 means the antecedent and consequent are independent, while a lift less than 1 indicates a negative correlation.

# Count: Count represents the number of transactions in the dataset that contain both the antecedent and consequent.

# When interpreting rules, it's crucial to consider these metrics together. High support indicates the popularity of the rule, high confidence indicates the reliability of the rule, high lift indicates a strong association between the items, and high coverage indicates how frequently the items in the rule appear in the dataset.

























######################
##    elasticity    ##
######################

# Product A
# Product B
# Product C

# Itemset 1
# Itemset 2
# Itemset 3
# Itemset 4





# Generate a random integer within the specified interval
randomNumber <- sample(minValue:maxValue, 1)


