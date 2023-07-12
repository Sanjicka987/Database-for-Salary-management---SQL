-- SQLProject_Sanja

Create database SQLProject_Sanja
GO

USE SQLProject_Sanja
GO

Drop table if exists dbo.SeniorityLevel
Create table dbo.SeniorityLevel
(
	ID int identity(1,1) NOT Null,
	[Name] nvarchar(100) Not Null,
	CONSTRAINT [PK_SeniorityLevel] PRIMARY KEY CLUSTERED([ID] ASC)
)
GO

Insert into dbo.SeniorityLevel ([Name])
Values 
	('Junior'),
	('Intermediate'),
	('Senor'),
	('Lead'),
	('Project Manager'),
	('Division Manager'),
	('Office Manager'),
	('CEO'),
	('CTO'),
	('CIO')
GO

--Test Select * from dbo.SeniorityLevel

Drop table if exists dbo.[Location]
Create table dbo.[Location]
(
	ID int identity(1,1) NOT Null,
	[CountryName] nvarchar(100) Null,
	[Continent] nvarchar(100) Null,
	[Region] nvarchar(100) Null,
	CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED([ID] ASC)
)
GO

Insert into dbo.[Location] ([CountryName], [Continent], [Region] )
	Select top(190)  wac.CountryName,wac.Continent,wac.Region
From 
	[WideWorldImporters].[Application].[Countries] as wac
GO

--Test Select * from [dbo].[Location]

Drop table if exists dbo.Department
Create table dbo.Department
(
	ID int identity(1,1) NOT Null,
	[Name] nvarchar(100) Not Null,
	CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED([ID] ASC)
)
GO

Insert into dbo.Department ([Name])
Values 
	('Personal Banking & Operations'),
	('Digital Banking Department'),
	('Retail Banking & Marketing Department'),
	('Wealth Management & Third Party Products'),
	('International Banking Division & DFB'),
	('Treasury'),
	('Information Technology'),
	('Corporate Communications'),
	('Support Services & Branch Expansion'),
	('Human Resources')
GO

--Test Select * from dbo.Department

Drop table if exists dbo.[Employee]
Create table dbo.[Employee]
(
	ID int identity(1,1) NOT Null,
	FirstName nvarchar(100) Not Null,
	LastName nvarchar(100) Not Null,
	LocationId int Not Null,
	SenorityLevelId int Not Null,
	DepartmentId int Not Null,
	CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED([ID] ASC)
)
GO


Drop table if exists dbo.[Salary]
Create table dbo.[Salary]
(
	ID int identity(1,1) NOT Null,
	EmployeeId int Not Null,
	[Month] smallint Not Null,
	[Year] smallint Not Null,
	GrossAmount decimal(18,2) Not Null,
	NetAmount decimal(18,2) Not Null,
	RegularWorkAmount decimal(18,2) Not Null,
	BonusAmount decimal(18,2) Not Null,
	OvertimeAmount decimal(18,2) Not Null,
	[VacationDays] smallint Not Null,
	[SickLeaveDays] smallint Not Null,
	CONSTRAINT [PK_Salary] PRIMARY KEY CLUSTERED([ID] ASC)
)
GO




Alter Table dbo.Employee
ADD Constraint FK_Location_Employee Foreign Key(LocationId)
References dbo.Location(ID)
GO

Alter Table dbo.Employee
ADD Constraint FK_SeniorityLevel_Employee Foreign Key(SenorityLevelId)
References dbo.SeniorityLevel(ID)
GO

Alter Table dbo.Employee
ADD Constraint FK_Department_Employee Foreign Key(DepartmentId)
References dbo.Department(ID)
GO

Alter Table dbo.Salary
ADD Constraint FK_Employee_Salary Foreign Key(EmployeeId)
References dbo.Employee(ID)
GO


Insert Into  dbo.[Employee] (FirstName,LastName,LocationId,SenorityLevelId,DepartmentId)
	Select top(1111) 
			SUBSTRING(wap.FullName, 1, CHARINDEX(' ', wap.FullName) - 1) AS FirstName,     
			SUBSTRING(wap.FullName, CHARINDEX(' ', wap.FullName) + 1, LEN(wap.FullName) - CHARINDEX(' ', wap.FullName)) AS LastName,
			 1 as LocationID, 1 as SenorityLevelId, 1 as  DepartmentId
From [WideWorldImporters].[Application].[People] as wap

GO	

With Mycte as 
(
Select e.ID,e.SenorityLevelId,e.LocationID,e.DepartmentID,
NTILE(10) OVER (partition by s.Name ORDER BY e.ID ) RanksSenorityLevelID,
NTILE(10) OVER (partition by d.Name ORDER BY e.ID) RanksDepartmentlID,
NTILE(185) OVER (partition by l.ID ORDER BY e.ID) RanksLocationID
from dbo.Employee as e
join dbo.SeniorityLevel as s ON s.ID=e.SenorityLevelId
join dbo.Department as d On e.DepartmentId=d.ID
join dbo.Location as l On l.ID=e.LocationId
)
Update 
e
SET 
	SenorityLevelId  =Mycte.RanksSenorityLevelID,
	DepartmentID =Mycte.RanksDepartmentlID,
	LocationID =Mycte.RanksLocationID
from Mycte 
join dbo.Employee as e ON e.ID=Mycte.ID
GO

--Test select * from dbo.Employee

-- Salary


-- Create Date Damension

Drop Table if exists [dbo].[Date]
CREATE TABLE [dbo].[Date]
(
	[DateKey] Date NOT NULL
,	[Day] TINYINT NOT NULL
,	DaySuffix CHAR(2) NOT NULL
,	[Weekday] TINYINT NOT NULL
,	WeekDayName VARCHAR(10) NOT NULL
,	IsWeekend BIT NOT NULL
,	IsHoliday BIT NOT NULL
,	HolidayText VARCHAR(64) SPARSE
,	DOWInMonth TINYINT NOT NULL
,	[DayOfYear] SMALLINT NOT NULL
,	WeekOfMonth TINYINT NOT NULL
,	WeekOfYear TINYINT NOT NULL
,	ISOWeekOfYear TINYINT NOT NULL
,	[Month] TINYINT NOT NULL
,	[MonthName] VARCHAR(10) NOT NULL
,	[Quarter] TINYINT NOT NULL
,	QuarterName VARCHAR(6) NOT NULL
,	[Year] INT NOT NULL
,	MMYYYY CHAR(6) NOT NULL
,	MonthYear CHAR(7) NOT NULL
,	FirstDayOfMonth DATE NOT NULL
,	LastDayOfMonth DATE NOT NULL
,	FirstDayOfQuarter DATE NOT NULL
,	LastDayOfQuarter DATE NOT NULL
,	FirstDayOfYear DATE NOT NULL
,	LastDayOfYear DATE NOT NULL
,	FirstDayOfNextMonth DATE NOT NULL
,	FirstDayOfNextYear DATE NOT NULL
,	CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED 
	(
		[DateKey] ASC
	)
)
GO

--=========================================================================
--Creates Procedure for initial load Date Dimension
--=========================================================================
CREATE OR ALTER PROCEDURE sp_GenerateDimensionDate
AS
BEGIN
	DECLARE
		@StartDate DATE = '2001-01-01'
	,	@NumberOfYears INT = 20
	,	@CutoffDate DATE;
	SET @CutoffDate = DATEADD(YEAR, @NumberOfYears, @StartDate);

	-- prevent set or regional settings from interfering with 
	-- interpretation of dates / literals
	SET DATEFIRST 7;
	SET DATEFORMAT mdy;
	SET LANGUAGE US_ENGLISH;

	-- this is just a holding table for intermediate calculations:
	CREATE TABLE #dim
	(
		[Date]       DATE        NOT NULL, 
		[day]        AS DATEPART(DAY,      [date]),
		[month]      AS DATEPART(MONTH,    [date]),
		FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),
		[MonthName]  AS DATENAME(MONTH,    [date]),
		[week]       AS DATEPART(WEEK,     [date]),
		[ISOweek]    AS DATEPART(ISO_WEEK, [date]),
		[DayOfWeek]  AS DATEPART(WEEKDAY,  [date]),
		[quarter]    AS DATEPART(QUARTER,  [date]),
		[year]       AS DATEPART(YEAR,     [date]),
		FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0)),
		Style112     AS CONVERT(CHAR(8),   [date], 112),
		Style101     AS CONVERT(CHAR(10),  [date], 101)
	);

	-- use the catalog views to generate as many rows as we need
	INSERT INTO #dim ([date]) 
	SELECT
		DATEADD(DAY, rn - 1, @StartDate) as [date]
	FROM 
	(
		SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
			rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
		FROM
			-- on my system this would support > 5 million days
			sys.all_objects AS s1
			CROSS JOIN sys.all_objects AS s2
		ORDER BY
			s1.[object_id]
	) AS x;
	-- select * from #dim

	INSERT dbo.[Date] ([DateKey], [Day], [DaySuffix], [Weekday], [WeekDayName], [IsWeekend], [IsHoliday], [HolidayText], [DOWInMonth], [DayOfYear], [WeekOfMonth], [WeekOfYear], [ISOWeekOfYear], [Month], [MonthName], [Quarter], [QuarterName], [Year], [MMYYYY], [MonthYear], [FirstDayOfMonth], [LastDayOfMonth], [FirstDayOfQuarter], [LastDayOfQuarter], [FirstDayOfYear], [LastDayOfYear], [FirstDayOfNextMonth], [FirstDayOfNextYear])
	SELECT
		--DateKey     = CONVERT(INT, Style112),
		[DateKey]        = [date],
		[Day]         = CONVERT(TINYINT, [day]),
		DaySuffix     = CONVERT(CHAR(2), CASE WHEN [day] / 10 = 1 THEN 'th' ELSE 
						CASE RIGHT([day], 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
						WHEN '3' THEN 'rd' ELSE 'th' END END),
		[Weekday]     = CONVERT(TINYINT, [DayOfWeek]),
		[WeekDayName] = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [date])),
		[IsWeekend]   = CONVERT(BIT, CASE WHEN [DayOfWeek] IN (1,7) THEN 1 ELSE 0 END),
		[IsHoliday]   = CONVERT(BIT, 0),
		HolidayText   = CONVERT(VARCHAR(64), NULL),
		[DOWInMonth]  = CONVERT(TINYINT, ROW_NUMBER() OVER 
						(PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [date])),
		[DayOfYear]   = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [date])),
		WeekOfMonth   = CONVERT(TINYINT, DENSE_RANK() OVER 
						(PARTITION BY [year], [month] ORDER BY [week])),
		WeekOfYear    = CONVERT(TINYINT, [week]),
		ISOWeekOfYear = CONVERT(TINYINT, ISOWeek),
		[Month]       = CONVERT(TINYINT, [month]),
		[MonthName]   = CONVERT(VARCHAR(10), [MonthName]),
		[Quarter]     = CONVERT(TINYINT, [quarter]),
		QuarterName   = CONVERT(VARCHAR(6), CASE [quarter] WHEN 1 THEN 'First' 
						WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END), 
		[Year]        = [year],
		MMYYYY        = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
		MonthYear     = CONVERT(CHAR(7), LEFT([MonthName], 3) + LEFT(Style112, 4)),
		FirstDayOfMonth     = FirstOfMonth,
		LastDayOfMonth      = MAX([date]) OVER (PARTITION BY [year], [month]),
		FirstDayOfQuarter   = MIN([date]) OVER (PARTITION BY [year], [quarter]),
		LastDayOfQuarter    = MAX([date]) OVER (PARTITION BY [year], [quarter]),
		FirstDayOfYear      = FirstOfYear,
		LastDayOfYear       = MAX([date]) OVER (PARTITION BY [year]),
		FirstDayOfNextMonth = DATEADD(MONTH, 1, FirstOfMonth),
		FirstDayOfNextYear  = DATEADD(YEAR,  1, FirstOfYear)
	FROM #dim
END
GO

delete from dbo.[Date]
GO

EXEC sp_GenerateDimensionDate
GO

Drop table if exists #date
Create table #date (Mesec tinyint ,Godina int)

Insert into #date
	select distinct Month,Year
from 
	dbo.[Date]
order by 1,2

GO

Insert into dbo.Salary([EmployeeId], [Month], [Year], [GrossAmount], [NetAmount], [RegularWorkAmount], [BonusAmount], [OvertimeAmount], [VacationDays], [SickLeaveDays])
Select
	e.ID as EmployeeID,#date.Mesec as [Month],#date.Godina as [Year],(30000 + ABS(CHECKSUM(NewID())) % 30000) as GrossAmount,1,1,1,1,1,1
from 
	dbo.Employee as e
cross join #date
order by 1,2,3

GO

 Update
	dbo.Salary
 SET 
	NetAmount =GrossAmount*0.9
GO

 Update
	dbo.Salary
 SET 
	RegularWorkAmount =NetAmount*0.8
GO

 Update
	dbo.Salary
 SET 
	BonusAmount =CASE WHEN Month in(1,3,5,7,9,11) THEN (NetAmount-RegularWorkAmount) ELSE 0 END	
GO


 Update 
	dbo.Salary
 SET 
	OvertimeAmount = Case When Month in (2,4,6,8,10,12) THEN (NetAmount-RegularWorkAmount) ELSE 0 END
GO

Update 
	dbo.Salary
SET VacationDays =0,
	SickLeaveDays=0
GO

Update 
	dbo.Salary
SET 
	VacationDays =10
where 
	Month in (7,12)
GO

Update 
	dbo.salary 
Set 
	vacationDays = vacationDays + (EmployeeId % 2)
where  
	(employeeId + MONTH+ year)%5 = 1
GO

Update 
	dbo.salary 
Set 
	SickLeaveDays = EmployeeId%8, vacationDays = vacationDays + (EmployeeId % 3)
where  
	(employeeId + MONTH+ year)%5 = 2
GO

Select * from dbo.SeniorityLevel
Select * from dbo.[Location]
Select * from dbo.Department
Select * from dbo.Employee
Select * from dbo.Salary



----Proverka
--select * from dbo.salary 
--where NetAmount <> (regularWorkAmount + BonusAmount + OverTimeAmount)





 








