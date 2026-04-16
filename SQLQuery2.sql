USE phase_v_bcerts_lookup
SELECT *, COALESCE(MOBILE_NUMBER, TELEPHONE) AS CONTACT_NUMBER
FROM dbo.member_details 
WHERE ID_NUMBER IS NOT NULL
	AND NSSF_NUMBER IS NOT NULL
	AND MEMBER_NAME IS NOT NULL
	AND DATE_OF_BIRTH IS NOT NULL
	AND (MOBILE_NUMBER IS NOT NULL OR TELEPHONE IS NOT NULL)
FOR JSON PATH; 

USE phase_v_bcerts ;

SELECT TOP 10 * FROM dbo.IndexFieldTable
WHERE BatchID = 26702;

SELECT TOP 10 * FROM dbo.imgtable;

SELECT TOP 10 * FROM dbo.batchtable
WHERE BatchDirectory = '\\192.168.1.11\phase_v\BCERTS\RAW\094_10\43093DS06';


SELECT TOP 10 * FROM dbo.doctable;

SELECT COUNT(*) FROM dbo.doctable;

SELECT 
    TypeName AS DocumentType, 
    COUNT(*) AS TotalCount
FROM dbo.doctable
WHERE TypeName IN ('B_CERTIFICATE', 'FULLSET', 'ID', 'IDENTIFICATION')
GROUP BY TypeName
ORDER BY TotalCount DESC; -- This sorts them from highest to lowest count

SELECT 
    d.TypeName, 
    COUNT(*) as TotalRows
FROM dbo.imgtable i
INNER JOIN dbo.batchtable b 
    ON i.BatchID = b.BatchID
INNER JOIN dbo.doctable d 
    ON i.BatchID = d.BatchID AND i.DocID = d.DocID
-- THE FIX: Force it to grab data from the main document (DocID = 1) for EVERY image in the batch
LEFT JOIN dbo.IndexFieldTable f 
    ON i.BatchID = f.BatchID AND f.DocID = 1 
WHERE 
    LEFT(i.ImgPath, 2) = '10' 
    AND d.TypeName IN ('B_CERTIFICATE', 'FULLSET', 'ID', 'IDENTIFICATION')
    AND f.value IS NOT NULL
    AND LTRIM(RTRIM(f.value)) <> ''
GROUP BY 
    d.TypeName;

SELECT DISTINCT
    b.BatchDirectory + '\' + i.ImgPath AS FullImagePath, -- Combined the path here!
    d.TypeName AS DocumentType,
    f.FieldName,
    f.value
FROM dbo.imgtable i
INNER JOIN dbo.batchtable b 
    ON i.BatchID = b.BatchID
INNER JOIN dbo.doctable d 
    ON i.BatchID = d.BatchID AND i.DocID = d.DocID
-- Updated to INNER JOIN for better performance
INNER JOIN dbo.IndexFieldTable f 
    ON i.BatchID = f.BatchID AND f.DocID = 1 
WHERE 
    LEFT(i.ImgPath, 2) = '10' 
    AND d.TypeName IN ('B_CERTIFICATE', 'FULLSET', 'ID', 'IDENTIFICATION')
    -- AND b.BatchDirectory IS NOT NULL
    -- AND i.ImgPath IS NOT NULL
    -- AND d.TypeName IS NOT NULL
    AND f.FieldName IS NOT NULL
    AND f.value IS NOT NULL
    AND LTRIM(RTRIM(f.value)) <> '';

SELECT DISTINCT
    b.BatchDirectory,
    i.ImgPath,
    d.TypeName AS DocumentType,
    f.FieldName,
    f.value
FROM dbo.imgtable i
INNER JOIN dbo.batchtable b 
    ON i.BatchID = b.BatchID
INNER JOIN dbo.doctable d 
    ON i.BatchID = d.BatchID AND i.DocID = d.DocID
-- The magic fix: Forcing all documents in a batch to share the extracted data
LEFT JOIN dbo.IndexFieldTable f 
    ON i.BatchID = f.BatchID AND f.DocID = 1 
WHERE 
    LEFT(i.ImgPath, 2) = '10' 
    AND d.TypeName IN ('B_CERTIFICATE', 'FULLSET', 'ID', 'IDENTIFICATION')
    -- AND b.BatchDirectory IS NOT NULL
    -- AND i.ImgPath IS NOT NULL
    -- AND d.TypeName IS NOT NULL
    AND f.FieldName IS NOT NULL
    AND f.value IS NOT NULL
    AND LTRIM(RTRIM(f.value)) <> '';


SELECT 
    b.BatchDirectory,
    i.ImgPath,
    d.TypeName AS DocumentType,
    f.FieldName,
    f.value
FROM dbo.imgtable i
INNER JOIN dbo.batchtable b 
    ON i.BatchID = b.BatchID
INNER JOIN dbo.doctable d 
    ON i.BatchID = d.BatchID AND i.DocID = d.DocID
LEFT JOIN dbo.IndexFieldTable f 
    ON i.BatchID = f.BatchID AND i.DocID = f.DocID
WHERE 
    d.LevelNum = 1 
    AND LEFT(i.ImgPath, 2) = '10' -- This instantly drops all back/other images
    -- AND b.BatchDirectory IS NOT NULL
    -- AND i.ImgPath IS NOT NULL
    -- AND d.TypeName IS NOT NULL
    AND f.FieldName IS NOT NULL
    AND f.value IS NOT NULL
    AND LTRIM(RTRIM(f.value)) <> '';

SELECT DISTINCT
    b.BatchDirectory + '\' + i.ImgPath AS FullImagePath, -- Combined the path here!
    d.TypeName AS DocumentType,
    f.FieldName,
    f.value
FROM dbo.imgtable i
INNER JOIN dbo.batchtable b 
    ON i.BatchID = b.BatchID
INNER JOIN dbo.doctable d 
    ON i.BatchID = d.BatchID AND i.DocID = d.DocID
-- Updated to INNER JOIN for better performance
INNER JOIN dbo.IndexFieldTable f 
    ON i.BatchID = f.BatchID AND f.DocID = 1 
WHERE 
    LEFT(i.ImgPath, 4) = '1000' 
    AND d.TypeName IN ('B_CERTIFICATE', 'FULLSET', 'ID', 'IDENTIFICATION')
    AND b.BatchDirectory IS NOT NULL
    AND i.ImgPath IS NOT NULL
    AND d.TypeName IS NOT NULL
    AND f.FieldName IS NOT NULL
    AND f.value IS NOT NULL
    AND LTRIM(RTRIM(f.value)) <> '';

SELECT DISTINCT 
    d.TypeName AS DocumentType, 
    f.FieldName
FROM dbo.doctable d
INNER JOIN dbo.IndexFieldTable f 
    ON d.BatchID = f.BatchID AND d.DocID = f.DocID -- We use the true DocID here to see the real alignment
WHERE 
    d.TypeName IN ('B_CERTIFICATE', 'FULLSET', 'ID', 'IDENTIFICATION')
    AND f.FieldName IS NOT NULL
ORDER BY 
    d.TypeName, 
    f.FieldName;


WITH BaseData AS (
    -- This is our optimized query from the previous step
    SELECT DISTINCT
        b.BatchDirectory + '\' + i.ImgPath AS FullImagePath,
        d.TypeName AS DocumentType,
        f.FieldName,
        f.value
    FROM dbo.imgtable i
    INNER JOIN dbo.batchtable b 
        ON i.BatchID = b.BatchID
    INNER JOIN dbo.doctable d 
        ON i.BatchID = d.BatchID AND i.DocID = d.DocID
    INNER JOIN dbo.IndexFieldTable f 
        ON i.BatchID = f.BatchID AND f.DocID = 1 
    WHERE 
        LEFT(i.ImgPath, 2) = '10' 
        AND d.TypeName IN ('B_CERTIFICATE', 'FULLSET', 'ID', 'IDENTIFICATION')
        -- AND b.BatchDirectory IS NOT NULL
        -- AND i.ImgPath IS NOT NULL
        -- AND d.TypeName IS NOT NULL
        AND f.FieldName IS NOT NULL
        AND f.value IS NOT NULL
        AND LTRIM(RTRIM(f.value)) <> ''
)
-- Now we PIVOT those field names into their own columns
SELECT 
    FullImagePath,
    DocumentType,
    [MEMBER NUMBER],
    [MEMBER NAME],
    [IDENTIFICATION],
    [GENDER],
    [DATE OF BIRTH],
    [MOBILE NUMBER],
    [TELEPHONE]
FROM BaseData
PIVOT (
    MAX(value) -- MAX is required by PIVOT to aggregate the string, but since there's only one value per field per document, it just grabs that string.
    FOR FieldName IN (
        [MEMBER NUMBER],
        [MEMBER NAME],
        [IDENTIFICATION],
        [GENDER],
        [DATE OF BIRTH],
        [MOBILE NUMBER],
        [TELEPHONE]
    )
) AS PivotTable;


SELECT 
    b.BatchID,
    
    -- 1. Align the Images into their own columns
    MAX(CASE WHEN d.TypeName = 'B_CERTIFICATE' THEN b.BatchDirectory + '\' + i.ImgPath END) AS BCert_ImagePath,
    MAX(CASE WHEN d.TypeName IN ('ID', 'IDENTIFICATION') THEN b.BatchDirectory + '\' + i.ImgPath END) AS ID_ImagePath,
    MAX(CASE WHEN d.TypeName = 'FULLSET' THEN b.BatchDirectory + '\' + i.ImgPath END) AS Fullset_ImagePath,
    
    -- 2. Align the Extracted Fields into their own columns
    MAX(CASE WHEN f.FieldName = 'MEMBER NUMBER' THEN f.value END) AS [MEMBER NUMBER],
    MAX(CASE WHEN f.FieldName = 'MEMBER NAME' THEN f.value END) AS [MEMBER NAME],
    MAX(CASE WHEN f.FieldName = 'IDENTIFICATION' THEN f.value END) AS [IDENTIFICATION],
    MAX(CASE WHEN f.FieldName = 'GENDER' THEN f.value END) AS [GENDER],
    MAX(CASE WHEN f.FieldName = 'DATE OF BIRTH' THEN f.value END) AS [DATE OF BIRTH],
    MAX(CASE WHEN f.FieldName = 'MOBILE NUMBER' THEN f.value END) AS [MOBILE NUMBER],
    MAX(CASE WHEN f.FieldName = 'TELEPHONE' THEN f.value END) AS [TELEPHONE]

FROM dbo.batchtable b
-- Join images, filtering for only the front images
LEFT JOIN dbo.imgtable i 
    ON b.BatchID = i.BatchID AND LEFT(i.ImgPath, 2) = '10'
-- Join doctable to know which image is which
LEFT JOIN dbo.doctable d 
    ON i.BatchID = d.BatchID AND i.DocID = d.DocID
-- Join the extracted fields for the batch
LEFT JOIN dbo.IndexFieldTable f 
    ON b.BatchID = f.BatchID 
WHERE b.BatchDirectory IS NOT NULL
    AND i.ImgPath IS NOT NULL
    AND d.TypeName IS NOT NULL
    AND f.FieldName IS NOT NULL
    AND f.value IS NOT NULL
    AND LTRIM(RTRIM(f.value)) <> ''

-- Group everything together by the unique Batch
GROUP BY 
    b.BatchID
    
-- Optional: Only return batches that actually have at least ONE extracted field
HAVING 
    MAX(f.value) IS NOT NULL 
    AND LTRIM(RTRIM(MAX(f.value))) <> '';


WITH PivotedBatch AS (
    -- 1. Create the base pivoted dataset
    SELECT 
        b.BatchID,
        MAX(CASE WHEN d.TypeName = 'B_CERTIFICATE' THEN b.BatchDirectory + '\' + i.ImgPath END) AS BCert_ImagePath,
        MAX(CASE WHEN d.TypeName IN ('ID', 'IDENTIFICATION') THEN b.BatchDirectory + '\' + i.ImgPath END) AS ID_ImagePath,
        MAX(CASE WHEN d.TypeName = 'FULLSET' THEN b.BatchDirectory + '\' + i.ImgPath END) AS Fullset_ImagePath,
        MAX(CASE WHEN f.FieldName = 'MEMBER NUMBER' THEN f.value END) AS [MEMBER NUMBER],
        MAX(CASE WHEN f.FieldName = 'MEMBER NAME' THEN f.value END) AS [MEMBER NAME],
        MAX(CASE WHEN f.FieldName = 'IDENTIFICATION' THEN f.value END) AS [IDENTIFICATION],
        MAX(CASE WHEN f.FieldName = 'GENDER' THEN f.value END) AS [GENDER],
        MAX(CASE WHEN f.FieldName = 'DATE OF BIRTH' THEN f.value END) AS [DATE OF BIRTH],
        MAX(CASE WHEN f.FieldName = 'MOBILE NUMBER' THEN f.value END) AS [MOBILE NUMBER],
        MAX(CASE WHEN f.FieldName = 'TELEPHONE' THEN f.value END) AS [TELEPHONE]
    FROM dbo.batchtable b
    LEFT JOIN dbo.imgtable i 
        ON b.BatchID = i.BatchID AND LEFT(i.ImgPath, 2) = '10'
    LEFT JOIN dbo.doctable d 
        ON i.BatchID = d.BatchID AND i.DocID = d.DocID
    LEFT JOIN dbo.IndexFieldTable f 
        ON b.BatchID = f.BatchID 
    GROUP BY b.BatchID
)
-- 2. Apply all your strict filtering rules
SELECT 
    BatchID,
    BCert_ImagePath,
    ID_ImagePath,
    Fullset_ImagePath,
    [MEMBER NUMBER],
    [MEMBER NAME],
    [IDENTIFICATION],
    [GENDER],
    [DATE OF BIRTH],
    -- Create the new Phone_No column
    CASE 
        -- Check Mobile Number first: must be >= 9 chars, not just '0', and not masked with 'X'
        WHEN LEN(LTRIM(RTRIM([MOBILE NUMBER]))) >= 9 AND [MOBILE NUMBER] NOT LIKE '%X%' THEN LTRIM(RTRIM([MOBILE NUMBER]))
        -- Fallback to Telephone if Mobile is invalid
        WHEN LEN(LTRIM(RTRIM([TELEPHONE]))) >= 9 AND [TELEPHONE] NOT LIKE '%X%' THEN LTRIM(RTRIM([TELEPHONE]))
        ELSE NULL 
    END AS Phone_No
FROM PivotedBatch
WHERE 
    -- Drop NULL or empty Image Paths
    BCert_ImagePath IS NOT NULL AND BCert_ImagePath <> ''
    AND ID_ImagePath IS NOT NULL AND ID_ImagePath <> ''
    AND Fullset_ImagePath IS NOT NULL AND Fullset_ImagePath <> ''
    
    -- Drop NULL or empty Text Fields
    AND [MEMBER NUMBER] IS NOT NULL AND LTRIM(RTRIM([MEMBER NUMBER])) <> ''
    AND [MEMBER NAME] IS NOT NULL AND LTRIM(RTRIM([MEMBER NAME])) <> ''
    AND [GENDER] IS NOT NULL AND LTRIM(RTRIM([GENDER])) <> ''
    AND [DATE OF BIRTH] IS NOT NULL AND LTRIM(RTRIM([DATE OF BIRTH])) <> ''
    
    -- Drop Identification if NULL, empty, or less than 7 characters
    AND [IDENTIFICATION] IS NOT NULL 
    AND LEN(LTRIM(RTRIM([IDENTIFICATION]))) >= 7
    
    -- Ensure at least one valid phone number exists to populate the new column
    AND (
        (LEN(LTRIM(RTRIM([MOBILE NUMBER]))) >= 9 AND [MOBILE NUMBER] NOT LIKE '%X%') OR 
        (LEN(LTRIM(RTRIM([TELEPHONE]))) >= 9 AND [TELEPHONE] NOT LIKE '%X%')
    );



WITH FinalCleanDataset AS (
    -- 1. Create the base pivoted dataset
    SELECT 
        b.BatchID,
        MAX(CASE WHEN d.TypeName = 'B_CERTIFICATE' THEN b.BatchDirectory + '\' + i.ImgPath END) AS BCert_ImagePath,
        MAX(CASE WHEN d.TypeName IN ('ID', 'IDENTIFICATION') THEN b.BatchDirectory + '\' + i.ImgPath END) AS ID_ImagePath,
        MAX(CASE WHEN d.TypeName = 'FULLSET' THEN b.BatchDirectory + '\' + i.ImgPath END) AS Fullset_ImagePath,
        MAX(CASE WHEN f.FieldName = 'MEMBER NUMBER' THEN f.value END) AS [MEMBER NUMBER],
        MAX(CASE WHEN f.FieldName = 'MEMBER NAME' THEN f.value END) AS [MEMBER NAME],
        MAX(CASE WHEN f.FieldName = 'IDENTIFICATION' THEN f.value END) AS [IDENTIFICATION],
        MAX(CASE WHEN f.FieldName = 'GENDER' THEN f.value END) AS [GENDER],
        MAX(CASE WHEN f.FieldName = 'DATE OF BIRTH' THEN f.value END) AS [DATE OF BIRTH],
        MAX(CASE WHEN f.FieldName = 'MOBILE NUMBER' THEN f.value END) AS [MOBILE NUMBER],
        MAX(CASE WHEN f.FieldName = 'TELEPHONE' THEN f.value END) AS [TELEPHONE]
    FROM dbo.batchtable b
    LEFT JOIN dbo.imgtable i 
        ON b.BatchID = i.BatchID AND LEFT(i.ImgPath, 2) = '10'
    LEFT JOIN dbo.doctable d 
        ON i.BatchID = d.BatchID AND i.DocID = d.DocID
    LEFT JOIN dbo.IndexFieldTable f 
        ON b.BatchID = f.BatchID 
    GROUP BY b.BatchID
)
-- 2. Apply all your strict filtering rules
SELECT 
    [MEMBER NUMBER], 
    COUNT(*) AS DuplicateCount
FROM FinalCleanDataset
GROUP BY [MEMBER NUMBER]
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC;


WITH PivotedBatch AS (
    -- 1. Create the base pivoted dataset
    SELECT 
        b.BatchID,
        MAX(CASE WHEN d.TypeName = 'B_CERTIFICATE' THEN b.BatchDirectory + '\' + i.ImgPath END) AS BCert_ImagePath,
        MAX(CASE WHEN d.TypeName IN ('ID', 'IDENTIFICATION') THEN b.BatchDirectory + '\' + i.ImgPath END) AS ID_ImagePath,
        MAX(CASE WHEN d.TypeName = 'FULLSET' THEN b.BatchDirectory + '\' + i.ImgPath END) AS Fullset_ImagePath,
        MAX(CASE WHEN f.FieldName = 'MEMBER NUMBER' THEN f.value END) AS [MEMBER NUMBER],
        MAX(CASE WHEN f.FieldName = 'MEMBER NAME' THEN f.value END) AS [MEMBER NAME],
        MAX(CASE WHEN f.FieldName = 'IDENTIFICATION' THEN f.value END) AS [IDENTIFICATION],
        MAX(CASE WHEN f.FieldName = 'GENDER' THEN f.value END) AS [GENDER],
        MAX(CASE WHEN f.FieldName = 'DATE OF BIRTH' THEN f.value END) AS [DATE OF BIRTH],
        MAX(CASE WHEN f.FieldName = 'MOBILE NUMBER' THEN f.value END) AS [MOBILE NUMBER],
        MAX(CASE WHEN f.FieldName = 'TELEPHONE' THEN f.value END) AS [TELEPHONE]
    FROM dbo.batchtable b
    LEFT JOIN dbo.imgtable i 
        ON b.BatchID = i.BatchID AND LEFT(i.ImgPath, 2) = '10'
    LEFT JOIN dbo.doctable d 
        ON i.BatchID = d.BatchID AND i.DocID = d.DocID
    LEFT JOIN dbo.IndexFieldTable f 
        ON b.BatchID = f.BatchID 
    GROUP BY b.BatchID
),
FilteredAndNumbered AS (
    -- 2. Apply strict filtering AND assign a row number to duplicates
    SELECT 
        BatchID,
        BCert_ImagePath,
        ID_ImagePath,
        Fullset_ImagePath,
        [MEMBER NUMBER],
        [MEMBER NAME],
        [IDENTIFICATION],
        [GENDER],
        [DATE OF BIRTH],
        CASE 
            WHEN LEN(LTRIM(RTRIM([MOBILE NUMBER]))) >= 9 AND [MOBILE NUMBER] NOT LIKE '%X%' THEN LTRIM(RTRIM([MOBILE NUMBER]))
            WHEN LEN(LTRIM(RTRIM([TELEPHONE]))) >= 9 AND [TELEPHONE] NOT LIKE '%X%' THEN LTRIM(RTRIM([TELEPHONE]))
            ELSE NULL 
        END AS Phone_No,
        -- This ranks duplicates. The highest/newest BatchID gets RowNum = 1
        ROW_NUMBER() OVER(PARTITION BY [IDENTIFICATION] ORDER BY BatchID DESC) AS RowNum
    FROM PivotedBatch
    WHERE 
        BCert_ImagePath IS NOT NULL AND BCert_ImagePath <> ''
        AND ID_ImagePath IS NOT NULL AND ID_ImagePath <> ''
        AND Fullset_ImagePath IS NOT NULL AND Fullset_ImagePath <> ''
        AND [MEMBER NUMBER] IS NOT NULL AND LTRIM(RTRIM([MEMBER NUMBER])) <> ''
        AND [MEMBER NAME] IS NOT NULL AND LTRIM(RTRIM([MEMBER NAME])) <> ''
        AND [GENDER] IS NOT NULL AND LTRIM(RTRIM([GENDER])) <> ''
        AND [DATE OF BIRTH] IS NOT NULL AND LTRIM(RTRIM([DATE OF BIRTH])) <> ''
        AND [IDENTIFICATION] IS NOT NULL AND LEN(LTRIM(RTRIM([IDENTIFICATION]))) >= 7
        AND (
            (LEN(LTRIM(RTRIM([MOBILE NUMBER]))) >= 9 AND [MOBILE NUMBER] NOT LIKE '%X%') OR 
            (LEN(LTRIM(RTRIM([TELEPHONE]))) >= 9 AND [TELEPHONE] NOT LIKE '%X%')
        )
)
-- 3. Final Selection: Keep only the first instance of every ID
SELECT 
    BatchID,
    BCert_ImagePath,
    ID_ImagePath,
    Fullset_ImagePath,
    [MEMBER NUMBER],
    [MEMBER NAME],
    [IDENTIFICATION],
    [GENDER],
    [DATE OF BIRTH],
    Phone_No
FROM FilteredAndNumbered
WHERE RowNum = 1; -- completely drops any older duplicates!