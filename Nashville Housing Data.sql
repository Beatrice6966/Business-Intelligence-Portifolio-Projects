/*

Cleaning Data in SQL Queries

*/


Select *
From NashvilleHousing.dbo.NashvilleHousingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing.dbo.NashvilleHousingData


Update NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing.dbo.NashvilleHousingData a
JOIN NashvilleHousing.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing.dbo.NashvilleHousingData a
JOIN NashvilleHousing.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From NashvilleHousing.dbo.NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From NashvilleHousing.dbo.NashvilleHousingData


ALTER TABLE NashvilleHousing.dbo.NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing.dbo.NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From NashvilleHousing.dbo.NashvilleHousingData


Select OwnerAddress
From NashvilleHousing.dbo.NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing.dbo.NashvilleHousingData




ALTER TABLE NashvilleHousing.dbo.NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing.dbo.NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing.dbo.NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From NashvilleHousing.dbo.NashvilleHousingData


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing.dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing.dbo.NashvilleHousingData


Update NashvilleHousing.dbo.NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing.dbo.NashvilleHousingData
--order by ParcelID
)


Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From NashvilleHousing.dbo.NashvilleHousingData

--Delete unused columns

Select *
From NashvilleHousing.dbo.NashvilleHousingData


ALTER TABLE NashvilleHousing.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





