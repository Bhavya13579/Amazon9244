# Amazon-Style E-Commerce Analytics Project

# SQL + Python | End-to-End Business Analysis

# Overview
This project simulates an Amazon-like e-commerce analytics environment, built end-to-end using Python for data generation and MySQL for business intelligence analysis.
The goal is to demonstrate real-world SQL proficiency, business thinking, and analytical depth expected from roles at companies like Amazon, Meta, Google, Tesla, and other data-driven MNCs.
The dataset and queries are intentionally designed to mirror Amazon’s core retail business (excluding AWS and Ads), aligned with insights from Amazon’s public 10-K filings.
 
# Project Architecture

Tech Stack

•	Python: Synthetic data generation

•	MySQL: Relational database & analytics

•	SQL: Business KPIs, window functions, cohorts

•	CSV pipelines: Realistic ETL-style loading
 
# Data Model

Tables

•	regions – geographic segmentation

•	customers – Prime vs non-Prime users

•	products – retail catalog with cost & price

•	orders – transactional order data

•	order_items – basket-level purchase detail

All relationships are realistic and analytically meaningful.
 
# Python: Data Generation

Python scripts generate clean, consistent CSV files with:

•	Realistic price bands by category

•	Category-specific margins

•	Time-distributed orders (2022–2024)

•	Prime and non-Prime customer behaviour

Output Files

•	customers.csv

•	products.csv

•	orders.csv

•	order_items.csv

These are loaded directly into MySQL using LOAD DATA LOCAL INFILE, simulating real ETL workflows.
 
# Analysis Covered

1. Core Business KPIs

•	Total orders & unique customers

•	Order status distribution

•	Prime vs non-Prime order volume

•	Gross merchandise value (GMV proxy)


2. Revenue Analysis

•	Revenue by category

•	Category share of total revenue

•	Top-selling products

•	High-value customers


3. Advanced SQL

•	Window functions (RANK, DENSE_RANK, LAG)

•	Running totals & trend analysis

•	Customer cohort analysis

•	Yearly top-category rankings

•	NULL-safe revenue calculations

•	Left joins to capture inactive users


4. Performance & Scalability Thinking

•	Indexing on join and filter columns

•	CTE-based query structuring

•	Early filtering and aggregation logic

•	Business-first query design

