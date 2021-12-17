USE master;
GO

USE Portfolio;
GO

--NOTE: Units used are Imperial but are converted towards the end to metric apart from range(Nautical Miles) and speed (Knots)

--/////////////////////////////////////////////////////
--Viewing the columns of the required data for analysis
SELECT Company,
		Model,
		EngineType, 
		RangeNM, 
		GrossWeight,
		HorsePower,
		MaxSpeed, 
		StallSpeed,
		[Length], 
		WingSpan
FROM dbo.[Airplane]
ORDER BY GrossWeight;

--Deleted Sierra Industries, certain models of RAM Aircraft, and LP Machen Inc. airplane companies due to lack of data regarding their plane models
--updating their values to the average of other aircraft would not be representative of the actual average later on
DELETE FROM Airplane
WHERE (GrossWeight IN ('Orig','NC')) OR (Company IN ('Sierra Industries')) OR (Company IN ('Rockwell Meyers 200') AND RangeNM IS NULL);

--/////////////////////////////////////////////////////////
--Checking for spelling mistakes in Company and Engine Type

--Company

SELECT DISTINCT Company
FROM Airplane;

--updating company names
UPDATE Airplane
SET Company = CASE Company
				 WHEN 'De Havilland (See also Bombardier)' THEN 'De Havilland'
				 WHEN 'Beechcraft (Hawker Beechcraft)' THEN 'Beechcraft'
				 WHEN 'Eurofox, Rollison LSA Inc' THEN 'Eurofox/Rollison LSA Inc'
				 WHEN 'Luscombe Aircraft (Quartz Mountain Aero)' THEN 'Luscombe Aircraft/Quartz Mountain Aero'
			 END 
WHERE Company IN ('De Havilland (See also Bombardier)','Beechcraft (Hawker Beechcraft)', 'Eurofox, Rollison LSA Inc','Luscombe Aircraft (Quartz Mountain Aero)');

--Engine type

SELECT DISTINCT EngineType
FROM Airplane;

--updated engine code names to engine type

UPDATE dbo.[Airplane]
SET EngineType= CASE EngineType 
					 WHEN 'piston' THEN 'Piston'
					 WHEN 'Pistion' THEN 'Piston'
					 WHEN 'PT6A-21' THEN 'Turboprop'
					 WHEN 'TSIO 520' THEN 'Piston'
					 WHEN 'PT6A-35' THEN 'Jetprop'
					 WHEN 'IO550' THEN 'Piston'
				 END
WHERE EngineType IN ('piston','Pistion','PT6A-21', 'TSIO 520', 'PT6A-35', 'IO550');

--//////////////////////
--Converting data types and changing improper values
--During the import process columns could not be converted from their original string format due to values containing symbols and letters,
--thus a manual conversion was made after an inspection and update of the columns to find the improper values

--RangeNM

SELECT Distinct RangeNM
FROM Airplane
Order BY RangeNM;

UPDATE dbo.Airplane
SET RangeNM= CASE RangeNM
				WHEN '1,000+' THEN '1000'
				WHEN '600nm' THEN '600'
			END
WHERE RangeNM IN ('1,000+', '600nm');

ALTER TABLE Airplane
	ALTER COLUMN RangeNM int;
GO

--GrossWeight
ALTER TABLE Airplane
	ALTER COLUMN GrossWeight int;
GO

--HorsePower
--A few values had decimal points thus Horsepower was changed to float
--the following were values that had wording that prevented the conversion

UPDATE dbo.[Airplane]
SET HorsePower= CASE HorsePower
					 WHEN '100 hp' THEN '100'
					 WHEN '1000 dry' THEN '1000'
					 WHEN '940wet' THEN '940'
				 END
WHERE HorsePower IN ('100 hp', '1000 dry', '940wet');

ALTER TABLE Airplane
	ALTER COLUMN HorsePower float;
GO

--MaxSpeed
SELECT Company,
		MaxSpeed 
FROM dbo.[Airplane]
ORDER BY EngineType;

UPDATE dbo.[Airplane]
SET MaxSpeed= REPLACE(MaxSpeed, ' Mach','')
WHERE MaxSpeed LIKE ('% Mach');

UPDATE dbo.[Airplane]
SET MaxSpeed= REPLACE(MaxSpeed, '+','')
WHERE MaxSpeed LIKE ('%+');

UPDATE dbo.Airplane
SET MaxSpeed='0'+MaxSpeed
WHERE MaxSpeed Like '%.%'

ALTER TABLE Airplane
	ALTER COLUMN MaxSpeed float;
GO

--1 mach = 644 knots
UPDATE Airplane
SET MaxSpeed= (MaxSpeed*644.0)
WHERE MaxSpeed LIKE '%0.%'

--StallSpeed
SELECT DISTINCT StallSpeed
FROM Airplane;

UPDATE dbo.[Airplane]
SET StallSpeed= CASE StallSpeed
					 WHEN '44kcas' THEN '44'
					 WHEN '49kts' THEN '49'
				 END
WHERE StallSpeed IN ('44kcas', '49kts');

ALTER TABLE Airplane
	ALTER COLUMN StallSpeed float;
GO

--Length
SELECT DISTINCT [Length]
FROM Airplane;

--Updated '/' to ' ' as that allows for easier separation of feet and inches
UPDATE Airplane 
SET [Length]  =REPLACE([Length],'/',' ')
WHERE [Length] LIKE '%/%'

SELECT [Length]
FROM Airplane
WHERE [Length] NOT LIKE '% %';

--Viewing Length in Feet and Inches prior to column update
SELECT [Length], 
	TRIM(SUBSTRING([Length], 1, CHARINDEX(' ', [Length]))) AS LengthFeet,
	SUBSTRING([Length],  CHARINDEX(' ', [LENGTH])+1,2) AS LengthInches
FROM Airplane
ORDER BY [Length];

UPDATE Airplane
SET [Length] = '31 50'
WHERE [Length] LIKE '3150';

--As these values are non discriptive, they will be removed in order to add an average value 
UPDATE Airplane
SET [Length] = NULL
WHERE [Length] LIKE 'Orig';

UPDATE Airplane
SET [Length] = NULL
WHERE [Length] LIKE 'N C';

--Two columns are created for separate length in feet and in inches
--Column for Length in feet
ALTER TABLE Airplane
ADD LengthFeet INT;

UPDATE Airplane
SET LengthFeet=TRIM(SUBSTRING([Length], 1, CHARINDEX(' ', [Length])));

--Column for Length in inches
ALTER TABLE Airplane
ADD LengthInches SMALLINT;

UPDATE Airplane
SET LengthInches=SUBSTRING([Length],  CHARINDEX(' ', [LENGTH])+1,2);

SELECT [Length], LengthFeet, LengthInches
FROM Airplane
ORDER BY [Length];

--Updating values that are not displayed according to the right dimension
SELECT * 
FROM Airplane
WHERE LengthFeet>100;

UPDATE Airplane
SET LengthFeet= 111, LengthInches=0
WHERE [Length]='111';

--Wingspan
SELECT WingSpan
FROM Airplane
Order BY WingSpan;

UPDATE Airplane 
SET WingSpan  =REPLACE([Length],'/',' ')
WHERE WingSpan LIKE '%/%';

SELECT WingSpan
FROM Airplane
WHERE WingSpan NOT LIKE '% %';

UPDATE Airplane
SET WingSpan = NULL
WHERE WingSpan LIKE 'Orig';

UPDATE dbo.Airplane
SET WingSpan = ' '
WHERE WingSpan LIKE '%.%'

--Viewing WingSpan in Feet and Inches prior to column update
SELECT WingSpan, 
	TRIM(SUBSTRING(WingSpan, 1, CHARINDEX(' ', [WingSpan]))) AS WingSpanFeet,
	SUBSTRING(WingSpan,  CHARINDEX(' ', [WingSpan])+1,2) AS WingSpanInches
FROM Airplane
ORDER BY WingSpan;

--Column for WingSpan in feet
ALTER TABLE Airplane
ADD WingSpanFeet INT;

UPDATE Airplane
SET WingSpanFeet=TRIM(SUBSTRING(WingSpan, 1, CHARINDEX(' ', [Length])));

--Column for WingSpan in inches
ALTER TABLE Airplane
ADD WingspanInches SMALLINT;

UPDATE Airplane
SET WingSpanInches=SUBSTRING(WingSpan,  CHARINDEX(' ', [LENGTH])+1,2);

SELECT WingSpan, WingSpanFeet, WingSpanInches
FROM Airplane
Order BY WingSpan;

--Updating values that are not displayed according to the right dimension
UPDATE Airplane
SET WingSpanFeet= 104, WingSpanInches=0
WHERE WingSpan='104';

SELECT WingSpan, WingSpanFeet, WingSpanInches
FROM Airplane
WHERE WingSpanInches>12;

UPDATE dbo.[Airplane]
SET WingspanFeet= 58, WingspanInches= 0
WHERE Wingspan='58';

UPDATE dbo.[Airplane]
SET WingspanFeet= 26, WingspanInches= 0
WHERE Wingspan='26';

UPDATE dbo.[Airplane]
SET WingspanInches= 5
WHERE Wingspan='31 50';

UPDATE dbo.[Airplane]
SET WingspanInches= 6
WHERE Wingspan='68 63';

--//////////////////////////
--Adding data to null values

--Viewing the updated columns
SELECT Company,
		EngineType, 
		RangeNM, 
		GrossWeight,
		HorsePower,
		MaxSpeed, 
		StallSpeed,
		[Length],
		LengthFeet,
		LengthInches,
		WingSpan,
		WingSpanFeet,
		WingSpanInches
FROM dbo.[Airplane]
ORDER BY WingspanFeet, EngineType;

--Here the average values were taken according to the column and inserted where NULL values are present

--RangeNM
SELECT EngineType, AVG(RangeNM) 'AverageRange'
FROM Airplane
Group by EngineType --1000, 1377, 646, 950, 3059

UPDATE Airplane
SET RangeNM= 1377
WHERE EngineType='PropJet' AND RangeNM IS NULL;

UPDATE Airplane
SET RangeNM= 646
WHERE EngineType='Piston' AND RangeNM IS NULL;

UPDATE Airplane
SET RangeNM= 950
WHERE EngineType='TurboProp' AND RangeNM IS NULL;

UPDATE Airplane
SET RangeNM= 3059
WHERE EngineType='Jet' AND RangeNM IS NULL;

--GrossWeight
SELECT EngineType, AVG(GrossWeight) 'AverageWeight'
FROM Airplane
GROUP BY EngineType;

UPDATE Airplane
SET GrossWeight= 33897
WHERE EngineType='Jet' AND GrossWeight IS NULL;

UPDATE Airplane
SET GrossWeight= 10582
WHERE EngineType='Propjet' AND GrossWeight IS NULL;

--MaxSpeed
SELECT EngineType, AVG(MaxSpeed) 'AverageMaxSpeed'
FROM Airplane
GROUP BY EngineType;

UPDATE Airplane
SET MaxSpeed= 494.89
WHERE EngineType='Jet' AND MaxSpeed IS NULL;

UPDATE Airplane
SET MaxSpeed= 266.42
WHERE EngineType='Propjet' AND MaxSpeed IS NULL;

UPDATE Airplane
SET MaxSpeed= 167.32
WHERE EngineType='Piston' AND MaxSpeed IS NULL;

--StallSpeed
SELECT EngineType,AVG(StallSpeed) 'AverageStallSpeed'
FROM Airplane
GROUP BY EngineType;

UPDATE Airplane
SET StallSpeed= 88.48
WHERE EngineType='Jet' AND StallSpeed IS NULL;

UPDATE Airplane
SET StallSpeed= 73.56
WHERE EngineType='Propjet' AND StallSpeed IS NULL;

UPDATE Airplane
SET StallSpeed= 53.91
WHERE EngineType='Piston' AND StallSpeed IS NULL;

--LengthFeet
SELECT EngineType, AVG(LengthFeet) 'AverageLengthFeet'
FROM Airplane
GROUP BY EngineType;

UPDATE Airplane
SET LengthFeet= 59
WHERE EngineType='Jet' AND LengthFeet IS NULL;

UPDATE Airplane
SET LengthFeet= 40
WHERE EngineType='Propjet' AND LengthFeet IS NULL;

UPDATE Airplane
SET LengthFeet= 26
WHERE EngineType='Piston' AND LengthFeet IS NULL;

--LengthInches
SELECT EngineType, AVG(LengthInches) 'AverageLengthInches'
FROM Airplane
GROUP BY EngineType;

UPDATE Airplane
SET LengthInches= 6
WHERE EngineType='Jet' AND LengthInches IS NULL;

UPDATE Airplane
SET LengthInches= 5
WHERE EngineType='Propjet' AND LengthInches IS NULL;

UPDATE Airplane
SET LengthInches= 4
WHERE EngineType='Piston' AND LengthInches IS NULL;

--Checking for values with whitespace
SELECT EngineType,[Length], LengthFeet, LengthInches
FROM Airplane
WHERE [Length]=' '
ORDER BY EngineType, [Length];

--WingSpanFeet
SELECT EngineType, AVG(WingSpanFeet) 'AverageWingSpanFeet'
FROM Airplane
GROUP BY EngineType;

UPDATE Airplane
SET WingSpanFeet= 59
WHERE EngineType='Jet' AND WingSpanFeet IS NULL;

UPDATE Airplane
SET WingSpanFeet= 41
WHERE EngineType='Propjet' AND WingSpanFeet IS NULL;

UPDATE Airplane
SET WingSpanFeet= 26
WHERE EngineType='Piston' AND WingSpanFeet IS NULL;

--WingspanInches
SELECT EngineType, AVG(WingspanInches) 'AverageWingSpanInches'
FROM Airplane
GROUP BY EngineType;

UPDATE Airplane
SET WingspanInches= 5
WHERE EngineType='Jet' AND WingspanInches IS NULL;

UPDATE Airplane
SET WingspanInches= 5
WHERE EngineType='Propjet' AND WingspanInches IS NULL;

UPDATE Airplane
SET WingspanInches= 4
WHERE EngineType='Piston' AND WingspanInches IS NULL;

--Checking for values with whitespace and setting proper values for wingspan feet and inches
SELECT EngineType, WingSpan, WingSpanFeet, WingSpanInches
FROM Airplane
WHERE Wingspan=' '
ORDER BY EngineType, WingSpan;

UPDATE dbo.[Airplane]
SET WingspanFeet= 26, WingspanInches= 4
WHERE Wingspan=' ';

--//////////////////////
--Removing Duplicates
SELECT Company,
		Model,
		EngineType, 
		RangeNM, 
		GrossWeight,
		HorsePower,
		MaxSpeed, 
		StallSpeed,
		[Length], 
		WingSpan,
		COUNT(*)
FROM Airplane
GROUP BY company,enginetype,model, RangeNM, 
				 GrossWeight,
				 HorsePower,
				 MaxSpeed, 
				 StallSpeed,
				 [Length], 
				 WingSpan
HAVING COUNT(*)>1;
--no duplicates found

--////////////////////////////////////////
--Making Calculations based on clean data
SELECT Company,
		EngineType, 
		RangeNM, 
		GrossWeight,
		HorsePower,
		MaxSpeed, 
		StallSpeed,
		[Length],
		LengthFeet,
		LengthInches,
		WingSpan,
		WingSpanFeet,
		WingSpanInches
FROM dbo.[Airplane]
ORDER BY WingspanFeet, EngineType;

--Final units of measurement are Nautical miles fo range, Knots for Max Speed and Stall Speed, Metric tonnes for Weight, HorsePower, and Metres for the dimensions

--Combining the dimensional values into a single number, finding the average, and converting to metric
--1 in = 0.0254 m
--1 ft = 0.3048 m

SELECT EngineType, 
		AVG(WingspanFeet) 'WF',AVG(WingspanInches) 'WI',AVG(LengthFeet) 'LF',AVG(LengthInches) 'LI',
		(AVG(WingspanFeet)*0.3048) +(AVG(WingspanInches)*0.0254) 'WidthMetric',(AVG(LengthFeet)*0.3048) +(AVG(LengthInches)*0.0254) 'LengthMetric'
FROM Airplane
GROUP BY EngineType;

--percentage of engines
SELECT DISTINCT EngineType, (100.0*COUNT(EngineType))/(SELECT DISTINCT COUNT(EngineType) FROM Airplane) 'Percentage'
FROM Airplane
GROUP BY EngineType;

--Averages of columns by engine type
SELECT DISTINCT EngineType, 
				AVG(RangeNM) AverageRange,
				((AVG(GrossWeight)*0.4535924)/1000) AverageWeight, --converted to kilos and then set to metric tonnes
				AVG(HorsePower) AverageHP,
				AVG(StallSpeed) AverageStallSpeed,
				AVG(MaxSpeed) AverageMaxSpeed
FROM Airplane
GROUP BY EngineType;

SELECT EngineType, COUNT(EngineType) 'Total'
FROM Airplane
GROUP BY EngineType;
--826 total planes