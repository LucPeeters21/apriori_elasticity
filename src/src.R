# import libraries
library(arules)
library(lubridate)
library(ggplot2)

#####################
## data generation ##
#####################

# Create a sequence of dates for the whole year
dates <- seq(as.Date("2020-01-01"), as.Date("2023-12-31"), by = "day")

# generate transaction data
transaction_data <- data.frame(
  Date = rep(dates, each = 100),  # 10 transactions per day
  Transaction_ID = 1:(length(dates) * 100),      # Unique transaction IDs
  Q_A = sample(0:2, length(dates) * 100, replace = TRUE),  # Random quantities of Product A (0 to 2)
  Q_B = sample(0:3, length(dates) * 100, replace = TRUE),  # Random quantities of Product B (0 to 3)
  Q_C = sample(0:1, length(dates) * 100, replace = TRUE),   # Random quantities of Product C (0 to 1)
  Q_D = sample(0:2, length(dates) * 100, replace = TRUE),  # Random quantities of Product A (0 to 2)
  Q_E = sample(0:3, length(dates) * 100, replace = TRUE),  # Random quantities of Product B (0 to 3)
  Q_F = sample(0:1, length(dates) * 100, replace = TRUE),   # Random quantities of Product C (0 to 1)
  Quarter = quarter(dates),                                    # Quarter of the year
  DayOfWeek = weekdays(dates)                                  # Day of the week
  )

# Create a basket column based on product frequency in each transaction
transaction_data$Basket <- apply(transaction_data[, c("Q_A", "Q_B", "Q_C", "Q_D", "Q_E", "Q_F")], 1, function(x) {
  products <- c(rep("A", x["Q_A"]), rep("B", x["Q_B"]), rep("C", x["Q_C"]), rep("D", x["Q_D"]), rep("E", x["Q_E"]), rep("F", x["Q_F"]))
  paste(products, collapse = "")
})

# Remove trailing whitespace from the 'basket' column
transaction_data$Basket <- gsub("\\s", "", transaction_data$Basket)

# generate price data
price_data <- data.frame(
  Date = dates,                                                # Dates for the whole year
  P_A = sample(8:12, length(dates), replace = TRUE),      # Random prices for Product A (8 to 12)
  P_B = sample(18:22, length(dates), replace = TRUE),     # Random prices for Product B (18 to 22)
  P_C = sample(13:17, length(dates), replace = TRUE),      # Random prices for Product C (13 to 17)
  P_D = sample(9:12, length(dates), replace = TRUE),      # Random prices for Product A (8 to 12)
  P_E = sample(15:16, length(dates), replace = TRUE),     # Random prices for Product B (18 to 22)
  P_F = sample(11:13, length(dates), replace = TRUE)      # Random prices for Product C (13 to 17)
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
price_data <- price_data %>% select(Date, P_A, Q_A, P_B, Q_B, P_C, Q_C, P_D, Q_D, P_E, Q_E, P_F, Q_F)

# remove sales_per_day and merged_data
rm(sales_per_day, merged_data)




######################
##     apriori      ##
######################

# support
# confidence
# lift

baskets <- as.data.frame(table(transaction_data$Basket))

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






