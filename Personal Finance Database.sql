create database finance_tracker;
USE finance_tracker;

create table users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    total_expenses DECIMAL(10, 2) DEFAULT 0.00,
    total_incomes DECIMAL(10, 2) DEFAULT 0.00,
    total_budgets DECIMAL(10, 2) DEFAULT 0.00,
    total_goals DECIMAL(10, 2) DEFAULT 0.00,
    total_debts DECIMAL(10, 2) DEFAULT 0.00,
    index (username)
); 

create table expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES users(username)
);

create table incomes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES users(username)
);

create table budgets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES users(username)
);

create table goals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    goal_name VARCHAR(255) NOT NULL,
    target_amount DECIMAL(10, 2) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES users(username)
);

create table debts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES users(username)
);

-- Procedure to add an expense
DELIMITER $$
CREATE PROCEDURE add_expense(IN username VARCHAR(255), IN amount DECIMAL(10, 2))
BEGIN
    INSERT INTO expenses (username, amount) VALUES (username, amount);
END$$
DELIMITER ;

-- Procedure to add an income
DELIMITER $$
CREATE PROCEDURE add_income(IN username VARCHAR(255), IN amount DECIMAL(10, 2))
BEGIN
    INSERT INTO incomes (username, amount) VALUES (username, amount);
END$$
DELIMITER ;

-- Procedure to set a budget
DELIMITER $$
CREATE PROCEDURE set_budget(IN username VARCHAR(255), IN category VARCHAR(255), IN amount DECIMAL(10, 2))
BEGIN
    INSERT INTO budgets (username, category, amount) VALUES (username, category, amount);
END$$
DELIMITER ;

-- Procedure to set a financial goal
DELIMITER $$
CREATE PROCEDURE set_goal(IN username VARCHAR(255), IN goal_name VARCHAR(255), IN target_amount DECIMAL(10, 2))
BEGIN
    INSERT INTO goals (username, goal_name, target_amount) VALUES (username, goal_name, target_amount);
END$$
DELIMITER ;

-- Procedure to add a debt
DELIMITER $$
CREATE PROCEDURE add_debt(IN username VARCHAR(255), IN amount DECIMAL(10, 2))
BEGIN
    INSERT INTO debts (username, amount) VALUES (username, amount);
END$$
DELIMITER ;

-- Procedure to generate a user report
DELIMITER $$
CREATE PROCEDURE generate_user_report(IN username VARCHAR(255))
BEGIN
    SELECT * FROM expenses WHERE username = username;
    SELECT * FROM incomes WHERE username = username;
    SELECT * FROM budgets WHERE username = username;
    SELECT * FROM goals WHERE username = username;
    SELECT * FROM debts WHERE username = username;
END$$
DELIMITER ;

-- Trigger to update user's total incomes when a new income is added
DELIMITER $$
CREATE TRIGGER update_total_incomes AFTER INSERT ON incomes
FOR EACH ROW
BEGIN
    UPDATE users SET total_incomes = total_incomes + NEW.amount WHERE username = NEW.username;
END$$
DELIMITER ;

-- Trigger to update user's total expenses when a new expense is added
DELIMITER $$
CREATE TRIGGER update_total_expenses 
AFTER INSERT ON expenses
FOR EACH ROW
BEGIN
    DECLARE user_income DECIMAL(10, 2);

    -- Get the user's total income
    SELECT total_incomes INTO user_income 
    FROM users 
    WHERE username = NEW.username;

    -- Check if the new expense exceeds the user's total income
    IF NEW.amount > user_income THEN
        -- Raise an error if the expense exceeds income
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Expense cannot exceed income';
    ELSE
        -- Update user's total expenses if the expense is within the income
        UPDATE users 
        SET total_expenses = total_expenses + NEW.amount 
        WHERE username = NEW.username;
    END IF;
END$$
DELIMITER ;

-- Trigger to update user's total budgets when a new budget is set
DELIMITER $$
CREATE TRIGGER update_total_budgets 
AFTER INSERT ON budgets
FOR EACH ROW
BEGIN
    DECLARE user_income DECIMAL(10, 2);

    -- Get the user's total income
    SELECT total_incomes INTO user_income 
    FROM users 
    WHERE username = NEW.username;

    -- Update user's total budgets if the budget is within the income
    UPDATE users 
    SET total_budgets = total_budgets + NEW.amount 
    WHERE username = NEW.username
    AND NEW.amount <= user_income;
END$$
DELIMITER ;

-- Trigger to update user's total goals when a new goal is set
DELIMITER $$
CREATE TRIGGER update_total_goals AFTER INSERT ON goals
FOR EACH ROW
BEGIN
    UPDATE users SET total_goals = total_goals + NEW.target_amount WHERE username = NEW.username;
END$$
DELIMITER ;

-- Trigger to update user's total debts when a new debt is added
DELIMITER $$
CREATE TRIGGER update_total_debts AFTER INSERT ON debts
FOR EACH ROW
BEGIN
    UPDATE users SET total_debts = total_debts + NEW.amount WHERE username = NEW.username;
END$$
DELIMITER ;
