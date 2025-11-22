import mysql.connector
from mysql.connector import errorcode

DB_CONFIG = {
    'user': 'pharmacist_user',
    'password': 'pharmacistpass',
    'host': 'localhost', 
    'database': 'pharmacy',
    'raise_on_warnings': True
}


def manage_patients(cnx, cursor):
    """Handles CRUD operations for patients."""
    print("\n--- Manage Patients ---")
    print("1. Add New Patient")
    print("2. View Patient Details")
    print("3. Update Patient Information")
    print("4. Delete Patient Record")
    print("5. Back to Main Menu")
    
    try:
        choice = int(input("Enter your choice: "))
    except ValueError:
        print("Invalid input. Please enter a number.")
        return

    if choice == 1:
        try:
            pid = int(input("Enter Patient ID (PID): "))
            name = input("Enter Name: ")
            sex = input("Enter Sex (M/F): ")
            contact = input("Enter Contact Info: ")
            address = input("Enter Address: ")
            
            query = ("INSERT INTO Patient (PID, Name, Sex, Contact_info, Address)"
                     " VALUES (%s, %s, %s, %s, %s)")
            data = (pid, name, sex, contact, address)
            
            cursor.execute(query, data)
            cnx.commit()
            print("Patient added successfully.")
        except errorcode.IntegrityError as err:
            print(f"Error: {err.msg}")
            cnx.rollback()
        except Exception as err:
            print(f"An error occurred: {err}")
            cnx.rollback()

    elif choice == 2: 
        try:
            pid = int(input("Enter Patient ID (PID) to view: "))
            query = "SELECT * FROM Patient WHERE PID = %s"
            cursor.execute(query, (pid,))
            result = cursor.fetchone()
            
            if result:
                print("--- Patient Details ---")
                print(f"ID: {result[0]}")
                print(f"Name: {result[1]}")
                print(f"Sex: {result[2]}")
                print(f"Contact: {result[3]}")
                print(f"Address: {result[4]}")
                print(f"Insurance: {result[5]}")
            else:
                print("No patient found with that ID.")
        except Exception as err:
            print(f"An error occurred: {err}")
    
    elif choice == 3: 
        try:
            pid = int(input("Enter Patient ID (PID) to update: "))
            new_contact = input("Enter new Contact Info (leave blank to skip): ")
            new_address = input("Enter new Address (leave blank to skip): ")

            if not new_contact and not new_address:
                print("No changes specified.")
                return

            if new_contact:
                cursor.execute("UPDATE Patient SET Contact_info = %s WHERE PID = %s", (new_contact, pid))
            if new_address:
                cursor.execute("UPDATE Patient SET Address = %s WHERE PID = %s", (new_address, pid))

            cnx.commit()
            print("Patient information updated.")
        except Exception as err:
            print(f"An error occurred: {err}")
            cnx.rollback()

    elif choice == 4: 
        try:
            pid = int(input("Enter Patient ID (PID) to delete: "))
            cursor.execute("DELETE FROM Patient WHERE PID = %s", (pid,))
            cnx.commit()
            if cursor.rowcount > 0:
                print("Patient record deleted.")
            else:
                print("No patient found with that ID.")
        except Exception as err:
            print(f"An error occurred: {err}")
            cnx.rollback()

    elif choice == 5:
        return
    else:
        print("Invalid choice.")


def record_new_prescription(cnx, cursor):
    """Records a new prescription and demonstrates the trigger."""
    print("\n--- Record New Prescription (Demonstrates Trigger) ---")
    try:
        drug_name = input("Enter Drug Name (e.g., Paracetamol): ")
        
        
        cursor.execute("SELECT Quantity FROM Drug WHERE Drug_Name = %s", (drug_name,))
        before_qty = cursor.fetchone()
        if not before_qty:
            print(f"Error: Drug '{drug_name}' not found.")
            return
        print(f"Stock of {drug_name} BEFORE: {before_qty[0]}")

        
        pid = int(input("Enter Patient ID (PID): "))
        doc_id = int(input("Enter Doctor ID: "))
        qty = int(input("Enter Quantity prescribed: "))
        price = float(input("Enter Total Price: "))
        
        query = ("INSERT INTO Prescribed_to (PID, Doctor_id, Drug_Name, Date, Quantity, Price)"
                 " VALUES (%s, %s, %s, CURDATE(), %s, %s)")
        data = (pid, doc_id, drug_name, qty, price)
        
        cursor.execute(query, data)
        cnx.commit()
        print("Prescription recorded. Trigger will now update stock.")
        
        
        cursor.execute("SELECT Quantity FROM Drug WHERE Drug_Name = %s", (drug_name,))
        after_qty = cursor.fetchone()
        print(f"Stock of {drug_name} AFTER: {after_qty[0]}")
        print(f"Change in stock: {before_qty[0] - after_qty[0]} (should match prescribed quantity)")

    except Exception as err:
        print(f"An error occurred: {err}")
        cnx.rollback()


def view_reports(cursor):
    """Runs and displays reports from complex queries."""
    print("\n--- View Reports ---")
    print("1. Patients prescribed 'Paracetamol' (Nested Query)")
    print("2. Employee Work Details (Join Query)")
    print("3. Drug Stock Levels (Aggregate Query)")
    print("4. Find Pharmacies in a City (Stored Procedure)")
    print("5. Calculate Total Revenue by Drug (Function)")
    
    try:
        choice = int(input("Enter your choice: "))
    except ValueError:
        print("Invalid input.")
        return

    try:
        if choice == 1: 
            print("--- Patients Prescribed 'Paracetamol' ---")
            query = """
                SELECT Name, Contact_info FROM Patient
                WHERE PID IN (SELECT PID FROM Prescribed_to WHERE Drug_Name = 'Paracetamol')
            """
            cursor.execute(query)
            for (name, contact) in cursor:
                print(f"  Name: {name}, Contact: {contact}")

        elif choice == 2: 
            print("--- Employee Work Details ---")
            query = """
                SELECT e.Name, p.Name, e.Shift_start, e.Shift_end
                FROM Employees e
                JOIN Work w ON e.Employee_ID = w.Employee_ID
                JOIN Pharmacy p ON w.Pharmacy_ID = p.Pharmacy_ID
            """
            cursor.execute(query)
            for (emp_name, pharm_name, start, end) in cursor:
                print(f"  Employee: {emp_name}, Pharmacy: {pharm_name}, Shift: {start}-{end}")

        elif choice == 3: 
            print("--- Current Drug Stock Levels ---")
            query = "SELECT Drug_Name, SUM(Quantity) FROM Drug GROUP BY Drug_Name"
            cursor.execute(query)
            for (drug, total_qty) in cursor:
                print(f"  Drug: {drug}, Total Quantity: {total_qty}")

        elif choice == 4: 
            city = input("Enter city name (e.g., Bangalore): ")
            cursor.callproc('GetPharmaciesByCity', [city])
            print(f"--- Pharmacies in {city} ---")
            
            for result in cursor.stored_results():
                for (name, street, state) in result.fetchall():
                    print(f"  Name: {name}, Address: {street}, {state}")
        
        elif choice == 5: 
            drug = input("Enter drug name (e.g., Ibuprofen): ")
            cursor.execute("SELECT GetTotalRevenueByDrug(%s)", (drug,))
            revenue = cursor.fetchone()[0]
            print(f"--- Total Revenue for {drug} ---")
            print(f"  Total Revenue: {revenue}")
        
        else:
            print("Invalid choice.")
            
    except Exception as err:
        print(f"An error occurred while running the report: {err}")



def main():
    """Main function to run the CLI application."""
    cnx = None
    try:
    
        cnx = mysql.connector.connect(**DB_CONFIG)
        cursor = cnx.cursor()
        print("Connection to 'pharmacy' database established.")

        while True:
            print("\n===== Pharmacy Management System =====")
            print("1. Manage Patients (CRUD)")
            print("2. Record a New Prescription (Trigger Demo)")
            print("3. View Reports (Complex Queries)")
            print("4. Exit")
            
            try:
                choice = int(input("Enter your choice: "))
            except ValueError:
                print("Invalid input. Please enter a number.")
                continue

            if choice == 1:
                manage_patients(cnx, cursor)
            elif choice == 2:
                record_new_prescription(cnx, cursor)
            elif choice == 3:
                view_reports(cursor)
            elif choice == 4:
                print("Exiting application. Goodbye!")
                break
            else:
                print("Invalid choice. Please try again.")

    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Something is wrong with your user name or password")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("Database does not exist")
        else:
            print(err)
    finally:
        
        if cnx:
            cursor.close()
            cnx.close()
            print("MySQL connection is closed.")

if __name__ == "__main__":
    main()