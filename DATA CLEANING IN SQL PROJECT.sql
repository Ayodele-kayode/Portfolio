--Cleaning Data in SQL

*/


Select *
From  [PORTFOLIOPROJECT].[dbo].[Nashvillehousing]



----------------------------------------------------------------------------------------------------------------------

*/--Standardize Date Format
Select SaleDate, CONVERT(Date,SaleDate)
From  [PORTFOLIOPROJECT].[dbo].[Nashvillehousing]

UPDATE Nashvillehousing
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE Nashvillehousing
Add SaleDateConverted DATE;

UPDATE Nashvillehousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------

*/--Populate address data

Select PropertyAddress
From  [PORTFOLIOPROJECT].[dbo].[Nashvillehousing]

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From [PORTFOLIOPROJECT].[dbo].[Nashvillehousing] A
Join [PORTFOLIOPROJECT].[dbo].[Nashvillehousing] B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress Is NUll

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From [PORTFOLIOPROJECT].[dbo].[Nashvillehousing] A
Join [PORTFOLIOPROJECT].[dbo].[Nashvillehousing] B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress Is NUll

----------------------------------------------------------------------------------------------------------------------
*/--Breaking Address into individual columns(Address,City and State)

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS ADDRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From PORTFOLIOPROJECT.dbo.Nashvillehousing


ALTER TABLE Nashvillehousing
Add Splitaddress Varchar(255);

UPDATE Nashvillehousing
SET Splitaddress = 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE Nashvillehousing
Add SplitTown Varchar(255);

UPDATE Nashvillehousing
SET SplitTown = 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))







Select OwnerAddress
From PORTFOLIOPROJECT.dbo.Nashvillehousing

Select
PARSENAME(Replace(OwnerAddress,',','.'),3), 
PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From PORTFOLIOPROJECT.dbo.Nashvillehousing


ALTER TABLE Nashvillehousing
Add Statesplit Varchar(255);

UPDATE Nashvillehousing
SET Statesplit = PARSENAME(Replace(OwnerAddress,',','.'),3)



ALTER TABLE Nashvillehousing
Add Citysplit Varchar(255);

UPDATE Nashvillehousing
SET Citysplit = PARSENAME(Replace(OwnerAddress,',','.'),2)



ALTER TABLE Nashvillehousing
Add OwnerAddresssplit Varchar(255);

UPDATE Nashvillehousing
SET OwnerAddresssplit = PARSENAME(Replace(OwnerAddress,',','.'),1)


----------------------------------------------------------------------------------------------------------------------

*/--Changing Y and N to YES and NO respectively in the sold and vacant field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From  [PORTFOLIOPROJECT].[dbo].[Nashvillehousing]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,CASE WHEN SoldAsVacant = 'N' THEN 'NO'
WHEN SoldAsVacant = 'Y' THEN 'YES'
ELSE SoldAsVacant
END
From PORTFOLIOPROJECT.dbo.Nashvillehousing


Update Nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'NO'
WHEN SoldAsVacant = 'Y' THEN 'YES'
ELSE SoldAsVacant
END
From PORTFOLIOPROJECT.dbo.Nashvillehousing


----------------------------------------------------------------------------------------------------------------------
*/--Removing Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) Row_num
FROM PORTFOLIOPROJECT.dbo.Nashvillehousing
)

delete
FROM RowNumCTE
Where Row_num > 1

----------------------------------------------------------------------------------------------------------------------
*/--Deleting unused columns

Alter Table PORTFOLIOPROJECT.dbo.Nashvillehousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

Alter Table PORTFOLIOPROJECT.dbo.Nashvillehousing
DROP COLUMN SaleDate