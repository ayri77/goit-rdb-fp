/*
1. Завантажте дані:

Створіть схему pandemic у базі даних за допомогою SQL-команди.
Оберіть її як схему за замовчуванням за допомогою SQL-команди.
Імпортуйте дані за допомогою Import wizard так, як ви вже робили це у темі 3.
Продивіться дані, щоб бути у контексті.
💡 Як бачите, атрибути Entity та Code постійно повторюються. Позбудьтеся цього за допомогою нормалізації даних.

2. Нормалізуйте таблицю infectious_cases до 3ї нормальної форми. Збережіть у цій же схемі дві таблиці з нормалізованими даними.
Виконайте запит SELECT COUNT(*) FROM infectious_cases , щоб ментор міг зрозуміти, скільки записів ви завантажили у базу даних із файла.

3. Проаналізуйте дані:
Для кожної унікальної комбінації Entity та Code або їх id порахуйте середнє, мінімальне, максимальне значення та суму для атрибута Number_rabies.
💡 Врахуйте, що атрибут Number_rabies може містити порожні значення ‘’ — вам попередньо необхідно їх відфільтрувати.

Результат відсортуйте за порахованим середнім значенням у порядку спадання.
Оберіть тільки 10 рядків для виведення на екран.

4. Побудуйте колонку різниці в роках.
Для оригінальної або нормованої таблиці для колонки Year побудуйте з використанням вбудованих SQL-функцій:
атрибут, що створює дату першого січня відповідного року,
💡 Наприклад, якщо атрибут містить значення ’1996’, то значення нового атрибута має бути ‘1996-01-01’.
атрибут, що дорівнює поточній даті,
атрибут, що дорівнює різниці в роках двох вищезгаданих колонок.
💡 Перераховувати всі інші атрибути, такі як Number_malaria, не потрібно.
👉🏼 Для пошуку необхідних вбудованих функцій вам може знадобитися матеріал до теми 7.

5. Побудуйте власну функцію.
Створіть і використайте функцію, що будує такий же атрибут, як і в попередньому завданні: функція має приймати на вхід значення року, 
а повертати різницю в роках між поточною датою та датою, створеною з атрибута року (1996 рік → ‘1996-01-01’).
💡 Якщо ви не виконали попереднє завдання, то можете побудувати іншу функцію — функцію, що рахує кількість захворювань за певний період. 
Для цього треба поділити кількість захворювань на рік на певне число: 12 — для отримання середньої кількості захворювань на місяць, 4 — на квартал або 2 — на півріччя. 
Таким чином, функція буде приймати два параметри: кількість захворювань на рік та довільний дільник. Ви також маєте використати її — запустити на даних. 
Оскільки не всі рядки містять число захворювань, вам необхідно буде відсіяти ті, що не мають чисельного значення (≠ ‘’).
*/

-- Final Project: Relational Databases
/* turn on import from local files */
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- Step 1.1. Create schema and select it
DROP SCHEMA IF EXISTS pandemic;
CREATE SCHEMA pandemic;
USE pandemic;
-- Step 1.2. Create tabe and import data
DROP TABLE IF EXISTS infectious_cases;

CREATE TABLE infectious_cases (
    Entity VARCHAR(255),
    Code VARCHAR(50),
    Year YEAR,
    Number_yaws BIGINT NULL,
    polio_cases BIGINT NULL,
    cases_guinea_worm BIGINT NULL,
    Number_rabies BIGINT NULL,
    Number_malaria BIGINT NULL,
    Number_hiv BIGINT NULL,
    Number_tuberculosis BIGINT NULL,
    Number_smallpox BIGINT NULL,
    Number_cholera_cases BIGINT NULL
);

LOAD DATA LOCAL INFILE 'C:/Users/pbori/Documents/Courses/Neoversity/Databases/Homework/goit-rdb-fp/data/infectious_cases.csv'
INTO TABLE infectious_cases
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
-- Entity,Code,Year,Number_yaws,polio_cases,cases_guinea_worm,Number_rabies,Number_malaria,Number_hiv,Number_tuberculosis,Number_smallpox,Number_cholera_cases
(
    Entity,
    Code,
    Year,
    @Number_yaws,
    @polio_cases,
    @cases_guinea_worm,
    @Number_rabies,
    @Number_malaria,
    @Number_hiv,
    @Number_tuberculosis,
    @Number_smallpox,
    @Number_cholera_cases
)
SET
    Number_yaws = NULLIF(@Number_yaws, ''),
    polio_cases = NULLIF(@polio_cases, ''),
    cases_guinea_worm = NULLIF(@cases_guinea_worm, ''),
    Number_rabies = NULLIF(@Number_rabies, ''),
    Number_malaria = NULLIF(@Number_malaria, ''),
    Number_hiv = NULLIF(@Number_hiv, ''),
    Number_tuberculosis = NULLIF(@Number_tuberculosis, ''),
    Number_smallpox = NULLIF(@Number_smallpox, ''),
    Number_cholera_cases = NULLIF(@Number_cholera_cases, '');
-- Step 2. Inspect imported table
DESCRIBE infectious_cases;

SELECT COUNT(*) AS total_rows
FROM infectious_cases;

SELECT *
FROM infectious_cases
LIMIT 10;

-- Step 3. Normalize data to 3NF
DROP TABLE IF EXISTS entities;
CREATE TABLE entities (
    entity_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(255) NOT NULL,
    entity_code VARCHAR(50) NOT NULL,
    UNIQUE (entity_name, entity_code)
);
DROP TABLE IF EXISTS diseases;
CREATE TABLE diseases (
    disease_id INT AUTO_INCREMENT PRIMARY KEY,
    disease_name VARCHAR(100) NOT NULL UNIQUE
);
DROP TABLE IF EXISTS infectious_cases_normalized;
CREATE TABLE infectious_cases_normalized (
    case_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    year YEAR NOT NULL,
    disease_id INT NOT NULL,
    case_count BIGINT NOT NULL,
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id),
    FOREIGN KEY (disease_id) REFERENCES diseases(disease_id)
);

/* Data injection */ 

-- entities
INSERT INTO entities (entity_name, entity_code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

-- diseases
INSERT INTO diseases (disease_name)
VALUES
    ('Number_yaws'),
    ('polio_cases'),
    ('cases_guinea_worm'),
    ('Number_rabies'),
    ('Number_malaria'),
    ('Number_hiv'),
    ('Number_tuberculosis'),
    ('Number_smallpox'),
    ('Number_cholera_cases');

-- infectious_cases_normalized
INSERT INTO infectious_cases_normalized (entity_id, year, disease_id, case_count)
SELECT e.entity_id, ic.Year, d.disease_id, ic.Number_yaws
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
JOIN diseases d
    ON d.disease_name = 'Number_yaws'
WHERE ic.Number_yaws IS NOT NULL

UNION ALL

SELECT e.entity_id, ic.Year, d.disease_id, ic.polio_cases
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
JOIN diseases d
    ON d.disease_name = 'polio_cases'
WHERE ic.polio_cases IS NOT NULL

UNION ALL

SELECT e.entity_id, ic.Year, d.disease_id, ic.cases_guinea_worm
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
JOIN diseases d
    ON d.disease_name = 'cases_guinea_worm'
WHERE ic.cases_guinea_worm IS NOT NULL

UNION ALL

SELECT e.entity_id, ic.Year, d.disease_id, ic.Number_rabies
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
JOIN diseases d
    ON d.disease_name = 'Number_rabies'
WHERE ic.Number_rabies IS NOT NULL

UNION ALL

SELECT e.entity_id, ic.Year, d.disease_id, ic.Number_malaria
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
JOIN diseases d
    ON d.disease_name = 'Number_malaria'
WHERE ic.Number_malaria IS NOT NULL

UNION ALL

SELECT e.entity_id, ic.Year, d.disease_id, ic.Number_hiv
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
JOIN diseases d
    ON d.disease_name = 'Number_hiv'
WHERE ic.Number_hiv IS NOT NULL

UNION ALL

SELECT e.entity_id, ic.Year, d.disease_id, ic.Number_tuberculosis
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
JOIN diseases d
    ON d.disease_name = 'Number_tuberculosis'
WHERE ic.Number_tuberculosis IS NOT NULL

UNION ALL

SELECT e.entity_id, ic.Year, d.disease_id, ic.Number_smallpox
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
JOIN diseases d
    ON d.disease_name = 'Number_smallpox'
WHERE ic.Number_smallpox IS NOT NULL

UNION ALL

SELECT e.entity_id, ic.Year, d.disease_id, ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
JOIN diseases d
    ON d.disease_name = 'Number_cholera_cases'
WHERE ic.Number_cholera_cases IS NOT NULL;

-- check new tables
SELECT COUNT(*) AS total_entities FROM entities;
SELECT COUNT(*) AS total_diseases FROM diseases;
SELECT COUNT(*) AS total_normalized_rows FROM infectious_cases_normalized;

SELECT *
FROM infectious_cases_normalized
LIMIT 10;

-- Step 4. Analytical query for Number_rabies
SELECT 
	e.entity_id,
    e.entity_code,
	e.entity_name as entity,
    AVG(icn.case_count) AS avg_rabies_cases,
    MAX(icn.case_count) AS max_rabies_cases,
    MIN(icn.case_count) AS min_rabies_cases,
    SUM(icn.case_count) AS total_rabies_cases
FROM infectious_cases_normalized AS icn
JOIN entities AS e
    ON icn.entity_id = e.entity_id
JOIN diseases AS d
    ON icn.disease_id = d.disease_id
WHERE d.disease_name = 'Number_rabies'
GROUP BY
    e.entity_name,
    e.entity_id,
    e.entity_code    
ORDER BY avg_rabies_cases DESC
LIMIT 10;

-- Step 5. Build year difference columns
-- The required date-based values are generated in the SELECT query instead of being stored as physical columns,
-- because they are derived attributes and persisting them would be redundant and impractical.
SELECT
    `Year`,
    STR_TO_DATE(CONCAT(`Year`, '-01-01'), '%Y-%m-%d') AS year_start_date,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(`Year`, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    ) AS year_difference
FROM infectious_cases
LIMIT 10;

-- Step 6. Create custom function
DROP FUNCTION IF EXISTS year_difference;
DELIMITER //
CREATE FUNCTION year_difference(input_year INT)
RETURNS INT
NOT DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    );
END //
DELIMITER ;

SELECT
    `Year`,
    year_difference(`Year`) AS year_difference
FROM infectious_cases
LIMIT 10;
