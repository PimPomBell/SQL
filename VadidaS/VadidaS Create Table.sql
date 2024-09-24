CREATE DATABASE VadidaS
GO

USE VadidaS
GO

CREATE TABLE MsStaff (
	StaffID CHAR(5) PRIMARY KEY NOT NULL
	CONSTRAINT CheckStaffID 
	CHECK (StaffID LIKE 'ST[0-9][0-9][0-9]'), 
	StaffName VARCHAR(50) NOT NULL
	CONSTRAINT CheckStaffName
	CHECK(LEN(StaffName) > 10), 
	StaffGender VARCHAR(50) NOT NULL
	CONSTRAINT CheckStaffGender
	CHECK(StaffGender IN ('Male', 'Female')), 
	StaffEmail VARCHAR(50) NOT NULL
	CONSTRAINT CheckStaffEmail
	CHECK(StaffEmail LIKE '%@gmail.com'), 
	StaffAddress VARCHAR(150) NOT NULL,
	StaffSalary INT NOT NULL
	CONSTRAINT CheckStaffSalary 
	CHECK (StaffSalary BETWEEN 120000 AND 500000)
)

CREATE TABLE MsVendor (
	VendorID CHAR(5) PRIMARY KEY NOT NULL
	CONSTRAINT CheckVendorID
	CHECK (VendorID LIKE 'VE[0-9][0-9][0-9]'),
	VendorName VARCHAR(50) NOT NULL,
	VendorAddress VARCHAR(50) NOT NULL,
	VendorEmail VARCHAR(50) NOT NULL
	CONSTRAINT CheckVendorEmail
	CHECK(VendorEmail LIKE '%@gmail.com'), 
	VendorPhoneNumber VARCHAR(20) NOT NULL
)

CREATE TABLE MsShoes (
	ShoeID CHAR(5) PRIMARY KEY NOT NULL
	CONSTRAINT CheckShoeID
	CHECK (ShoeID LIKE 'SH[0-9][0-9][0-9]'),
	ShoeName VARCHAR(50) NOT NULL, 
	ShoePrice INT NOT NULL,
	[Description] VARCHAR(50) NOT NULL
)

CREATE TABLE MsCustomer (
	CustomerID CHAR(5) PRIMARY KEY NOT NULL
	CONSTRAINT CheckCustomerID 
	CHECK (CustomerID LIKE 'CU[0-9][0-9][0-9]'),
	CustomerName VARCHAR(50) NOT NULL
	CONSTRAINT CheckCustomerName
	CHECK(LEN(CustomerName) > 10), 
	CustomerGender VARCHAR (50) NOT NULL
	CONSTRAINT CheckCustomerGender
	CHECK(CustomerGender IN ('Male', 'Female')), 
	CustomerDOB VARCHAR(50) NOT NULL
	CONSTRAINT CheckCustomerAge
	CHECK (DATEDIFF(yy, CustomerDOB, GETDATE()) >= 17), 
	CustomerAddress VARCHAR(50) NOT NULL,
	CustomerEmail VARCHAR(50) NOT NULL
	CONSTRAINT CheckCustomerEmail
	CHECK(CustomerEmail LIKE '%@gmail.com')
)

CREATE TABLE TransactionHeader (
	TransactionID CHAR(5) PRIMARY KEY NOT NULL
	CONSTRAINT CheckTransactionID
	CHECK (TransactionID LIKE 'TR[0-9][0-9][0-9]'),
	StaffID CHAR(5) FOREIGN KEY REFERENCES MsStaff(StaffID)
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL, 
	CustomerID CHAR(5) FOREIGN KEY REFERENCES MsCustomer(CustomerID)
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	TransactionDate DATE
)

CREATE TABLE TransactionDetail (
	TransactionID CHAR(5) FOREIGN KEY REFERENCES TransactionHeader(TransactionID)
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	ShoeID CHAR(5) FOREIGN KEY REFERENCES MsShoes(ShoeID)
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	ShoeSold INT
)

CREATE TABLE PurchaseHeader (
	PurchaseID CHAR(5) PRIMARY KEY NOT NULL
	CONSTRAINT CheckPurchaseID
	CHECK (PurchaseID LIKE 'PU[0-9][0-9][0-9]'),
	StaffID CHAR(5) FOREIGN KEY REFERENCES MsStaff(StaffID)
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL, 
	VendorID CHAR(5) FOREIGN KEY REFERENCES MsVendor(VendorID)
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	PurchaseDate DATE
)

CREATE TABLE PurchaseDetail ( 
	PurchaseID CHAR(5) FOREIGN KEY REFERENCES PurchaseHeader(PurchaseID) 
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	ShoeID CHAR (5) FOREIGN KEY REFERENCES MsShoes(ShoeID)
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	ShoePurchased INT NOT NULL
)
