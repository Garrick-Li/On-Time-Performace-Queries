CREATE TABLE TotalData2007
(
Year INT, 
Month INT, 
Day_of_month INT, 
Day_Of_Week INT,
Flight_Date varchar(10), 
Unique_Carrier varchar(2), 
Airline_ID INT, 
Flight_Number INT, 
Tail_Number varchar(10),
Origin varchar(3), 
Destination varchar(3), 
Planned_departure_time INT, 
Actual_departure_time INT, 
Departure_delay INT,
Wheels_off_time INT, 
Wheels_on_time INT, 
Planned_arrival_time INT, 
Actual_arrival_time INT, 
Arrival_delay INT, 
Cancelled INT, 
PDT INT, 
ADT INT, 
PAT INT, 
AAT INT
);

LOAD DATA LOCAL INFILE '/Users/garrickli/Desktop/export.csv' 
INTO TABLE TotalData2007
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ALTER TABLE TotalData2007
ADD COLUMN ID INT;

SET SQL_SAFE_UPDATES=0;
SET @i = 0;
UPDATE TotalData2007
SET ID = (@i:=@i+1) WHERE 1<>2;

CREATE TABLE CarrierUS AS
SELECT * FROM TotalData2007;
 
ALTER TABLE CarrierUS
ADD COLUMN (
CID INT,
CDay_of_month INT,
CTail_Number varchar(10),
COrigin varchar(3),
CDestination varchar(3),
CPDT INT,
CADT INT,
CPAT INT,
CAAT INT);

DELIMITER //
CREATE PROCEDURE basic_while()
BEGIN
   SET @i := 1;
   WHILE @i <= 1000 DO
      UPDATE CarrierUS
		SET CDay_of_month = (SELECT Day_of_month FROM TotalData2007 WHERE ID = @i+1)
		WHERE ID = @i;
      SET @i := @i + 1;
   END WHILE;
END//
DELIMITER ;
CALL basic_while;

SET @i = 1;
UPDATE CarrierUS
SET CDay_of_month = (SELECT Day_of_month FROM TotalData2007 WHERE ID = (@i:=@i+1));

SET @i = 1;
UPDATE CarrierUS
SET CTail_Number = (SELECT Tail_Number FROM TotalData2007 WHERE ID = (@i:=@i+1));

SET @i = 1;
UPDATE CarrierUS
SET COrigin = (SELECT Origin FROM TotalData2007 WHERE ID = (@i:=@i+1));

SET @i = 1;
UPDATE CarrierUS
SET CDestination = (SELECT Destination FROM TotalData2007 WHERE ID = (@i:=@i+1));

SET @i = 1;
UPDATE CarrierUS
SET CPDT = (SELECT PDT FROM TotalData2007 WHERE ID = (@i:=@i+1));

SET @i = 1;
UPDATE CarrierUS
SET CADT = (SELECT ADT FROM TotalData2007 WHERE ID = (@i:=@i+1));

SET @i = 1;
UPDATE CarrierUS
SET CPAT = (SELECT PAT FROM TotalData2007 WHERE ID = (@i:=@i+1));

SET @i = 1;
UPDATE CarrierUS
SET CAAT = (SELECT AAT FROM TotalData2007 WHERE ID = (@i:=@i+1));

SELECT @i;

SELECT * FROM CarrierUS;


INSERT INTO CarrierUS
SELECT * FROM (TotalData2007 INNER JOIN t2
ON TotalData2007.ID = t2.CID)
WHERE ID = 1;

ALTER TABLE USAirway
ADD COLUMN (ConnYN INT, ConnTime INT, Slack INT, PDelay INT);

UPDATE USAirway
SET ConnYN = CASE
				WHEN Day_of_month = CDay_of_month AND  
					 Tail_Number = CTail_Number AND
					 Cancelled = 0
				THEN 1
				ELSE 0
				END;

UPDATE USAirway
SET ConnTime = CASE
				WHEN ConnYN = 1
				THEN CPDT - PAT
				ELSE 0
				END;

UPDATE USAirway
SET Slack = CASE
				WHEN ConnYN = 1
				THEN MAX (0 , (ConnTime - 30))
				ELSE -1
				END;

UPDATE USAirway
SET PDelay = CASE
				WHEN ConnYN = 1
				THEN MAX (Arrival_delay - Slack, 0)
				ELSE -1
				END;

Show processlist;
Kill 19;

SELECT * FROM TotalData2007;
SELECT COUNT(*) FROM (SELECT * FROM TotalData2007 WHERE AAT =0 and Wheels_on_time = 0 and Cancelled = 0) as a;