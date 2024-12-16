import re
import pandas as pd

# Sample SQL data
sql_data = """
-- Step 1: Define the virtual views (CTEs)
WITH CustomerDetails AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ACCOUNT_NUMBER) AS CUSTOMER_ID,
        FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME,
        '1234567890123456' AS ACCOUNT_NUMBER,
        '123 Elm St, Apt 4B, Springfield, IL, 62704' AS ADDRESS,
        'Premium Member' AS MEMBER_STATUS,
        '1985-08-15' AS DOB,
        'Male' AS GENDER,
        '555-123-4567' AS PHONE_NUMBER,
        'john.doe@email.com' AS EMAIL,
        '4111111111111111' AS CARD_NUMBER,
        '123-45-6789' AS SSN,
        '12-3456789' AS TIN
    FROM DUAL
    UNION ALL
    SELECT 
        'Jane', 
        'Smith', 
        '9876543210987654', 
        '456 Oak St, Apt 10C, Chicago, IL, 60605', 
        'Regular Member', 
        '1992-06-21', 
        'Female', 
        '555-987-6543', 
        'jane.smith@email.com', 
        '5500000000000004', 
        '987-65-4321', 
        '98-7654321'
    FROM DUAL
    UNION ALL
    SELECT 
        'Alice', 
        'Brown', 
        '6543210987654321', 
        '789 Maple Ave, Springfield, IL, 62703', 
        'Basic Member', 
        '1978-12-05', 
        'Female', 
        '555-456-7890', 
        'alice.brown@email.com', 
        '4012888888881881', 
        '654-32-1098', 
        '65-4321098'
    FROM DUAL
)
"""

# Patterns to detect sensitive data
patterns = {
    "Name": r"(?:[A-Z][a-z]+\s+[A-Z][a-z]+)",
    "Account Number": r"\b\d{16}\b",
    "Address": r"(?:\d{1,5}\s\w+\s\w+,\s\w+,\s\w+, \w{2},\s\d{5})",
    "Member": r"(?:Premium Member|Regular Member|Basic Member)",
    "DOB": r"\d{4}-\d{2}-\d{2}",
    "Gender": r"(?:Male|Female)",
    "Phone number": r"\b\d{3}-\d{3}-\d{4}\b",
    "Email": r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
    "Card Number": r"\b\d{16}\b",
    "SSN": r"\b\d{3}-\d{2}-\d{4}\b",
    "TIN": r"\b\d{2}-\d{7}\b"
}

# Data structure to hold results
results = []

# Extracting sensitive data from SQL
for name, pattern in patterns.items():
    matches = re.findall(pattern, sql_data)
    for match in matches:
        results.append({
            "Source": "Sample SQL",
            "Report name": "Sensitive Data Detection",
            "DB": "CustomerDB",
            "Schema": "CustomerSchema",
            "Table": "CustomerDetails",
            "Is Sensitive": "Yes",
            name: match
        })

# Creating a DataFrame and writing to Excel
df = pd.DataFrame(results)
output_file = "sensitive_data_detection.xlsx"
df.to_excel(output_file, index=False)

print(f"Sensitive data extraction completed. Results saved to {output_file}.")
