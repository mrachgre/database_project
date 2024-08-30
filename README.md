# Database Design for an Internet Café Management App

## Overview
This database design is intended for an app that manages an internet café. It includes trigger functions to support necessary management features, maintain history, and handle associated services.

## Key Components

### 1. **Entity-Relationship Diagram (ERD)**
   - Illustrates the structure of the database including entities (tables), attributes (columns), and relationships.

### 2. **Triggers**
   - **Function Trigger for Inventory Management**: Automatically updates the quantity of products if the same type of product is added to an existing order, instead of creating a new record.
   - **Trigger for Calculating Total Order Value**: Computes the total value of an order whenever an item is inserted, updated, or deleted.
   - **Trigger for Updating Remaining Time**: Adjusts the remaining time for users based on the purchased packages in the order.

### 3. **History Management**
   - **Login History**: Tracks user login events and stores information about the time, user, and machine involved.
   - **Transaction History**: Keeps a record of all transactions related to orders, including details of products and services purchased.

### 4. **Associated Services**
   - **Package Handling**: Updates the remaining time for users based on the purchased service packages (e.g., 1-hour, 2-hour, 5-hour packages).
   - **Notification Services**: Alerts users if their account balance or remaining time is low.



