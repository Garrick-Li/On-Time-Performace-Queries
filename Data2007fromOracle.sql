DROP VIEW temp1;
DROP VIEW temp2;
DROP VIEW temp3;

CREATE VIEW temp1 AS SELECT DISTINCT tail_number, ICAO_aircraft_code, Seating_capacity FROM ModelSeats;
CREATE VIEW temp2 AS SELECT * FROM AOTP WHERE Unique_Carrier = 'CO'
ORDER BY TAIL_NUMBER, MONTH, DAY_OF_MONTH, Planned_departure_time ASC;

CREATE VIEW temp3 AS
SELECT temp2.*, temp1.icao_aircraft_code, temp1.SEATING_CAPACITY FROM (
temp2 LEFT OUTER JOIN temp1 ON
temp2.TAIL_NUMBER = temp1.TAIL_NUMBER
);

CREATE TABLE cal_CO_Garrick AS SELECT 
Year, Month, Day_of_month, Day_Of_Week,
Flight_Date, Unique_Carrier, Airline_ID, Flight_Number, Tail_Number,
Origin, Destination, Planned_departure_time, Actual_departure_time, Departure_delay,
Wheels_off_time, Wheels_on_time, Planned_arrival_time, Actual_arrival_time, Arrival_delay, Cancelled, 
ICAO_aircraft_code, Seating_capacity
FROM temp3
where tail_number is not null;

ALTER TABLE cal_CO_Garrick
ADD (PDT NUMBER, ADT NUMBER, PAT NUMBER, AAT NUMBER);

UPDATE cal_CO_Garrick
SET PDT = (Planned_Departure_Time - MOD (Planned_Departure_Time, 100))/100*60 + MOD (Planned_Departure_Time, 100),
    ADT = (Actual_Departure_Time - MOD (Actual_Departure_Time, 100))/100*60 + MOD (Actual_Departure_Time, 100),
    PAT = (Planned_Arrival_Time - MOD (Planned_Arrival_Time, 100))/100*60 + MOD (Planned_Arrival_Time, 100),
    AAT = (Actual_Arrival_Time - MOD (Actual_Arrival_Time, 100))/100*60 + MOD (Actual_Arrival_Time, 100);
    
SELECT * FROM cal_CO_Garrick
ORDER BY TAIL_NUMBER, MONTH, DAY_OF_MONTH, Planned_departure_time ASC;

CREATE VIEW seats AS
SELECT tail_number, icao_aircraft_code, seating_capacity FROM flights
WHERE seating_capacity is not null AND tail_number is not null
Order by TAIL_NUMBER ASC;

CREATE TABLE ModelSeats AS
SELECT tail_number, icao_aircraft_code, seating_capacity, COUNT(*) AS Freq FROM seats 
GROUP BY tail_number, icao_aircraft_code, seating_capacity
Order by TAIL_NUMBER ASC;

DROP VIEW seats;

CREATE VIEW seats AS SELECT * FROM ModelSeats;

DELETE FROM ModelSeats
WHERE Freq < ANY (SELECT Freq From Seats
WHERE tail_number = ModelSeats.tail_number);

SELECT DISTINCT flight_number||origin||destination FROM cal_CO_Garrick;
SELECT COUNT (*) FROM (SELECT DISTINCT flight_number||origin||destination FROM cal_CO_Garrick);

CREATE TABLE FOD_CO_Garrick AS
SELECT flight_number||origin||destination AS FOD, ICAO_AIRCRAFT_CODE, Seating_capacity ,COUNT (*) AS Freq FROM cal_WN_Garrick GROUP BY flight_number, origin, destination, ICAO_AIRCRAFT_CODE, Seating_capacity;
CREATE VIEW FOD_WN AS SELECT * FROM FOD_WN_Garrick;
DELETE FROM FOD_WN_Garrick
WHERE Freq < ANY (SELECT Freq From FOD_WN
WHERE FOD = FOD_WN_Garrick.FOD) ;
SELECT * FROM FOD_WN_Garrick ORDER BY FOD ASC;

