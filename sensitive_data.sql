-- Step 1: Define the virtual views (CTEs)
WITH CustomerDetails AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ACCOUNT_NUMBER) AS CUSTOMER_ID,
        FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME,
        ACCOUNT_NUMBER,
        ADDRESS,
        MEMBER_STATUS,
        TO_DATE(DOB, 'YYYY-MM-DD') AS DATE_OF_BIRTH,
        GENDER,
        PHONE_NUMBER,
        EMAIL,
        CARD_NUMBER,
        '****-****-' || SUBSTR(CARD_NUMBER, 13, 4) AS MASKED_CARD,
        SSN,
        TIN
    FROM (
        SELECT 
            'John' AS FIRST_NAME, 
            'Doe' AS LAST_NAME, 
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
),
AccountSummary AS (
    SELECT
        CUSTOMER_ID,
        ACCOUNT_NUMBER,
        LENGTH(ACCOUNT_NUMBER) AS ACCOUNT_LENGTH,
        CASE 
            WHEN MEMBER_STATUS = 'Premium Member' THEN 'Gold Tier'
            WHEN MEMBER_STATUS = 'Regular Member' THEN 'Silver Tier'
            ELSE 'Bronze Tier'
        END AS ACCOUNT_TIER,
        CASE 
            WHEN LENGTH(CARD_NUMBER) = 16 THEN 'Valid'
            ELSE 'Invalid'
        END AS CARD_STATUS
    FROM CustomerDetails
),
MaskedSensitiveData AS (
    SELECT
        CUSTOMER_ID,
        REGEXP_REPLACE(PHONE_NUMBER, '[0-9]', '*') AS MASKED_PHONE,
        REGEXP_REPLACE(SSN, '[0-9]', 'X') AS MASKED_SSN,
        REGEXP_REPLACE(TIN, '[0-9]', 'X') AS MASKED_TIN,
        MASKED_CARD
    FROM CustomerDetails
)

-- Step 2: Final SELECT combining virtual views
SELECT 
    CUST.CUSTOMER_ID,
    CUST.FULL_NAME,
    CUST.ADDRESS,
    CUST.DATE_OF_BIRTH,
    CUST.GENDER,
    ACC.ACCOUNT_TIER,
    ACC.CARD_STATUS,
    MASK.MASKED_PHONE,
    MASK.MASKED_SSN,
    MASK.MASKED_TIN,
    MASK.MASKED_CARD
FROM CustomerDetails CUST
JOIN AccountSummary ACC ON CUST.CUSTOMER_ID = ACC.CUSTOMER_ID
JOIN MaskedSensitiveData MASK ON CUST.CUSTOMER_ID = MASK.CUSTOMER_ID
ORDER BY CUST.CUSTOMER_ID;
