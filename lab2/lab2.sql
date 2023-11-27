/*
Lab 2 report <Axel Rönnberg axero912 and Eskil Brännerud eskbr129>
*/

/* All non code should be within SQL-comments like this */ 


/*
Drop all user created tables that have been created when solving the lab
*/

DROP TABLE IF EXISTS custom_table CASCADE;


/* Have the source scripts in the file so it is easy to recreate!*/

SOURCE company_schema.sql;
SOURCE company_data.sql;

/* Question 1 */
SELECT `jbemployee`.*
FROM `jbemployee`;
/* Answer
+------+--------------------+--------+---------+-----------+-----------+
| id   | name               | salary | manager | birthyear | startyear |
+------+--------------------+--------+---------+-----------+-----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |
+------+--------------------+--------+---------+-----------+-----------+
 */
/* Question 2 */
SELECT `jbdept`.`name`
FROM `jbdept`
ORDER BY `jbdept`.`name`;

/* Answer
+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
| Women's          |
| Women's          |
+------------------+

 */
/* Question 3 */
SELECT `jbparts`.*
FROM `jbparts`
WHERE `jbparts`.`qoh` = 0;

/* Answer
+----+-------------------+-------+--------+------+
| id | name              | color | weight | qoh  |
+----+-------------------+-------+--------+------+
| 11 | card reader       | gray  |    327 |    0 |
| 12 | card punch        | gray  |    427 |    0 |
| 13 | paper tape reader | black |    107 |    0 |
| 14 | paper tape punch  | black |    147 |    0 |
+----+-------------------+-------+--------+------+

 */
/* Question 4 */
SELECT `jbemployee`.*
FROM `jbemployee`
WHERE `jbemployee`.`salary` >= 9000 && `jbemployee`.`salary` <= 10000;

/* Answer
+-----+----------------+--------+---------+-----------+-----------+
| id  | name           | salary | manager | birthyear | startyear |
+-----+----------------+--------+---------+-----------+-----------+
|  13 | Edwards, Peter |   9000 |     199 |      1928 |      1958 |
|  32 | Smythe, Carol  |   9050 |     199 |      1929 |      1967 |
|  98 | Williams, Judy |   9000 |     199 |      1935 |      1969 |
| 129 | Thomas, Tom    |  10000 |     199 |      1941 |      1962 |
+-----+----------------+--------+---------+-----------+-----------+


 */
/* Question 5 */
SELECT `jbemployee`.*,
`jbemployee`.`startyear` - `jbemployee`.`birthyear` AS starting_age
FROM `jbemployee`;

/* Answer
+------+--------------------+--------+---------+-----------+-----------+--------------+
| id   | name               | salary | manager | birthyear | startyear | starting_age |
+------+--------------------+--------+---------+-----------+-----------+--------------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |           18 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |            1 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |           30 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |           40 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |           38 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |           32 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |           22 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |           24 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |           49 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |           34 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |           21 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |           20 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |            0 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |           21 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |           21 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |           20 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |           26 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |           21 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |           19 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |           21 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |           23 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |           19 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |           19 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |           24 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |           15 |
+------+--------------------+--------+---------+-----------+-----------+--------------+

 */
/* Question 6 */
SELECT `jbemployee`.*
FROM `jbemployee`
WHERE `jbemployee`.`name` LIKE '%son,%';

/* Answer
+----+---------------+--------+---------+-----------+-----------+
| id | name          | salary | manager | birthyear | startyear |
+----+---------------+--------+---------+-----------+-----------+
| 26 | Thompson, Bob |  13000 |     199 |      1930 |      1970 |
+----+---------------+--------+---------+-----------+-----------+

 */
/* Question 7 */
SELECT `jbitem`.*
FROM `jbitem` 
WHERE `jbitem`.`supplier` IN (SELECT
                             `jbsupplier`.`id`
                             FROM `jbsupplier`
                             WHERE `jbsupplier`.`name` = 'Fisher-Price'
);

/* Answer
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
+-----+-----------------+------+-------+------+----------+

 */
/* Question 8 */
SELECT `jbitem`.*
FROM `jbitem` 
	LEFT JOIN `jbsupplier` ON `jbitem`.`supplier` = `jbsupplier`.`id`
WHERE `jbsupplier`.`name` = 'Fisher-Price';

/* Answer
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
+-----+-----------------+------+-------+------+----------+

 */
/* Question 9 */
SELECT `jbcity`.*
FROM `jbcity`
WHERE `jbcity`.`id` IN (SELECT
                   `jbsupplier`.`city`
                   FROM `jbsupplier`)
;

/* Answer
+-----+----------------+-------+
| id  | name           | state |
+-----+----------------+-------+
|  10 | Amherst        | Mass  |
|  21 | Boston         | Mass  |
| 100 | New York       | NY    |
| 106 | White Plains   | Neb   |
| 118 | Hickville      | Okla  |
| 303 | Atlanta        | Ga    |
| 537 | Madison        | Wisc  |
| 609 | Paxton         | Ill   |
| 752 | Dallas         | Tex   |
| 802 | Denver         | Colo  |
| 841 | Salt Lake City | Utah  |
| 900 | Los Angeles    | Calif |
| 921 | San Diego      | Calif |
| 941 | San Francisco  | Calif |
| 981 | Seattle        | Wash  |
+-----+----------------+-------+

 */
/* Question 10 */
SELECT `jbparts`.`name`, `jbparts`.`color`
FROM `jbparts`
WHERE `jbparts`.`weight` > (SELECT
                           `jbparts`.`weight`
                           FROM `jbparts`
                           WHERE `jbparts`.`name` = 'card reader')
;

/* Answer
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+

 */
/* Question 11 */
SELECT `b`.`name`,
       `b`.`color`      
FROM `jbparts` a, `jbparts` b 
WHERE a.name = 'card reader' && a.weight < b.weight;

/* Answer
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+

 */
/* Question 12 */
SELECT AVG(`jbparts`.`weight`)
from `jbparts`
WHERE `jbparts`.`color` = "black";

/* Answer
+-------------------------+
| AVG(`jbparts`.`weight`) |
+-------------------------+
|                347.2500 |
+-------------------------+


 */
/* Question 13 */
SELECT `jbsupplier`.`name`, SUM(`jbsupply`.`quan` * `jbparts`.`weight`) AS `Total weight deliverd`
FROM `jbsupplier` 
	LEFT JOIN `jbcity` ON `jbsupplier`.`city` = `jbcity`.`id` 
	LEFT JOIN `jbsupply` ON `jbsupply`.`supplier` = `jbsupplier`.`id`
    	LEFT JOIN `jbparts` on `jbparts`.`id` = `jbsupply`.`part`
WHERE `jbcity`.`state` = 'Mass'
GROUP BY `jbsupplier`.`name`;

/* Answer
+--------------+-----------------------+
| name         | Total weight deliverd |
+--------------+-----------------------+
| DEC          |                  3120 |
| Fisher-Price |               1135000 |
+--------------+-----------------------+

 */
/* Question 14 */
CREATE TABLE jblikeitem ( 
id INT, name VARCHAR(20), 
dept INT NOT NULL, price INT, 
qoh INT UNSIGNED /* or, if check constraints were enforced: INT CHECK (qoh >= 0)*/, 
supplier INT NOT NULL, 
CONSTRAINT pk_item PRIMARY KEY(id)) ENGINE=InnoDB;

INSERT INTO `jblikeitem` SELECT * FROM `jbitem` WHERE `jbitem`.`price` < (SELECT AVG(`jbitem`.`price`) FROM `jbitem`);

/* Answer
Query OK, 14 rows affected (0,00 sec)
Records: 14  Duplicates: 0  Warnings: 0

 */
/* Question 15 */
CREATE VIEW jbitemview AS 
SELECT * FROM jbitem 
WHERE jbitem.price < (SELECT AVG(jbitem.price) FROM jbitem);

/* Answer
Query OK, 0 rows affected (0,00 sec)

 */
/* Question 16 */
/* Answer
A table contains the tuples themself and is therefore static.
A view is like looking at another table through tinted glasses.
The “tint” on these glasses can be a constraint like the price being less than average or something similar.
This means that if the original table is modified the view will reflect that but a table that has been filled once will not, making the view dynamic.

 */
/* Question 17 */
CREATE VIEW totaldebit1 AS
SELECT a.id, SUM(b.`quantity` * c.`price`) AS `total_cost`
FROM `jbdebit` a, `jbsale` b, `jbitem` c
WHERE a.`id` = b.`debit` AND b.`item` = c.`id`
GROUP BY a.`id`;

/* Answer
Query OK, 0 rows affected (0,02 sec)


 */
/* Question 18 */
CREATE VIEW totaldebit2 AS 
SELECT `jbdebit`.*, SUM(`jbsale`.`quantity` * `jbitem`.`price`) AS `total_cost` 
FROM `jbdebit` 
LEFT JOIN `jbsale` ON `jbsale`.`debit` = `jbdebit`.`id` 
LEFT JOIN `jbitem` ON `jbsale`.`item` = `jbitem`.`id` 
GROUP BY `jbdebit`.`id`;

/* Answer
Query OK, 0 rows affected (0,01 sec)


 */
/* Question 19 */

These queries were writtern in the oposite order and first ran that order to se wich tables had dependecies on each other.
The order was then reversed to make sure that the tables were deleted in the correct order.

DELETE `jbsale`
FROM `jbsale` 
	LEFT JOIN `jbitem` ON `jbsale`.`item` = `jbitem`.`id` 
	LEFT JOIN `jbsupplier` ON `jbitem`.`supplier` = `jbsupplier`.`id` 
	LEFT JOIN `jbcity` ON `jbsupplier`.`city` = `jbcity`.`id`
WHERE `jbcity`.`name` = 'Los Angeles';

DELETE `jbitem`
 FROM `jbitem` 
LEFT JOIN `jbsupplier` ON `jbitem`.`supplier` = `jbsupplier`.`id` 
LEFT JOIN `jbcity` ON `jbsupplier`.`city` = `jbcity`.`id` 
WHERE `jbcity`.`name` = 'Los Angeles';

DELETE `jbsupplier`
FROM `jbsupplier` 
	LEFT JOIN `jbcity` ON `jbsupplier`.`city` = `jbcity`.`id`
WHERE `jbcity`.`name` = 'Los Angeles';


/* Answer
Query OK, 1 row affected (0,00 sec)


 */
/* Question 20 */
CREATE VIEW jbSale_supply(supplier, item, quantity) AS 
SELECT `jbsupplier`.`name`, `jbitem`.`name`, `jbsale`.`quantity` 
FROM `jbsupplier` 
LEFT JOIN `jbitem` ON `jbitem`.`supplier` = `jbsupplier`.`id` 
LEFT JOIN `jbsale` ON `jbsale`.`item` = `jbitem`.`id`;


SELECT supplier, sum(quantity) as sum 
FROM jbsale_supply 
GROUP BY supplier;
/* Answer


 */

