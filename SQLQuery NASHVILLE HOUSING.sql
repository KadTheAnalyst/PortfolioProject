SELECT *
FROM ProjectPortfolio..NashvilleHousing

--STANDARDIZED DATE FORMAT

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM ProjectPortfolio..NashvilleHousing

UPDATE ProjectPortfolio..NashvilleHousing
SET SaleDate = CONVERT(DATE, SALEDATE)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE ProjectPortfolio..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SALEDATE)

--POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM ProjectPortfolio..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

--SELF JOIN
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM ProjectPortfolio..NashvilleHousing A
JOIN ProjectPortfolio..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing A
JOIN ProjectPortfolio..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM ProjectPortfolio..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS ADDRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress), LEN(PropertyAddress)) AS ADDRESS

FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PROPERTYSPLITADDRESS NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET PROPERTYSPLITADDRESS = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PROPERTYSPLITCITY NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET PROPERTYSPLITCITY = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress), LEN(PropertyAddress))

SELECT *
FROM ProjectPortfolio..NashvilleHousing

SELECT OwnerAddress
FROM ProjectPortfolio..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OWNERSPLITADDRESS NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OWNERSPLITADDRESS = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OWNERSPLITCITY NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OWNERSPLITCITY = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OWNERSPLITSTATE NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OWNERSPLITSTATE = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

--CHANGE Y AND N  TO YES AND NO IN  SOLDASVACANT FIELD 
SELECT DISTINCT(SOLDASVACANT), COUNT(SOLDASVACANT)
FROM ProjectPortfolio..NashvilleHousing
GROUP BY SOLDASVACANT
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM ProjectPortfolio..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM ProjectPortfolio..NashvilleHousing

--REMOVE DUPLICATES

WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PROPERTYADDRESS, SALEPRICE, SALEDATE, LEGALREFERENCE ORDER BY
UNIQUEID ) row_num
FROM ProjectPortfolio..NashvilleHousing
)

SELECT *
--DELETE
FROM ROWNUMCTE
WHERE row_num > 1
--ORDER BY PROPERTYADDRESS

--DELETE UNUSED COLUMNS
SELECT *
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN OWNERADDRESS, TAXDISTRICT, PROPERTYADDRESS, SALEDATE