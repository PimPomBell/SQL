-- 10 cases

-- 1 Display CustomerID, First Name (obtained from the first word of CustomerName), 
--   CustomerGender, and Total Item Purchased (obtained from the total of Quantity) 
--   for each CustomerGender equals to Male and Total Item Purchased is greater than 1.

SELECT mc.CustomerID, [First Name] = LEFT(CustomerName, CHARINDEX(' ', CustomerName + ' ')- 1), CustomerGender, [Total Item Purchased] = SUM(ShoeSold)
FROM MsCustomer mc
JOIN TransactionHeader th ON mc.CustomerID = th.CustomerID
JOIN TransactionDetail td ON th.TransactionID = td.TransactionID
WHERE CustomerGender = 'Male'
GROUP BY mc.CustomerID, LEFT(CustomerName, CHARINDEX(' ', CustomerName + ' ')- 1), CustomerGender
HAVING SUM(ShoeSold) > 1



-- 2 Display Shoes Id (obtained by replacing 'SH' with 'Shoes ' from ShoesID), StaffID, 
--   Transaction Day (obtained from the day of SalesDate) ShoesName, and Total Sold (obtained from the total of Quantity) 
--   for each ShoesPrice greater than 120000 and Total Sold must be even number

SELECT [Shoes Id] = REPLACE(ms.ShoeID, 'SH', 'Shoes '), [Transaction Day] = DATENAME(DAY, TransactionDate), ShoeName, [Total Sold] = SUM(ShoeSold)
FROM MsShoes ms
JOIN TransactionDetail td ON ms.ShoeID = td.ShoeID
JOIN TransactionHeader th ON td.TransactionID = th.TransactionID
WHERE ShoePrice > 120000
GROUP BY REPLACE(ms.ShoeID, 'SH', 'Shoes '), DATENAME(day, TransactionDate), ShoeName
HAVING (SUM(ShoeSold) % 2) = 0



-- 3 Display Staff Number (obtained from displaying StaffID as integer), 
--   Staff Name (obtained from StaffName in uppercase format), StaffSalary,
--   Total Purchase Made (obtained from total purchase made by vendor), and Max Shoes Purchased (obtained from maximum of Quantity)
--   for each StaffSalary greater than 150000 and Total Purchase Made greater than 2.

SELECT [StaffNumber] = CONVERT(INT, RIGHT(ms.StaffID, 3)), [StaffName] = UPPER(StaffName), StaffSalary, [Total Purchase Made] = SUM(ShoePurchased), [Max Shoe Purchased] = MAX(ShoePurchased)
FROM MsStaff ms
JOIN PurchaseHeader ph ON ms.StaffID = ph.StaffID
JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
WHERE StaffSalary > 150000
GROUP BY CONVERT(INT, RIGHT(ms.StaffID, 3)), UPPER(StaffName), StaffSalary
HAVING SUM(ShoePurchased) > 2



-- 4 Display VendorID, Vendor Name (obtained from VendorName ends with ' Vendor'), Vendor Mail
--   (obtained by replacing ‘@gmail.com’ with ‘@mail.co.id’ from VendorEmail in uppercase format), Total Shoes Sold (obtained from total of Quantity), 
--   and Minimum Shoes Sold (obtained from minimum of Quantity) for each Total Shoes Sold greater than 13 and Minimum Shoes Sold greater than 10.

SELECT mv.VendorID, [Vendor Name] = CONCAT(VendorName, ' Vendor'), [Vendor Mail] = REPLACE(VendorEmail, '@gmail.com', UPPER('@mail.co.id')), [Total Shoes Sold] = SUM(ShoePurchased), [Minimum Shoes Sold] = MIN(ShoePurchased)
FROM MsVendor mv
JOIN PurchaseHeader ph ON mv.VendorID = ph.VendorID
JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
GROUP BY mv.VendorID, CONCAT(VendorName, ' Vendor'), REPLACE(VendorEmail, '@gmail.com', UPPER('@mail.co.id'))
HAVING SUM(ShoePurchased) > 13 AND
MIN(ShoePurchased) > 10



-- 5 Display VendorID, Vendor Name (obtained from VendorName ends with ' Company'), VendorPhone, 
--   Purchase Month (obtained from the name of the month of PurchaseDate), and Quantity for each 
--   transaction that occurs in April and Quantity is greater than the average of all purchasing quantity. 
--   (ALIAS SUBQUERY)

SELECT mv.VendorID, [Vendor Name] = CONCAT(VendorName, ' Company'), VendorPhoneNumber, [Purchase Month] = MONTH(PurchaseDate), ShoePurchased
FROM MsVendor mv
JOIN PurchaseHeader ph ON mv.VendorID = ph.VendorID
JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID, (
SELECT AVG(ShoePurchased) AS [avgshoespurchased]
FROM PurchaseDetail
)asp 
WHERE ShoePurchased > asp.avgshoespurchased
AND MONTH(PurchaseDate) = '4'



-- 6 Display Invoice Number (obtained from replacing 'SA' with 'Invoice 'from SalesID),  
--   Sales Year (obtained from the year of the SalesDate) ShoesName, ShoesPrice, Total Item (obtained from Quantity ends with ' piece(s)') 
--   for each ShoesName that contains 'c' and ShoesPrice is greater than average of all ShoesPrice.
--   (ALIAS SUBQUERY)

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



-- 7 Display PurchaseID, StaffID, Staff Name (obtained from StaffName in uppercase format), 
--   Purchase Date (obtained from PurchaseDate in 'dd/mm/yyyy' format), and Total Expenses 
--   (obtained from calculating the total of multiplication between ShoesPrice and Quantity and starts with 'Rp. ') 
--   for each Total Expenses greater than the average of multiplication between ShoesPrice and Quantity and last three digit of StaffID must be an odd number.
--   (ALIAS SUBQUERY)

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



-- 8 Display SalesID, StaffID, First Name (obtained from the first word of StaffName), Last Name (obtained from the last word of StaffName), 
--   and Total Revenue (obtained from the total of multiplication between Quantity and ShoesPrice) 
--   for each StaffGender that equals 'Female' and ShoesPrice is greater than the average of all shoes price.
-- (ALIAS SUBQUERY)

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



-- 9 Create a view named 'Vendor Max Transaction View' to display Vendor Number (obtained by replacing 'VE' with 'Vendor ' from VendorID), 
--   Vendor Name (obtained from VendorName in lower case format), Total Transaction Made (obtained from the total transaction made), 
--   Maximum Quantity (obtained from maximum of Quantity) for each VendorName that contains 'a' and Maximum Quantity greater than 20.

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



-- 10 Create view named 'Shoes Minimum Transaction View' to display SalesID, SalesDate, StaffName, Staff Email (obtained from StaffEmail in uppercase format), 
--    Minimum Shoes Sold (obtained from minimum of Quantity), and Total Shoes Sold (obtained from total of Quantity) for SalesDate that occurs after 2020 and 
--    ShoesPrice greater than 10000.

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