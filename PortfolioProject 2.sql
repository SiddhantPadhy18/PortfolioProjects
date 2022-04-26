select * from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------

-- Standardise the Sale date(Removing time part which is of no use)

select SaleDateConverted, CONVERT(date, SaleDate) from NashvilleHousing

update NashvilleHousing set SaleDate = CONVERT(date, SaleDate)

--select SaleDate, SaleDataConverted from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing set SaleDateConverted = CONVERT(Date, SaleDate)

alter table NashvilleHousing 
drop column SaleDataConverted

-----------------------------------------------------------------------------------------------------------------------------

-- Populate property address data

select a.PropertyAddress, b.PropertyAddress from
NashvilleHousing a join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from
NashvilleHousing a join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)

select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) from NashvilleHousing

select substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

-- Breaking out Owner Address

select PARSENAME(REPLACE(owneraddress, ',', '.'),3),
PARSENAME(REPLACE(owneraddress, ',', '.'),2), 
PARSENAME(REPLACE(owneraddress, ',', '.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing set OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing set OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing set OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'),1)

------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant

select distinct SoldAsVacant, count(SoldAsVacant) from NashvilleHousing
group by SoldAsVacant order by 2

update NashvilleHousing 
set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
                        When SoldAsVacant = 'N' Then 'No'
						else SoldAsVacant
						End


---------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With row_numCTE as 
(
select *, ROW_NUMBER() over (
  partition by parcelId,
               propertyaddress,
			   saleprice,
			   saledate,
			   legalreference
			   order by uniqueid
			   ) row_num 
from NashvilleHousing
)
delete from row_numCTE
where row_num>1
--order by PropertyAddress


-----------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

alter table NashvilleHousing
drop column PropertyAddress, SaleDate, OwnerAddress