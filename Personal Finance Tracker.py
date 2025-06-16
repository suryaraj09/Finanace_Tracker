import mysql.connector

class PersonalFinanceTracker:
    def __init__(self):
        self.db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="7600288140@Ss",
            database="finance_tracker"
        )
        self.cursor = self.db.cursor()

    def sign_up(self, username, password):
        query = "INSERT INTO users (username, password) VALUES (%s, %s)"
        values = (username, password)
        try:
            self.cursor.execute(query, values)
            self.db.commit()
            print("Sign up successful.")
            return True
        except mysql.connector.Error as err:
            print(f"Error: {err}")
            return False

    def sign_in(self, username, password):
        query = "SELECT * FROM users WHERE username = %s AND password = %s"
        values = (username, password)
        try:
            self.cursor.execute(query, values)
            user = self.cursor.fetchone()
            if user:
                print("Sign in successful.")
                return User(username, password, self.db, self.cursor)
            else:
                print("Invalid username or password.")
                return None
        except mysql.connector.Error as err:
            print(f"Error: {err}")
            return None

class User:
    def __init__(self, username, password, db, cursor):
        self.username = username
        self.password = password
        self.db = db
        self.cursor = cursor

    def add_expense(self, amount):
        query = "INSERT INTO expenses (username, amount) VALUES (%s, %s)"
        values = (self.username, amount)
        try:
            self.cursor.execute(query, values)
            self.db.commit()
            print("Expense added successfully.")
        except mysql.connector.Error as err:
            print(f"Error: {err}")

    def add_income(self, amount):
        query = "INSERT INTO incomes (username, amount) VALUES (%s, %s)"
        values = (self.username, amount)
        try:
            self.cursor.execute(query, values)
            self.db.commit()
            print("Income added successfully.")
        except mysql.connector.Error as err:
            print(f"Error: {err}")

    def set_budget(self, category, amount):
        query = "INSERT INTO budgets (username, category, amount) VALUES (%s, %s, %s)"
        values = (self.username, category, amount)
        try:
            self.cursor.execute(query, values)
            self.db.commit()
            print("Budget set successfully.")
        except mysql.connector.Error as err:
            print(f"Error: {err}")

    def set_goal(self, goal_name, target_amount):
        query = "INSERT INTO goals (username, goal_name, target_amount) VALUES (%s, %s, %s)"
        values = (self.username, goal_name, target_amount)
        try:
            self.cursor.execute(query, values)
            self.db.commit()
            print("Goal set successfully.")
        except mysql.connector.Error as err:
            print(f"Error: {err}")

    def add_debt(self, amount):
        query = "INSERT INTO debts (username, amount) VALUES (%s, %s)"
        values = (self.username, amount)
        try:
            self.cursor.execute(query, values)
            self.db.commit()
            print("Debt added successfully.")
        except mysql.connector.Error as err:
            print(f"Error: {err}")

    def generate_report(self):
        try:
            # Fetch expenses, incomes, budgets, goals, and debts for the user
            query_expenses = "SELECT * FROM expenses WHERE username = %s"
            self.cursor.execute(query_expenses, (self.username,))
            expenses = self.cursor.fetchall()

            query_incomes = "SELECT * FROM incomes WHERE username = %s"
            self.cursor.execute(query_incomes, (self.username,))
            incomes = self.cursor.fetchall()

            query_budgets = "SELECT * FROM budgets WHERE username = %s"
            self.cursor.execute(query_budgets, (self.username,))
            budgets = self.cursor.fetchall()

            query_goals = "SELECT * FROM goals WHERE username = %s"
            self.cursor.execute(query_goals, (self.username,))
            goals = self.cursor.fetchall()

            query_debts = "SELECT * FROM debts WHERE username = %s"
            self.cursor.execute(query_debts, (self.username,))
            debts = self.cursor.fetchall()

            # Display financial report
            print("Financial Report")
            print("----------------")
            print("Expenses:")
            for expense in expenses:
                print(f"- {expense[2]}: ${expense[3]:.2f}")

            print("\nIncomes:")
            for income in incomes:
                print(f"- {income[2]}: ${income[3]:.2f}")

            print("\nBudgets:")
            for budget in budgets:
                print(f"- {budget[2]}: ${budget[3]:.2f}")

            print("\nGoals:")
            for goal in goals:
                print(f"- {goal[2]}: ${goal[3]:.2f}")

            print("\nDebts:")
            for debt in debts:
                print(f"- {debt[2]}: ${debt[3]:.2f}")

        except mysql.connector.Error as err:
            print("Error encountered while generating the report:", err)

def main():
    finance_tracker = PersonalFinanceTracker()

    while True:
        print("\nWelcome to the Personal Finance Tracker!")
        print("1. Sign Up")
        print("2. Sign In")
        print("3. Exit")
        choice = input("Enter your choice: ")

        if choice == "1":
            username = input("Enter username: ")
            password = input("Enter password: ")
            finance_tracker.sign_up(username, password)

        elif choice == "2":
            username = input("Enter username: ")
            password = input("Enter password: ")
            user = finance_tracker.sign_in(username, password)
            if user:
                while True:
                    print("\nChoose functionality:")
                    print("1. Income Tracking")
                    print("2. Expense Tracking")
                    print("3. Budget Tracking")
                    print("4. Goal Setting")
                    print("5. Debt Management")
                    print("6. Generate Report")
                    print("7. Sign Out")
                    option = input("Enter your choice: ")

                    if option == "1":
                        amount = float(input("Enter income amount: "))
                        user.add_income(amount)

                    elif option == "2":
                        amount = float(input("Enter expense amount: "))
                        user.add_expense(amount)

                    elif option == "3":
                        category = input("Enter budget category: ")
                        amount = float(input("Enter budget amount: "))
                        user.set_budget(category, amount)

                    elif option == "4":
                        goal_name = input("Enter goal name: ")
                        target_amount = float(input("Enter target amount: "))
                        user.set_goal(goal_name, target_amount)

                    elif option == "5":
                        amount = float(input("Enter debt amount: "))
                        user.add_debt(amount)

                    elif option == "6":
                        user.generate_report()

                    elif option == "7":
                        print("Signing out...")
                        break

        elif choice == "3":
            print("Exiting...")
            break

        else:
            print("Invalid option. Please try again.")

if __name__ == "__main__":
    main()


