/*
Cleaning Data in SQL Queries 
*/

select * from [dbo].[StateHousing]

-- Standrize Date Format 

select SaleDateConverted , convert(date,SaleDate)
from StateHousing


Update StateHousing
set SaleDate = convert(date,SaleDate)

alter table StateHousing
add SaleDateConverted date;

Update StateHousing
set SaleDateConverted = convert(date,SaleDate)

--Populate Property Address 

select *
from StateHousing
where PropertyAddress is null

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From [dbo].[StateHousing] as A
join [dbo].[StateHousing] as B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ]<> B.[UniqueID ]
where A.PropertyAddress is null


update A
set a.PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From [dbo].[StateHousing] as A
join [dbo].[StateHousing] as B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ]<> B.[UniqueID ]
where A.PropertyAddress is null


-- breaking out address into individual columns 


select 
SUBSTRING (propertyaddress,1,charindex(',' ,propertyaddress)-1) as Address
, SUBSTRING (propertyaddress,charindex(',' ,propertyaddress)+1,len(propertyaddress)) as Address 
from [dbo].[StateHousing]


alter table StateHousing
add PropertySplitaddress varchar(255);

Update StateHousing
set PropertySplitaddress = SUBSTRING (propertyaddress,1,charindex(',' ,propertyaddress)-1)

alter table StateHousing
add PropertyCity varchar(255);

Update StateHousing
set PropertyCity = SUBSTRING (propertyaddress,charindex(',' ,propertyaddress)+1,len(propertyaddress))



select 
parsename(replace(owneraddress,',','.') ,1)
,parsename(replace(owneraddress,',','.') ,2)
,parsename(replace(owneraddress,',','.') ,3)

from [dbo].[StateHousing]


alter table StateHousing
add 
	OwnerMainAddress varchar(255),
	OwnerCity varchar(255),
	OwnerState varchar (255)

 update StateHousing
 set 
 OwnerMainAddress = parsename(replace(owneraddress,',','.') ,3),
 OwnerCity = parsename(replace(owneraddress,',','.') ,2),
 OwnerState = parsename(replace(owneraddress,',','.') ,1)



 -- change Y and N to Yes and No 

 select distinct( SoldAsVacant), count(SoldAsVacant)
 from StateHousing
 group by SoldAsVacant


 select SoldAsVacant
 ,case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
 end

 from StateHousing


Update StateHousing
set SoldAsVacant = 
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
 end


 -- Remove Duplicates 

 with RowNumberCTE as(
 select * , 
	ROW_NUMBER() over (
	partition by parcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
                 order by UniqueID) as RowNumber
 from StateHousing
 )

 delete
 from RowNumberCTE
 where RowNumber > 1


 -- delete unused Columns 
 alter table StateHousing
 drop column owneraddress , TaxDistrict , Propertyaddress , SaleDate 

 select * from StateHousing



