# Load required libraries
library(tidyverse)
library(lubridate)
library(scales)

# Read in the cleaned Divvy trip dataset
divvy_2024 <- read_csv("D:/Julianne/Google Data Analytics/Portfolio/Capstone/Data/processed/All_Divvy_Trip_2024_Cleaned.csv")
View(divvy_2024)
# Summarize the col information
glimpse(divvy_2024)

# ---- 1. Compare average ride durations by user type ----
ggplot(divvy_2024, aes(x = user_type, y = ride_duration_minutes, fill = user_type)) +
  geom_boxplot(outlier.shape = NA) +
  coord_cartesian(ylim = c(0, 60)) +  # Limit y-axis to remove extreme values
  labs(title = "Customer Rides Are 3x Longer Than Member Rides",
       subtitle = "Median ride duration by user type (outliers excluded)",
       y = "Average Duration (minutes)", x = "User Type")+
  theme_minimal() +
  theme(axis.line = element_line(color = "black"))  # Adds axis lines


# ---- 2. Are customers more active on weekends, and members on weekdays? ----
library(viridis)
divvy_2024 %>%
  group_by(user_type, weekend_flag) %>%
  summarise(avg_duration = mean(ride_duration_minutes), .groups = "drop") %>%
  ggplot(aes(x = user_type, y = avg_duration, fill = weekend_flag)) +
  geom_col(position = position_dodge(width = 0.9)) +
  geom_text(aes(label = weekend_flag),
    position = position_dodge(width = 0.9), # Use the same logic for spacing and alignment to align with bar
    vjust = -0.3, #place above the bar
    size = 3.5)+
  scale_fill_manual(values = c("Weekday" = "#0071bc", "Weekend" = "#f9c642")) +
  labs(title = "Ride Duration Comparsion by User Type", subtitle = "Weekend vs Weekday",
       x = "User Type", y = "Average Duration (minutes)", 
       caption = paste0("created by Zheyan on ", today("UTC"))) +
  theme(axis.text.x = element_text(size = 12))  # change 14 to any size you prefer

# ---- 3. Peak hours of usage by user type ----
# Find trip count by hour
trip_by_hour <- divvy_2024 %>%
  mutate(hour = lubridate::hour(start_time) + 1) %>%
  group_by(user_type, hour) %>%
  summarise(trip_count = n(), .groups = "drop") #counts the number of rows in each group and ungroup after

# Plot with annotation
trip_by_hour  %>% 
  ggplot(aes(x = hour, y = trip_count, color = user_type)) + 
  geom_line(size = 1.2) +
  scale_x_continuous(breaks = 1:24) +  # This adds hourly breaks
  scale_y_continuous(labels = comma) +
  labs(title = "Bike Share Peak Hours of Different Users", 
       subtitle = "Usage Spikes during Commuting Hours",
       caption = paste0("created by Zheyan on ", today("UTC")),
       x = "Hour of Day", y = "Number of Rides") +
  theme_minimal()
# the number of trip count increase leading up to 6pm but decrease after 6
# could be that many one-day-pass, or one single ride user use it for commuting purpose at 6, 
# but it might not be the only main reason, since there are no peak point at 8 am rush hour
# the number of # the number of trip count increase leading up to 9am and 6pm,
# suggesting member mainly use it for commuting purpose

# ---- Trip Count by User Type Column
divvy_2024 %>%
  mutate(hour = lubridate::hour(start_time) + 1) %>%
  group_by(user_type, hour) %>%
  summarise(trip_count = n(), .groups = "drop") %>%
  ggplot(aes(x = hour, y = trip_count)) +
  geom_col(fill = "#56B4E9") +
  facet_wrap(~ user_type) +
  scale_x_continuous(breaks = seq(1, 24, by = 2)) +  # Start at 1, increment by 2
  scale_y_continuous(labels = comma) +
  labs(title = "Ride Distribution of User by Hour", subtitle = "Hourly Ride Patterns Reveal Key Usage Differences",
       x = "Hour of Day", y = "Number of Trips", caption = paste0("created by Zheyan on ", today("UTC")))

# ---- 4. Ride activity by day of the week ----
divvy_2024 %>%
  mutate(
    day_of_week = factor( #map day to factor column and assign the correct order
      day_of_week, 
      levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"),
      ordered = TRUE
    )
  ) %>%
  group_by(user_type, day_of_week) %>%
  summarise(trip_count = n(), .groups = "drop") %>%
  ggplot(aes(x = day_of_week, y = trip_count, fill = user_type)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = comma) +
  labs(title = "Ride Count by Day of Week for Different Users",
       subtitle = "The Weekend Effect: Casual Rider Demand Surges",
       x = "Day of Week", y = "Number of Trips", caption = paste0("created by Zheyan on ", today("UTC"))) + 
  theme_minimal() +
  theme(axis.line = element_line(color = "black"),# Adds axis lines
        axis.text.x = element_text(angle = 45, hjust = 1))

# Customer (Casual Users):
# Weekend Peak: Saturday and Sunday are the busiest days, with 317,848 and 266,194 rides respectively.
# Insight: Casual users prefer riding on weekends, likely for leisure, tourism, or social activities.
# Friday also sees high ridership, possibly due to people starting weekends early or transitioning into weekend activities.
#  📌 Conclusion: Customers are "leisure-oriented" riders, with usage peaks on weekends and Fridays.

# ---- Member (Subscribers):
# Weekday Peak: Wednesday, Tuesday, and Thursday are the most active days.
# Insight: Members likely use bikes primarily for commuting, showing stable weekday patterns.
# 📌 Conclusion: Members are "commute-oriented" riders, peaking midweek (Tuesday–Thursday).
#  Strategic Insight: Targeted promotions (e.g., weekend passes for Customers, weekday discounts for Members) could optimize ridership and revenue.

# --- 5. Trip count by Bike Type for Different Rider
trip_by_bike_type <- divvy_2024 %>% 
  group_by(bike_type,user_type) %>% 
  summarize(trip_count = n())

trip_by_bike_type %>% 
  ggplot(aes(x = bike_type, y = trip_count, fill = bike_type)) +
  geom_col() +
  facet_wrap(~ user_type) +
  scale_y_continuous(labels = comma) +
  labs(title = "Number of Ride by Bike Type for Different User", 
       subtitle = "Classic Bikes Dominate Across All User Types",
       x = "Bike Type", y = "Number of Trips", caption = paste0("created by Zheyan on ", today("UTC"))) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# both user type relay heavily on classic bike

# --- 6. Average Trip Duration by Bike Type for Different Rider
trip_duration_bike_type <- divvy_2024 %>% 
  group_by(bike_type,user_type) %>% 
  summarize(average_duration = mean(ride_duration_minutes))

trip_duration_bike_type %>% 
  ggplot(aes(x = bike_type, y = average_duration, fill = bike_type)) +
  geom_col() +
  facet_wrap(~ user_type) +
  scale_y_continuous(labels = comma) +
  labs(title = "How Bike Type Affects Ride Duration: Members vs. Customers", 
       subtitle = "Electric options reduce average ride duration by 40% compared to classic bikes",
       x = "Bike Type", y = "Number of Trips", 
       caption = paste0("created by Zheyan on ", today("UTC"))) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# the customer ride heavily longer on classic bike (30), almost twice as much as the electric bike (16) and electric scooter (12)
# the annual member, the duration is slightly increase from class bike to electric bike to electric scooter, 
# but on average the duration time are approximately similar around 10
# which could be an indication of riding for leisure


# ---- 7. Top 20 start stations for casual riders ----
# Get top 20 stations for each user type
top_stations_by_user <- divvy_2024 %>%
  group_by(user_type, start_station) %>%
  summarise(trip_count = n(), .groups = "drop") %>%
  group_by(user_type) %>%
  slice_max(trip_count, n = 20) %>%
  ungroup()

# Plot with facets
ggplot(top_stations_by_user, aes(x = reorder(start_station, trip_count), y = trip_count)) +
  geom_col(fill = "#56B4E9") +
  coord_flip() +  # Horizontal bars
  facet_wrap(~ user_type, scales = "free_y") +  # Separate plots per user type
  labs(
    title = "Top 20 Start Stations by User Type",
    x = "Start Station",y = "Number of Trips",
    caption = paste0("created by Zheyan on ", today("UTC"))) +
  theme(panel.grid.major = element_blank(),        # Optional: removes major gridlines
        panel.grid.minor = element_blank()) +         # Optional: removes minor gridlines
  theme(axis.text.y = element_text(size = 8),    # Adjust station name font size
        axis.text.x = element_text(size = 8, angle = 45))

# ---- 8. Top 50 stations by customer ride volume (for marketing strategy) ----
pivot_usage <- divvy_2024 %>%
  filter(!is.na(start_station)) %>%
  group_by(user_type, start_station) %>%
  summarise(trip_count = n(), .groups = "drop") %>%
  pivot_wider(names_from = user_type, values_from = trip_count, values_fill = 0) %>%
  mutate(total_trips = customer + member) %>%
  arrange(desc(customer)) %>%
  slice_head(n = 50)
# Display the table
