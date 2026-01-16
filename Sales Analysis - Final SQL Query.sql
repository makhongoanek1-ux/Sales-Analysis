FINAL BIG QUERY

 SELECT *
FROM Dataset.Sales_Analysis.Case_Study;

--------------------------------------------------------
--Final query for analysis--
WITH base_data AS (
    SELECT
        DATE,
        SALES,
        COST_OF_SALES,
        QUANTITY_SOLD,

        -- Base calculations
        SALES / QUANTITY_SOLD AS PRICE_PER_UNIT,
        SALES - COST_OF_SALES AS GROSS_PROFIT,
        (SALES - COST_OF_SALES) / SALES AS GROSS_PROFIT_PCT
    FROM Dataset.Sales_Analysis.Case_Study
),

promo_flag AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY PRICE_PER_UNIT) AS PRICE_BUCKET
    FROM base_data
),

elasticity_calc AS (
    SELECT
        DATE,
        SALES,
        COST_OF_SALES,
        QUANTITY_SOLD,

        PRICE_PER_UNIT,
        GROSS_PROFIT,
        GROSS_PROFIT_PCT,

        PRICE_BUCKET,

        LAG(QUANTITY_SOLD) OVER (ORDER BY DATE) AS PREV_QTY,
        LAG(PRICE_PER_UNIT) OVER (ORDER BY DATE) AS PREV_PRICE,

        -- % change calculations
        (QUANTITY_SOLD - LAG(QUANTITY_SOLD) OVER (ORDER BY DATE))
            / LAG(QUANTITY_SOLD) OVER (ORDER BY DATE) AS QTY_CHANGE_PCT,

        (PRICE_PER_UNIT - LAG(PRICE_PER_UNIT) OVER (ORDER BY DATE))
            / LAG(PRICE_PER_UNIT) OVER (ORDER BY DATE) AS PRICE_CHANGE_PCT
    FROM promo_flag
)

SELECT
    DATE,
    SALES,
    COST_OF_SALES,
    QUANTITY_SOLD,
    PRICE_PER_UNIT,
    GROSS_PROFIT,
    GROSS_PROFIT_PCT,

    CASE 
        WHEN PRICE_BUCKET = 1 THEN 'Promotion'
        ELSE 'Non-Promotion'
    END AS PROMO_FLAG,

    QTY_CHANGE_PCT,
    PRICE_CHANGE_PCT,

    -- Price Elasticity
    QTY_CHANGE_PCT / PRICE_CHANGE_PCT AS PRICE_ELASTICITY

FROM elasticity_calc
ORDER BY DATE;