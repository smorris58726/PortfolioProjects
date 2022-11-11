Select *
From Projects.dbo.NashvilleHousingData

-- standardize the sale date

Select SaleDateConverted, CONVERT(Date,SaleDate)
From Projects.dbo.NashvilleHousingData

ALTER TABLE Projects.dbo.NashvilleHousingData
Add SaleDateConverted Date;

Update Projects.dbo.NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data

Select PropertyAddress
From Projects.dbo.NashvilleHousingData


Select PropertyAddress
From Projects.dbo.NashvilleHousingData
Where PropertyAddress is null

Select *
From Projects.dbo.NashvilleHousingData
--Where PropertyAddress is null
order by ParcelID


-- If there is a duplicate parcel id in the data set and one has an address populated but another does not, I want to populate,
-- the address based on the duplicate parcel id using a join and update statement

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Projects.dbo.NashvilleHousingData a
JOIN Projects.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Projects.dbo.NashvilleHousingData a
JOIN Projects.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Break out the address into individual columns (Address, City, State)

Select PropertyAddress
From Projects.dbo.NashvilleHousingData

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From Projects.dbo.NashvilleHousingData

ALTER TABLE Projects.dbo.NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update Projects.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Projects.dbo.NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update Projects.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select *
From Projects.dbo.NashvilleHousingData


-- Looking into owner addresses and splitting them into individual columns as well this time using PARSENAME

Select OwnerAddress
From Projects.dbo.NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
From Projects.dbo.NashvilleHousingData

ALTER TABLE Projects.dbo.NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update Projects.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)


ALTER TABLE Projects.dbo.NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update Projects.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)


ALTER TABLE Projects.dbo.NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update Projects.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

Select*
From Projects.dbo.NashvilleHousingData


-- Change Y and N to Yes and No in "Sold as Vacant" filed to make the data more clear and consistent

Select Distinct(SoldAsVacant)
From Projects.dbo.NashvilleHousingData


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Projects.dbo.NashvilleHousingData
Group By SoldAsVacant
Order By 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From Projects.dbo.NashvilleHousingData

Update Projects.dbo.NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
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

				 
From Projects.dbo.NashvilleHousingData
--order by ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1
Order by
PropertyAddress



-- Delete Unused Columns

Select *
From Projects.dbo.NashvilleHousingData


ALTER TABLE Projects.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


ALTER TABLE Projects.dbo.NashvilleHousingData
DROP COLUMN SaleDate

