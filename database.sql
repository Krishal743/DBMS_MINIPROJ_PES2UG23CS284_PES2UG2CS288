-- ============================
-- Pharmacy Management System DB
-- UE23CS351A Miniproject
-- PES2UG23CS284 & PES2UG23CS288
-- ============================
CREATE DATABASE IF NOT EXISTS pharmacy;
USE pharmacy;


DROP TABLE IF EXISTS Work, Contract, Makes, Sold_by, Seen_by, Prescribed_to,
Drug, Employees, Pharmacy, Drug_Manufacturer, Doctor, Patient;



CREATE TABLE Patient (
    PID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Sex CHAR(1) CHECK (Sex IN ('M','F')),
    Contact_info VARCHAR(100) UNIQUE,
    Address VARCHAR(150) NOT NULL,
    Insurance_info VARCHAR(100) DEFAULT 'Not Provided'
);


CREATE TABLE Doctor (
    Doctor_id INT PRIMARY KEY,
    Specialty VARCHAR(100) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Contact_info VARCHAR(100) UNIQUE
);

CREATE TABLE Drug_Manufacturer (
    Company_ID INT PRIMARY KEY,
    Address VARCHAR(150) NOT NULL,
    Name VARCHAR(100) UNIQUE NOT NULL,
    Contact_info VARCHAR(100)
);


CREATE TABLE Pharmacy (
    Pharmacy_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Street VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL
);


CREATE TABLE Employees (
    Employee_ID INT PRIMARY KEY,
    Salary DECIMAL(10,2) CHECK (Salary > 0),
    Name VARCHAR(100) NOT NULL,
    Shift_start TIME NOT NULL,
    Shift_end TIME NOT NULL
);


CREATE TABLE Drug (
    Drug_Name VARCHAR(100) PRIMARY KEY,
    Quantity INT CHECK (Quantity >= 0),
    Exp_date DATE NOT NULL,
    Price DECIMAL(10,2) CHECK (Price > 0),
    Mfg_date DATE NOT NULL
);


CREATE TABLE Prescribed_to (
    PID INT,
    Doctor_id INT,
    Drug_Name VARCHAR(100),
    Date DATE NOT NULL,
    Quantity INT CHECK (Quantity > 0),
    Price DECIMAL(10,2) CHECK (Price >= 0),
    PRIMARY KEY (PID, Doctor_id, Drug_Name),
    FOREIGN KEY (PID) REFERENCES Patient(PID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Doctor_id) REFERENCES Doctor(Doctor_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Drug_Name) REFERENCES Drug(Drug_Name) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Seen_by ( Doctor_id INT, PID INT, Date DATE NOT NULL, PRIMARY KEY (Doctor_id, PID), FOREIGN KEY (Doctor_id) REFERENCES Doctor(Doctor_id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (PID) REFERENCES Patient(PID) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE Sold_by ( Drug_Name VARCHAR(100), Pharmacy_ID INT, Price DECIMAL(10,2) CHECK (Price > 0), PRIMARY KEY (Drug_Name, Pharmacy_ID), FOREIGN KEY (Drug_Name) REFERENCES Drug(Drug_Name) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (Pharmacy_ID) REFERENCES Pharmacy(Pharmacy_ID) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE Makes ( Drug_Name VARCHAR(100), Company_ID INT, PRIMARY KEY (Drug_Name, Company_ID), FOREIGN KEY (Drug_Name) REFERENCES Drug(Drug_Name) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (Company_ID) REFERENCES Drug_Manufacturer(Company_ID) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE Contract ( Company_ID INT, Pharmacy_ID INT, Start_date DATE NOT NULL, End_date DATE NOT NULL, PRIMARY KEY (Company_ID, Pharmacy_ID), FOREIGN KEY (Company_ID) REFERENCES Drug_Manufacturer(Company_ID) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (Pharmacy_ID) REFERENCES Pharmacy(Pharmacy_ID) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE Work ( Employee_ID INT, Pharmacy_ID INT, Shift_start TIME NOT NULL, Shift_end TIME NOT NULL, PRIMARY KEY (Employee_ID, Pharmacy_ID), FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (Pharmacy_ID) REFERENCES Pharmacy(Pharmacy_ID) ON DELETE CASCADE ON UPDATE CASCADE);


INSERT INTO Patient VALUES (1, 'Alice Johnson', 'F', '9876543210', '12 Park Ave', 'HealthPlus'),(2, 'Bob Smith', 'M', '8765432109', '45 Oak St', 'MediCare'),(3, 'Charlie Brown', 'M', '7654321098', '78 Pine Rd', 'LifeSecure'),(4, 'Diana Prince', 'F', '6543210987', '90 Maple Ln', 'HealthFirst'),(5, 'Evan Davis', 'M', '5432109876', '101 Birch Blvd', DEFAULT);
INSERT INTO Doctor VALUES (101, 'Cardiologist', 'Dr. Raj Mehta', 'rajmehta@hospital.com'),(102, 'Dermatologist', 'Dr. Anu Rao', 'anurao@hospital.com'),(103, 'Pediatrician', 'Dr. Sunil Gupta', 'sunilg@hospital.com'),(104, 'Orthopedic', 'Dr. Kavya Nair', 'kavyan@hospital.com'),(105, 'General Physician', 'Dr. Arjun Menon', 'arjunm@hospital.com');
INSERT INTO Drug_Manufacturer VALUES (201, 'Mumbai, India', 'Cipla Ltd', 'contact@cipla.com'),(202, 'Bangalore, India', 'Sun Pharma', 'contact@sunpharma.com'),(203, 'Delhi, India', 'Dr. Reddys Labs', 'contact@drreddys.com'),(204, 'Hyderabad, India', 'Aurobindo Pharma', 'info@aurobindopharma.com'),(205, 'Chennai, India', 'Biocon Ltd', 'info@biocon.com');
INSERT INTO Pharmacy VALUES (301, 'MediStore', '12 MG Road', 'Bangalore', 'Karnataka'),(302, 'HealthPlus Pharmacy', '56 FC Road', 'Pune', 'Maharashtra'),(303, 'Wellness Chemists', '89 Park St', 'Kolkata', 'West Bengal'),(304, 'Care Pharmacy', '23 Anna Salai', 'Chennai', 'Tamil Nadu'),(305, 'LifeCare Pharmacy', '45 Brigade Rd', 'Bangalore', 'Karnataka');
INSERT INTO Employees VALUES (401, 35000, 'Ravi Kumar', '09:00:00', '17:00:00'),(402, 28000, 'Priya Sharma', '10:00:00', '18:00:00'),(403, 30000, 'Amit Patel', '08:00:00', '16:00:00'),(404, 32000, 'Neha Verma', '12:00:00', '20:00:00'),(405, 25000, 'Kiran Rao', '14:00:00', '22:00:00');
INSERT INTO Drug VALUES ('Paracetamol', 200, '2026-12-31', 15.00, '2023-01-10'),('Amoxicillin', 150, '2025-08-15', 50.00, '2023-02-20'),('Metformin', 100, '2027-01-01', 100.00, '2023-03-12'),('Ibuprofen', 180, '2026-06-30', 30.00, '2023-04-05'),('Cetirizine', 120, '2025-09-20', 20.00, '2023-05-25');
INSERT INTO Prescribed_to VALUES (1, 101, 'Paracetamol', '2025-10-17', 10, 150.00),(2, 102, 'Amoxicillin', '2025-02-12', 5, 250.00),(3, 103, 'Metformin', '2025-03-15', 2, 200.00),(4, 104, 'Ibuprofen', '2025-04-18', 15, 450.00),(5, 105, 'Cetirizine', '2025-05-20', 8, 160.00);
INSERT INTO Seen_by VALUES (101, 1, '2025-01-10'),(102, 2, '2025-02-12'),(103, 3, '2025-03-15'),(104, 4, '2025-04-18'),(105, 5, '2025-05-20');
INSERT INTO Sold_by VALUES ('Paracetamol', 301, 15.00),('Amoxicillin', 302, 50.00),('Metformin', 303, 100.00),('Ibuprofen', 304, 30.00),('Cetirizine', 305, 20.00);
INSERT INTO Makes VALUES ('Paracetamol', 201),('Amoxicillin', 202),('Metformin', 203),('Ibuprofen', 204),('Cetirizine', 205);
INSERT INTO Contract VALUES (201, 301, '2024-01-01', '2025-12-31'),(202, 302, '2024-02-01', '2025-11-30'),(203, 303, '2024-03-01', '2026-01-31'),(204, 304, '2024-04-01', '2025-10-31'),(205, 305, '2024-05-01', '2026-03-31');
INSERT INTO Work VALUES (401, 301, '09:00:00', '17:00:00'),(402, 302, '10:00:00', '18:00:00'),(403, 303, '08:00:00', '16:00:00'),(404, 304, '12:00:00', '20:00:00'),(405, 305, '14:00:00', '22:00:00');

CREATE USER IF NOT EXISTS 'admin_user'@'localhost' IDENTIFIED BY 'adminpass';
CREATE USER IF NOT EXISTS 'pharmacist_user'@'localhost' IDENTIFIED BY 'pharmacistpass';


GRANT ALL PRIVILEGES ON pharmacy.* TO 'admin_user'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE ON pharmacy.Patient TO 'pharmacist_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON pharmacy.Drug TO 'pharmacist_user'@'localhost';
GRANT SELECT, INSERT ON pharmacy.Prescribed_to TO 'pharmacist_user'@'localhost';
GRANT SELECT ON pharmacy.Doctor TO 'pharmacist_user'@'localhost';
FLUSH PRIVILEGES;

DELIMITER $$
CREATE TRIGGER UpdateDrugQuantity
AFTER INSERT ON Prescribed_to
FOR EACH ROW
BEGIN
    UPDATE Drug
    SET Quantity = Quantity - NEW.Quantity
    WHERE Drug_Name = NEW.Drug_Name;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetPharmaciesByCity(IN city_name VARCHAR(50))
BEGIN
    SELECT Name, Street, State
    FROM Pharmacy
    WHERE City = city_name;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION GetTotalRevenueByDrug(drug_name_param VARCHAR(100))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE total_revenue DECIMAL(12,2);
    SELECT SUM(Price)
    INTO total_revenue
    FROM Prescribed_to
    WHERE Drug_Name = drug_name_param;
    RETURN total_revenue;
END$$
DELIMITER ;


NESTED QUERY: Find patients who were prescribed 'Paracetamol'.
SELECT Name, Contact_info FROM Patient
WHERE PID IN (SELECT PID FROM Prescribed_to WHERE Drug_Name = 'Paracetamol');

JOIN QUERY: List all employees and the name of the pharmacy they work at.
SELECT e.Name AS EmployeeName, p.Name AS PharmacyName, e.Shift_start, e.Shift_end
FROM Employees e
JOIN Work w ON e.Employee_ID = w.Employee_ID
JOIN Pharmacy p ON w.Pharmacy_ID = p.Pharmacy_ID;

AGGREGATE QUERY: Get the total quantity of each drug available.
SELECT Drug_Name, SUM(Quantity) AS TotalQuantity
FROM Drug
GROUP BY Drug_Name
ORDER BY TotalQuantity DESC;

