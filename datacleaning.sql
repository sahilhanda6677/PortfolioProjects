
--Cleaning data in sql queries

select * 
from PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------
--standardized date format


select SaleDateConverted, convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

------------------------------------------------------------------------------------------------------------------
--Populate property address data


select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


------------------------------------------------------------------------------------------------------------------
--Breaking out Address into indvidual columns (Address, City, State)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
add PropertySplitAdress nvarchar(255);

update NashvilleHousing
set PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

Alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing 

select 
PARSENAME(replace(OwnerAddress, ',', '.'),3)
,PARSENAME(replace(OwnerAddress, ',', '.'),2)
,PARSENAME(replace(OwnerAddress, ',', '.'),1)
from PortfolioProject.dbo.NashvilleHousing 

Alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),3)

Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing 

------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "sold as vacant" field.


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

with RowNumCte as(
select *,
   ROW_NUMBER() over(
   partition by ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
)
delete
from RowNumCte
where row_num>1

------------------------------------------------------------------------------------------------------------------
---Delete Unused columns

select* 
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate
