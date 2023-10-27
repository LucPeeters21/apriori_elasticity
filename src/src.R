# Create a sequence of dates for the whole year
dates <- seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day")



# Sample transaction data for 10 transactions every day of the year
transaction_data <- data.frame(
  Transaction_Date = rep(dates, each = 10),      # Repeat each date 10 times for 10 transactions
  Transaction_ID = 1:(length(dates) * 10),      # Unique transaction IDs
  Product_A = sample(0:3, length(dates) * 10, replace = TRUE),  # Random quantities of Product A
  Product_B = sample(0:3, length(dates) * 10, replace = TRUE),  # Random quantities of Product B
  Product_C = sample(0:3, length(dates) * 10, replace = TRUE)   # Random quantities of Product C
)



# Generate fluctuating prices for each product for every day of the year
price_changes_data <- data.frame(
  Date = rep(dates, each = 3),                  # Repeat each date 3 times for 3 products
  Product = rep(c("Product_A", "Product_B", "Product_C"), times = length(dates)),  # Product names
  Price = numeric(length(dates) * 3)            # Initialize an empty vector for prices
)

# Set initial prices
initial_prices <- c(10, 20, 15)  # Initial prices for Product_A, Product_B, and Product_C
set.seed(123)  # Setting seed for reproducibility of random numbers

# Generate fluctuating prices for each product for every day
for (i in 1:length(dates)) {
  # Generate random price fluctuations (between -2 to +2) for each product
  price_fluctuations <- sample(-2:2, 3, replace = TRUE)
  
  # Update prices based on fluctuations
  price_changes_data$Price[i * 3 - 2] <- max(1, initial_prices[1] + price_fluctuations[1])
  price_changes_data$Price[i * 3 - 1] <- max(1, initial_prices[2] + price_fluctuations[2])
  price_changes_data$Price[i * 3] <- max(1, initial_prices[3] + price_fluctuations[3])
}






