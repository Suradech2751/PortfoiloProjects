------------------CLEANING DATA----------------------------

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Data Format

STEP 1 SaleDate: COVERT THE DateTime To date in 

SELECT SaleDate, CONVERT(DATE,SaleDate) AS SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

--NOT EFFECTED
UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

--SHOULD DO

--ADD NEW COLUMN

ALTER TABLE NashVilleHousing
ADD SaleDateConverted Date

--UPDATE SaleDateConverted
--ไม่จำเป็นต้องมี WHERE มันจะเรียงลงไปเลย

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing

STEP 2 PropertyAddress: FILL OUT SOME MISSING PropertyAddress

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT ParcelID, PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID

--USE JOIN TO ITSELF FOR COMPARE THE DATA

--ISNULL = REPLACEMENT FOR NULL DATA

--ISNULL(IF A NULL, USE THIS TO REPLACE)

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--UPDATE THE REPLACED DATA

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing AS a
	JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

SELECT *
FROM NashvilleHousing

--BREAKING OUT THE ADDRESS TO PropertyAddress = (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

--USE SUBSTRING TO FIND FIRST NUMBER UNTILE FOUND THE COMMA ,
--AND DELETE THE COMMA BY -1
------------WE GOT SEPERATED ADDRESS------------

--USE SUBSTRING TO FIND THE COMMA IS THE FIRST THING WE NEED US "CHARINDEX" +1 FOR DON'T PICK COMMA
--AND END WITH LEN() FOR ANY LENGTH OF TEXT IN "PropertyAddress" Colunm
------------WE GOT SEPERATED CITY----------------
SELECT 
	SUBSTRING(PropertyAddress ,1,CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

--UPDATE THE ADDRESS AND CITY
ALTER TABLE NashVilleHousing
ADD PropertySplitAddress nvarchar(225),
	PropertySplitCity nvarchar(225)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress ,1,CHARINDEX(',', PropertyAddress)-1)

UPDATE NashvilleHousing
SET	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing

STEP 3 OWERNERAddress
COUNTINUE AT 27.09
