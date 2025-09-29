-- Insert sample customers
INSERT INTO customers VALUES (1001, 'John Doe', 'Kigali', 'john.doe@email.com', DATE '2024-01-01');
INSERT INTO customers VALUES (1002, 'Alice Smith', 'Northern', 'alice.smith@email.com', DATE '2024-01-15');

-- Insert sample products
INSERT INTO products VALUES (2001, 'Grilled Chicken', 'Main Course', 8500, 'Y');
INSERT INTO products VALUES (2002, 'Beef Burger', 'Main Course', 6500, 'Y');

-- Insert sample transactions
INSERT INTO transactions VALUES (3001, 1001, 2001, DATE '2024-01-15', 8500, 1);
INSERT INTO transactions VALUES (3002, 1001, 2002, DATE '2024-01-20', 6500, 1);
