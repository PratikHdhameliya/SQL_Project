# COVID-19 Data Exploration

This project involves exploring and analyzing COVID-19 data using SQL queries. The SQL script provided includes various queries to understand the impact of COVID-19 across different regions and demographics.

## Description

The SQL script `Covid-Data-exploration.sql` contains queries that:
- Retrieve and order COVID-19 death records.
- Analyze total cases vs. total deaths.
- Compare total cases to population.
- Identify countries with the highest infection rates relative to their population.
- Determine countries with the highest death rates relative to their population.
- Summarize COVID-19 impact by continent.
- Aggregate global COVID-19 data by date.

## Prerequisites

To run the SQL script, you need:
- A SQL Server instance (e.g., SQL Server, MySQL, PostgreSQL).
- Access to a database containing COVID-19 data tables such as `CovidDeaths` and `CovidVaccinations`.

## Installation

1. Clone the repository to your local machine:
    ```bash
       git clone git@github.com:PratikHdhameliya/SQL_Project.git
    ```

2. Ensure your database contains the necessary tables and data:
    - `CovidDeaths`
    - `CovidVaccinations`

## Usage

1. Open your SQL Server Management Studio (SSMS) or any SQL client.
2. Connect to your SQL Server instance.
3. Open the `Covid_Data_Exploration.sql` file.
4. Execute the queries to analyze the data.

### Example Queries

- **Retrieve COVID-19 Death Records:**
    ```sql
    SELECT * 
    FROM SQLProject.CovidDeaths
    ORDER BY 3, 4;
    ```

- **Total Cases vs. Total Deaths:**
    ```sql
    SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
    FROM SQLProject.CovidDeaths
    WHERE location LIKE '%state%'
    ORDER BY 2;
    ```

- **Total Cases vs. Population:**
    ```sql
    SELECT location, date, population, total_cases,  (total_cases/population)*100 AS CasePercentage 
    FROM SQLProject.CovidDeaths
    WHERE location LIKE 'India'
    ORDER BY 5 DESC;
    ```

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes. Ensure your code follows the existing coding style and includes appropriate comments.


