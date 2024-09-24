--10 cases

--1
SELECT mc.CustomerID, [First Name] = LEFT(CustomerName, CHARINDEX(' ', CustomerName + ' ')- 1), CustomerGender, [Total Item Purchased] = SUM(ShoeSold)
FROM MsCustomer mc
JOIN TransactionHeader th ON mc.CustomerID = th.CustomerID
JOIN TransactionDetail td ON th.TransactionID = td.TransactionID
WHERE CustomerGender = 'Male'
GROUP BY mc.CustomerID, LEFT(CustomerName, CHARINDEX(' ', CustomerName + ' ')- 1), CustomerGender
HAVING SUM(ShoeSold) > 1

--2
SELECT [Shoes Id] = REPLACE(ms.ShoeID, 'SH', 'Shoes '), [Transaction Day] = DATENAME(DAY, TransactionDate), ShoeName, [Total Sold] = SUM(ShoeSold)
FROM MsShoes ms
JOIN TransactionDetail td ON ms.ShoeID = td.ShoeID
JOIN TransactionHeader th ON td.TransactionID = th.TransactionID
WHERE ShoePrice > 120000
GROUP BY REPLACE(ms.ShoeID, 'SH', 'Shoes '), DATENAME(day, TransactionDate), ShoeName
HAVING (SUM(ShoeSold) % 2) = 0

--3
SELECT [StaffNumber] = CONVERT(INT, RIGHT(ms.StaffID, 3)), [StaffName] = UPPER(StaffName), StaffSalary, [Total Purchase Made] = SUM(ShoePurchased), [Max Shoe Purchased] = MAX(ShoePurchased)
FROM MsStaff ms
JOIN PurchaseHeader ph ON ms.StaffID = ph.StaffID
JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
WHERE StaffSalary > 150000
GROUP BY CONVERT(INT, RIGHT(ms.StaffID, 3)), UPPER(StaffName), StaffSalary
HAVING SUM(ShoePurchased) > 2

--4
SELECT mv.VendorID, [Vendor Name] = CONCAT(VendorName, ' Vendor'), [Vendor Mail] = REPLACE(VendorEmail, '@gmail.com', UPPER('@mail.co.id')), [Total Shoes Sold] = SUM(ShoePurchased), [Minimum Shoes Sold] = MIN(ShoePurchased)
FROM MsVendor mv
JOIN PurchaseHeader ph ON mv.VendorID = ph.VendorID
JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
GROUP BY mv.VendorID, CONCAT(VendorName, ' Vendor'), REPLACE(VendorEmail, '@gmail.com', UPPER('@mail.co.id'))
HAVING SUM(ShoePurchased) > 13 AND
MIN(ShoePurchased) > 10

--5
SELECT mv.VendorID, [Vendor Name] = CONCAT(VendorName, ' Company'), VendorPhoneNumber, [Purchase Month] = MONTH(PurchaseDate), ShoePurchased
FROM MsVendor mv
JOIN PurchaseHeader ph ON mv.VendorID = ph.VendorID
JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID, (
SELECT AVG(ShoePurchased) AS [avgshoespurchased]
FROM PurchaseDetail
)asp 
WHERE ShoePurchased > asp.avgshoespurchased
AND MONTH(PurchaseDate) = '4'

--6
SELECT [Invoice Number] = REPLACE(th.TransactionID, 'TR', 'Invoice '), [Transaction Year] = YEAR(TransactionDate),
ShoeName, ShoePrice, [Total Item] = CONCAT(ShoeSold, ' piece(s)')
FROM TransactionHeader th 
JOIN TransactionDetail td ON th.TransactionID = td.TransactionID 
JOIN MsShoes ms ON td.ShoeID = ms.ShoeID, (
	SELECT  AVG(ShoePrice) AS 'avgshoeprice'
	FROM MsShoes
) AS alias
WHERE ShoeName LIKE '%c%'
AND ShoePrice > alias.avgshoeprice

--7
SELECT ph.PurchaseID, ms.StaffID, [Staff Name] = UPPER(StaffName), [Purchase Date] = CONVERT(VARCHAR, PurchaseDate, 103), 
[Total Expenses] = CONCAT('Rp. ', SUM(ShoePrice * ShoePurchased))
FROM MsStaff ms 
JOIN PurchaseHeader ph ON ms.StaffID = ph.StaffID
JOIN PurchaseDetail pd ON pd.PurchaseID = ph.PurchaseID
JOIN MsShoes mss ON pd.ShoeID = mss.ShoeID, (
	SELECT AVG(ShoePrice*ShoePurchased) AS [avgshoepurchased]
	FROM PurchaseDetail pd
	JOIN MsShoes ms ON pd.ShoeID = ms.ShoeID
) AS alias
WHERE CAST(SUBSTRING(ms.StaffID, 3, 3) AS INTEGER) % 2 = 1
GROUP BY  ph.PurchaseID, ms.StaffID, UPPER(StaffName), CONVERT(VARCHAR, PurchaseDate, 103), alias.avgshoepurchased
HAVING SUM(ShoePrice * ShoePurchased) > alias.avgshoepurchased 

--8
SELECT th.TransactionID, ms.StaffID, [First Name] = LEFT(StaffName, CHARINDEX(' ', StaffName + ' ')-1), 
[Last Name] = RIGHT(StaffName, CHARINDEX(' ', REVERSE(StaffName) + ' ')-1), [Total Revenue] = SUM(ShoeSold * ShoePrice) 
FROM MsStaff ms
JOIN TransactionHeader th ON ms.StaffID = th.StaffID
JOIN TransactionDetail td ON th.TransactionID = td.TransactionID
JOIN MsShoes mss ON mss.ShoeID = td.ShoeID, (
	SELECT AVG(ShoePrice) AS 'avgshoeprice'
	FROM MsShoes
) as alias
WHERE StaffGender = 'Female'
AND ShoePrice > alias.avgshoeprice
GROUP BY th.TransactionID, ms.StaffID, LEFT(StaffName, CHARINDEX(' ', StaffName + ' ')-1), RIGHT(StaffName, CHARINDEX(' ', REVERSE(StaffName) + ' ')-1)
GO

--9
CREATE VIEW [Vendor Max Transaction View]
AS
SELECT [Vendor Number] = REPLACE(mv.VendorID, 'VE', 'Vendor '), [Vendor Name] = LOWER(VendorName), 
[Total Transaction Made] = COUNT(ph.PurchaseID), [Maximum Quantity] = MAX(ShoePurchased) 
FROM MsVendor mv 
JOIN PurchaseHeader ph ON mv.VendorID = ph.VendorID
JOIN PurchaseDetail pd ON pd.PurchaseID = ph.PurchaseID
JOIN MsShoes ms ON ms.ShoeID = pd.ShoeID
WHERE VendorName LIKE '%a%'
GROUP BY REPLACE(mv.VendorID, 'VE', 'Vendor '), LOWER(VendorName)
HAVING MAX(ShoePurchased) > 20
GO

--10
CREATE VIEW [Shoes Minimum Transaction View]
AS
SELECT th.TransactionID, TransactionDate, StaffName, [Staff Email] = UPPER(StaffEmail), [Minimum Shoes Sold] = MIN(ShoeSold), 
[Total Shoes Sold] = SUM(ShoeSold)
FROM MsStaff ms
JOIN TransactionHeader th ON ms.StaffID = th.StaffID
JOIN TransactionDetail td ON th.TransactionID = td.TransactionID
JOIN MsShoes mss ON mss.ShoeID = td.ShoeID
WHERE YEAR(TransactionDate) > 2020 
AND ShoePrice > 10000
GROUP BY  th.TransactionID, TransactionDate, StaffName, UPPER(StaffEmail)