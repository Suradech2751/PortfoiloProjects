------------------CLEANING DATA----------------------------

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Data Format

--STEP 1 SaleDate: COVERT THE DateTime To date in 

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

--STEP 2 PropertyAddress: FILL OUT SOME MISSING PropertyAddress

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

--STEP 3 OWERNERAddress

--FIND OUT SOME NULL
SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

--FILL OUT THE DATA
SELECT a.ParcelID, a.OwnerAddress, b.ParcelID, b.OwnerAddress
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerAddress is NOT NULL and b.OwnerAddress is Null
ORDER BY a.ParcelID

--CREATE NEW SEPARATED COLUMN

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing 

--ADD 3 COLUMNS FOR SEPARATED ADDRESS

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress nvarchar(225)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM NashvilleHousing

SELECT OwnerAddress, OwnerSplitAddress
FROM NashvilleHousing

---

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity nvarchar(225)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
FROM NashvilleHousing

SELECT OwnerAddress, OwnerSplitCity
FROM NashvilleHousing

---

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState nvarchar(225)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

SELECT OwnerAddress, OwnerSplitState
FROM NashvilleHousing

--CHECK

SELECT *
FROM NashvilleHousing

--STEP 4 OWNERNAME: Split Name And LAst Name

--Check some blank
SELECT a.ParcelID, a.OwnerName, b.ParcelID, b.OwnerName
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.OwnerName is NOT NULL and b.OwnerName is NULL

SELECT OwnerName, OwnerLastName, OwnerFirstName
FROM NashvilleHousing

ALTER TABLE NashVilleHousing
ADD OwnerFirstName nvarchar(255)

ALTER TABLE NashVilleHousing
ADD OwnerLastName nvarchar(255)

UPDATE NashvilleHousing
SET OwnerLastName = SUBSTRING(OwnerName, 1, CHARINDEX(',', OwnerName)-1)

SELECT
	SUBSTRING(OwnerName, 1, CHARINDEX(',', OwnerName)-0.1) AS OwnerLastName,
	SUBSTRING(OwnerName,CHARINDEX(',', OwnerName)+1, LEN(OwnerName)) AS OwnerFirstName
FROM NashvilleHousing
WHERE OwnerName is NOT NULL

UPDATE NashvilleHousing
SET
	OwnerLastName = SUBSTRING(OwnerName, 1, CHARINDEX(',', OwnerName)-0.1)
	
UPDATE NashvilleHousing
SET
	OwnerFirstName = SUBSTRING(OwnerName,CHARINDEX(',', OwnerName)+1, LEN(OwnerName))

SELECT *
FROM NashvilleHousing

SELECT
	SUBSTRING(OwnerName, 1, CHARINDEX(',', OwnerName)-1) AS OwnerLastName 
FROM NashvilleHousing
WHERE OwnerName is NOT NULL

SELECT UPPER(OwnerFirstName), UPPER(OwnerLastName)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET OwnerFirstName = UPPER(OwnerFirstName),
	OwnerLastName = UPPER(OwnerLastName)

--STEP 5 SoldAsVecant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--TRANSFORM "Y" AND "N" TO ----->  "YES" AND "NO"

SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

--UPDATE Yes AND No

UPDATE NashvilleHousing
SET SoldAsVacant =
(SELECT
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END)
FROM NashvilleHousing

--CHECK

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

--STEP 6 REMOVE SOME DUPLICATED ROWS BY CTEs

WITH RowNumCTE AS
(SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID, 
			PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
)
--DELETE
SELECT *
FROM RowNumCTE

--NONE row_num>1

SELECT *
FROM NashvilleHousing

--STEP 7 REMOVE DUPLICATED COLUMS (BEFORE CLEANING)

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, SaleDate, OwnerName, PropertyAddress
