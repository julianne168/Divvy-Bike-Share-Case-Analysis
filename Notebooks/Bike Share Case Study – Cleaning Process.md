# 🚲 Divvy 2024 Trip Data – Cleaning & Preparation Documentation

## Objective  
The goal of this cleaning process is to produce a clean, deduplicated, and analysis-ready dataset of Divvy bike trips for the year 2024, ensuring accurate and consistent data fields while retaining all relevant trip-level information. All data cleaning and manipulation processes are conducted in **Google BigQuery** using SQL.


---

## 🧹 Step-by-Step Cleaning and Manipulation Process

### 1. Initial Column Selection and Renaming  

To simplify and standardize the dataset, we selected only the necessary columns from the raw `DivvyTripData2024` table and renamed them for consistency and clarity:

- `ride_id` → `trip_id`  
- `rideable_type` → `bike_type`  
- `started_at` → `start_time`  
- `ended_at` → `end_time`  
- `start_station_name` → `start_station`  
- `end_station_name` → `end_station`  
- `member_casual` → `user_type`

Columns retained without renaming:
- `start_station_id`
- `end_station_id`

This step reduced the dataset to the essential fields required for trip-level analysis, improving readability and standardizing naming conventions across time.

The resulting dataset was saved as `Divvy_Trip_2024_Column_Update` in BigQuery Table

---

### 2. Data Consistency Checks

- **Trip ID Length Validation:**  
  Ensured all `trip_id` values followed a consistent length and format.

- **Bike Type and User Type Validation:**  
  Verified that all values in `bike_type` and `user_type` were valid and free of typos or anomalies.

- **Standardization of User Type Field:**  
  Renamed user type `"casual"` to `"customer"` for improved clarity in segmentation.

---

### 3. Filtering Incomplete Station Information  
Removed rows where both start and end station names and IDs were missing.  
This ensures that every trip retained has at least partial station information for analysis.

---

### 4. Feature Engineering  

New columns were created to enrich the dataset:

- `ride_duration` – Trip duration in minutes, computed as the difference between `end_time` and `start_time`.
- `day_of_week` – Extracted the name of the weekday from `start_time` (e.g., Monday, Friday).
- `weekend_flag` – Labeled each trip as either **Weekday** or **Weekend** based on `day_of_week`.

---

### 5. Deduplication of Trips  
We identified duplicate `trip_id` entries and retained only the earliest one per trip.  
Using a row ranking method, we kept the record with the earliest `start_time` and discarded others.  
This step ensures each `trip_id` appears only once in the final dataset.

---

### 7. Final Cleaning  
As a last validation, all rows with null `trip_id` values were removed to ensure data integrity.

---

## ✅ Final Output  
The final cleaned dataset includes:

- Consistent and renamed field names
- No duplicate or null `trip_id` entries
- New fields for behavior and temporal analysis
- Cleaned station data with only relevant attributes

The final cleaned data was exported to ` and saved from BigQuery using the "Save Results" feature to persist the table for downstream use.
This dataset is now ready for further usage pattern, temporal trend, and spatial mobility analysis.
