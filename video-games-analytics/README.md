# Video Game Publications: Data Preprocessing & Exploratory Data Analysis (2000–2013)

## 📌 Project Overview
This project focuses on the comprehensive analysis and preprocessing of a historical dataset containing video game sales, genres, platforms, and reviews (`new_games.csv`). The primary goal is to clean raw data, eliminate critical technical anomalies, categorize key metrics, and construct a highly representative, clean data slice for future business modeling.

The research is strictly focused on the **"Golden Age" of gaming (2000–2013)**, which covers the full lifecycles of the 6th and 7th generations of video game consoles.

---

## 🛠️ Tech Stack & Skills
* **Programming Language:** Python
* **Libraries:** Pandas, NumPy, Matplotlib, Seaborn
* **Core Skills:** Data Cleaning & Integrity, Feature Engineering, Data Categorization, Exploratory Data Analysis (EDA), Advanced Missing Value Imputation, String Manipulation.

---

## 🚀 Key Steps & Results

1. **Rigorous Data Cleaning & Integrity:**
   * Standardized all column names to standard Python `snake_case`.
   * Fixed critical data type bugs: regional sales volumes (`eu_sales`, `jp_sales`) and user scores (`user_score`) were successfully converted from string format to `float64`.
   * Eradicated the `"tbd"` text placeholder in user reviews, converting them into systematic `NaN` values.
   * Strategically recovered missing values in regional sales using smart grouping by platform and year of release (`.transform('mean')`).
   * **Result:** Preserved **99.9% of the original commercial data**, fully protecting the sample from losing its representativeness.

2. **Time-Frame Slicing:**
   * Isolated a clean data slice strictly covering 2000–2013. This eliminated the historical noise of 80s/90s retro platforms and focused the analysis on the most economically relevant period of the market.

3. **Feature Categorization & Business Segments:**
   * Segmented continuous user scores (10-point scale) and critic scores (100-point scale) into three explicit business categories: *High*, *Medium*, and *Low Score*.
   * Uncovered a "hidden market" phenomenon: a colossal portion of commercially successful games sell millions of copies worldwide without ever receiving an official score on major aggregators like Metacritic.

4. **Market Leaders Identification:**
   * Identified the **TOP 7 most popular gaming platforms** by the total number of released titles during the target period (including ecosystems from Sony, Microsoft, and Nintendo), outlining the boundaries of the primary sales markets.

---

## 📂 Repository Structure
* `games_analysis.ipynb` — Jupyter Notebook containing step-by-step code, detailed comments, data visualizations, and analytical insights.
* `README.md` — concise project summary optimized for a professional data portfolio.
