SET SERVEROUTPUT ON;

-- 1) Annual Salary
DECLARE
    v_basic_salary  NUMBER := 30000;
    v_bonus         NUMBER := 5000;
    v_annual_salary NUMBER;
BEGIN
    v_annual_salary := v_basic_salary + v_bonus;
    DBMS_OUTPUT.PUT_LINE('Annual Salary = ' || v_annual_salary);
END;
/
------------------------------------------------------------

-- 2) Average of 3 subject marks
DECLARE
    v_sub1 NUMBER := 80;
    v_sub2 NUMBER := 75;
    v_sub3 NUMBER := 90;
    v_avg  NUMBER;
BEGIN
    v_avg := (v_sub1 + v_sub2 + v_sub3) / 3;
    DBMS_OUTPUT.PUT_LINE('Average Marks = ' || v_avg);
END;
/



-- 3) Bank balance check
DECLARE
    v_balance NUMBER := 4500;
BEGIN
    IF v_balance < 1000 THEN
        DBMS_OUTPUT.PUT_LINE('Low Balance');
    ELSIF v_balance BETWEEN 1000 AND 5000 THEN
        DBMS_OUTPUT.PUT_LINE('Sufficient Balance');
    ELSE
        DBMS_OUTPUT.PUT_LINE('High Balance');
    END IF;
END;
/
------------------------------------------------------------

-- 4) Grading system using CASE
DECLARE
    v_percentage NUMBER := 82;
    v_grade VARCHAR2(20);
BEGIN
    v_grade := CASE
        WHEN v_percentage BETWEEN 90 AND 100 THEN 'A Grade'
        WHEN v_percentage BETWEEN 75 AND 89 THEN 'B Grade'
        WHEN v_percentage BETWEEN 50 AND 74 THEN 'C Grade'
        ELSE 'Fail'
    END;

    DBMS_OUTPUT.PUT_LINE('Grade: ' || v_grade);
END;
/
------------------------------------------------------------

-- 5) Shopping discount
DECLARE
    v_bill NUMBER := 5200;
    v_discount NUMBER := 0;
    v_final NUMBER;
BEGIN
    IF v_bill > 5000 THEN
        v_discount := v_bill * 0.20;
    ELSIF v_bill BETWEEN 2000 AND 5000 THEN
        v_discount := v_bill * 0.10;
    END IF;

    v_final := v_bill - v_discount;

    DBMS_OUTPUT.PUT_LINE('Final Bill = ' || v_final);
END;
/


-- 6) Multiplication table
DECLARE
    v_num NUMBER := 7;
    i NUMBER := 1;
BEGIN
    WHILE i <= 10 LOOP
        DBMS_OUTPUT.PUT_LINE(v_num || ' x ' || i || ' = ' || (v_num * i));
        i := i + 1;
    END LOOP;
END;
/
------------------------------------------------------------

-- 7) Employee IDs 100 to 120
BEGIN
    FOR v_id IN 100..120 LOOP
        DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_id);
    END LOOP;
END;
/
------------------------------------------------------------

-- 8) Factorial using WHILE loop
DECLARE
    v_n NUMBER := 5;
    v_fact NUMBER := 1;
    i NUMBER := 1;
BEGIN
    WHILE i <= v_n LOOP
        v_fact := v_fact * i;
        i := i + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Factorial = ' || v_fact);
END;
/
------------------------------------------------------------

-- 9) Countdown 10 to 1
BEGIN
    FOR i IN REVERSE 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;
/


-- 10) Print IT department employees
BEGIN
    FOR rec IN (
        SELECT emp_name FROM employees WHERE dept_id = 10
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('IT Employee: ' || rec.emp_name);
    END LOOP;
END;
/
------------------------------------------------------------

-- 11) Give 10% salary increase to employees with salary < 3000
DECLARE
    CURSOR c_emp IS
        SELECT emp_id, salary FROM employees WHERE salary < 3000;
BEGIN
    FOR rec IN c_emp LOOP
        UPDATE employees
        SET salary = rec.salary * 1.10
        WHERE emp_id = rec.emp_id;

        DBMS_OUTPUT.PUT_LINE(
            'Updated ' || rec.emp_id || ' -> ' || (rec.salary * 1.10)
        );
    END LOOP;

    COMMIT;
END;
/
------------------------------------------------------------

-- 12) Employees above average salary
DECLARE
    v_avg NUMBER;
BEGIN
    SELECT AVG(salary) INTO v_avg FROM employees;

    DBMS_OUTPUT.PUT_LINE('Average Salary = ' || v_avg);

    FOR rec IN (
        SELECT emp_id, emp_name, salary
        FROM employees
        WHERE salary > v_avg
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' -> ' || rec.salary);
    END LOOP;
END;
/
------------------------------------------------------------

-- 13) High / Mid / Low earner
BEGIN
    FOR rec IN (SELECT emp_name, salary FROM employees) LOOP
        IF rec.salary > 8000 THEN
            DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' = High Earner');
        ELSIF rec.salary BETWEEN 4000 AND 8000 THEN
            DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' = Mid Earner');
        ELSE
            DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' = Low Earner');
        END IF;
    END LOOP;
END;
/
------------------------------------------------------------

-- 14) Total salary cost by department
BEGIN
    FOR rec IN (
        SELECT dept_id, SUM(salary) AS total_salary
        FROM employees
        GROUP BY dept_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Dept ' || rec.dept_id || ' -> ' || rec.total_salary
        );
    END LOOP;
END;
/
------------------------------------------------------------

-- 15) Fibonacci sequence
DECLARE
    n NUMBER := 10;
    a NUMBER := 0;
    b NUMBER := 1;
    c NUMBER;
    i NUMBER := 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Fibonacci Series:');

    WHILE i <= n LOOP
        IF i = 1 THEN
            DBMS_OUTPUT.PUT_LINE(a);
        ELSIF i = 2 THEN
            DBMS_OUTPUT.PUT_LINE(b);
        ELSE
            c := a + b;
            DBMS_OUTPUT.PUT_LINE(c);
            a := b;
            b := c;
        END IF;

        i := i + 1;
    END LOOP;
END;
/
------------------------------------------------------------

-- 16) Bank transactions processing
DECLARE
    v_balance NUMBER := 0;
BEGIN
    FOR rec IN (
        SELECT txn_id, amount, type FROM transactions WHERE ROWNUM <= 100
    ) LOOP
        IF rec.type = 'CREDIT' THEN
            v_balance := v_balance + rec.amount;
        ELSIF rec.type = 'DEBIT' THEN
            v_balance := v_balance - rec.amount;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Final Balance = ' || v_balance);
END;
/
------------------------------------------------------------

-- 17) Procedure to print employee details
CREATE OR REPLACE PROCEDURE show_employee_details (
    p_emp_id IN NUMBER
) AS
    v_name employees.emp_name%TYPE;
    v_dept departments.dept_name%TYPE;
    v_sal  employees.salary%TYPE;
BEGIN
    SELECT e.emp_name, d.dept_name, e.salary
    INTO v_name, v_dept, v_sal
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    WHERE e.emp_id = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_dept);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_sal);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found.');
END;
/
------------------------------------------------------------

-- Run the procedure example
BEGIN
    show_employee_details(101);
END;
/
------------------------------------------------------------


-- Second excersize  Cursor
-------------------------------------------------
-- Exercise 1: High Salary Report
-------------------------------------------------
DECLARE
    CURSOR c_emp IS
        SELECT e.emp_name,
               e.salary,
               d.dept_name
        FROM employees e
        JOIN departments d ON e.dept_id = d.dept_id
        WHERE e.salary > (
            SELECT AVG(e2.salary)
            FROM employees e2
            WHERE e2.dept_id = e.dept_id
        );
    v_name      employees.emp_name%TYPE;
    v_salary    employees.salary%TYPE;
    v_dept_name departments.dept_name%TYPE;
BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp INTO v_name, v_salary, v_dept_name;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || v_salary || ' - ' || v_dept_name);
    END LOOP;
    CLOSE c_emp;
END;
/
-------------------------------------------------
-- Exercise 2: Salary Increment by Department (IT)
-------------------------------------------------
DECLARE
    CURSOR c_it IS
        SELECT emp_id, emp_name, salary
        FROM employees
        WHERE dept_id = (
            SELECT dept_id FROM departments WHERE UPPER(dept_name) = 'IT'
        );
    v_id     employees.emp_id%TYPE;
    v_name   employees.emp_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    OPEN c_it;
    LOOP
        FETCH c_it INTO v_id, v_name, v_salary;
        EXIT WHEN c_it%NOTFOUND;

        UPDATE employees
        SET salary = v_salary * 1.10
        WHERE emp_id = v_id;

        DBMS_OUTPUT.PUT_LINE(v_name || ' new salary: ' || (v_salary * 1.10));
    END LOOP;
    CLOSE c_it;
    COMMIT;
END;
/
-------------------------------------------------
-- Exercise 3: Customer Orders Summary (last 30 days)
-------------------------------------------------
DECLARE
    CURSOR c_cust IS
        SELECT c.customer_id,
               c.customer_name,
               COUNT(o.order_id) AS total_orders,
               SUM(o.total_amount) AS total_amount
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.order_date >= TRUNC(SYSDATE) - 30
        GROUP BY c.customer_id, c.customer_name;
    v_id          customers.customer_id%TYPE;
    v_name        customers.customer_name%TYPE;
    v_total_ord   NUMBER;
    v_total_amt   NUMBER;
BEGIN
    OPEN c_cust;
    LOOP
        FETCH c_cust INTO v_id, v_name, v_total_ord, v_total_amt;
        EXIT WHEN c_cust%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' -> Orders: ' || v_total_ord ||
                             ', Amount: ' || v_total_amt);
    END LOOP;
    CLOSE c_cust;
END;
/
-------------------------------------------------
-- Exercise 4: Pending Payments Reminder (overdue > 60 days)
-------------------------------------------------
DECLARE
    CURSOR c_inv IS
        SELECT i.invoice_id,
               i.customer_id,
               i.due_date,
               i.pending_amount,
               c.customer_name
        FROM invoices i
        JOIN customers c ON i.customer_id = c.customer_id
        WHERE i.status = 'PENDING'
          AND i.due_date < TRUNC(SYSDATE) - 60;
    v_invoice_id    invoices.invoice_id%TYPE;
    v_cust_id       invoices.customer_id%TYPE;
    v_due_date      invoices.due_date%TYPE;
    v_pending       invoices.pending_amount%TYPE;
    v_cust_name     customers.customer_name%TYPE;
BEGIN
    OPEN c_inv;
    LOOP
        FETCH c_inv INTO v_invoice_id, v_cust_id, v_due_date, v_pending, v_cust_name;
        EXIT WHEN c_inv%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_cust_name || ' - Invoice: ' || v_invoice_id ||
                             ', Due: ' || TO_CHAR(v_due_date,'YYYY-MM-DD') ||
                             ', Pending: ' || v_pending);
    END LOOP;
    CLOSE c_inv;
END;
/
-------------------------------------------------
-- Exercise 5: Top 3 Employees per Department
-------------------------------------------------
DECLARE
    CURSOR c_top IS
        SELECT dept_name, emp_name, salary
        FROM (
            SELECT d.dept_name,
                   e.emp_name,
                   e.salary,
                   ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS rn
            FROM employees e
            JOIN departments d ON e.dept_id = d.dept_id
        )
        WHERE rn <= 3
        ORDER BY dept_name, salary DESC;
    v_dept  departments.dept_name%TYPE;
    v_name  employees.emp_name%TYPE;
    v_sal   employees.salary%TYPE;
BEGIN
    OPEN c_top;
    LOOP
        FETCH c_top INTO v_dept, v_name, v_sal;
        EXIT WHEN c_top%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_dept || ' - ' || v_name || ' - ' || v_sal);
    END LOOP;
    CLOSE c_top;
END;
/
-------------------------------------------------
-- Exercise 6: Low Stock Alert
-------------------------------------------------
DECLARE
    CURSOR c_prod IS
        SELECT product_name, category, stock_qty
        FROM products
        WHERE stock_qty < 10;
    v_name   products.product_name%TYPE;
    v_cat    products.category%TYPE;
    v_stock  products.stock_qty%TYPE;
BEGIN
    OPEN c_prod;
    LOOP
        FETCH c_prod INTO v_name, v_cat, v_stock;
        EXIT WHEN c_prod%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' (' || v_cat || ') - Stock: ' || v_stock);
    END LOOP;
    CLOSE c_prod;
END;
/
-------------------------------------------------
-- Exercise 7: Student Performance Report (below class average)
-------------------------------------------------
DECLARE
    v_avg NUMBER;
    CURSOR c_low IS
        SELECT s.student_name,
               e.subject,
               e.marks
        FROM exam_results e
        JOIN students s ON e.student_id = s.student_id
        WHERE e.exam_date = (SELECT MAX(exam_date) FROM exam_results)
          AND e.marks < v_avg;
    v_name   students.student_name%TYPE;
    v_sub    exam_results.subject%TYPE;
    v_marks  exam_results.marks%TYPE;
BEGIN
    SELECT AVG(marks)
    INTO v_avg
    FROM exam_results
    WHERE exam_date = (SELECT MAX(exam_date) FROM exam_results);

    OPEN c_low;
    LOOP
        FETCH c_low INTO v_name, v_sub, v_marks;
        EXIT WHEN c_low%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || v_sub || ' - ' || v_marks);
    END LOOP;
    CLOSE c_low;
END;
/
-------------------------------------------------
-- Exercise 8: Employee Anniversary (5, 10, 15 years this month)
-------------------------------------------------
DECLARE
    CURSOR c_ann IS
        SELECT emp_name,
               hire_date,
               TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) AS years_done
        FROM employees
        WHERE TO_CHAR(hire_date,'MM') = TO_CHAR(SYSDATE,'MM')
          AND TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) IN (5,10,15);
    v_name  employees.emp_name%TYPE;
    v_hire  employees.hire_date%TYPE;
    v_years NUMBER;
BEGIN
    OPEN c_ann;
    LOOP
        FETCH c_ann INTO v_name, v_hire, v_years;
        EXIT WHEN c_ann%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || TO_CHAR(v_hire,'YYYY-MM-DD') ||
                             ' - ' || v_years || ' years');
    END LOOP;
    CLOSE c_ann;
END;
/
-------------------------------------------------
-- Exercise 9: Monthly Sales Commission (5%)
-------------------------------------------------
DECLARE
    CURSOR c_sales IS
        SELECT e.emp_name,
               e.emp_id,
               SUM(s.sale_amount) AS total_sales
        FROM employees e
        JOIN sales s ON e.emp_id = s.emp_id
        WHERE TRUNC(s.sale_date,'MM') = TRUNC(SYSDATE,'MM')
        GROUP BY e.emp_name, e.emp_id;
    v_name   employees.emp_name%TYPE;
    v_id     employees.emp_id%TYPE;
    v_sales  NUMBER;
    v_comm   NUMBER;
BEGIN
    OPEN c_sales;
    LOOP
        FETCH c_sales INTO v_name, v_id, v_sales;
        EXIT WHEN c_sales%NOTFOUND;
        v_comm := v_sales * 0.05;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - Sales: ' || v_sales ||
                             ' - Commission: ' || v_comm);
    END LOOP;
    CLOSE c_sales;
END;
/
-------------------------------------------------
-- Exercise 10: Unused Accounts Cleanup (>1 year inactive)
-------------------------------------------------
DECLARE
    CURSOR c_acc IS
        SELECT user_id, username
        FROM user_accounts
        WHERE last_login_date < ADD_MONTHS(TRUNC(SYSDATE), -12)
          AND status <> 'Inactive';
    v_user_id user_accounts.user_id%TYPE;
    v_username user_accounts.username%TYPE;
BEGIN
    OPEN c_acc;
    LOOP
        FETCH c_acc INTO v_user_id, v_username;
        EXIT WHEN c_acc%NOTFOUND;

        UPDATE user_accounts
        SET status = 'Inactive'
        WHERE user_id = v_user_id;

        DBMS_OUTPUT.PUT_LINE('Marked inactive: ' || v_username);
    END LOOP;
    CLOSE c_acc;
    COMMIT;
END;
/
-------------------------------------------------
-- Exercise 11: Department Salary Budget Check
-------------------------------------------------
DECLARE
    CURSOR c_budget IS
        SELECT d.dept_name,
               SUM(e.salary) AS total_sal
        FROM employees e
        JOIN departments d ON e.dept_id = d.dept_id
        GROUP BY d.dept_name;
    v_dept   departments.dept_name%TYPE;
    v_total  NUMBER;
BEGIN
    OPEN c_budget;
    LOOP
        FETCH c_budget INTO v_dept, v_total;
        EXIT WHEN c_budget%NOTFOUND;

        IF v_total > 50000 THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: ' || v_dept ||
                                 ' salary budget = ' || v_total);
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_dept || ' salary budget = ' || v_total);
        END IF;
    END LOOP;
    CLOSE c_budget;
END;
/
-------------------------------------------------
-- Exercise 12: Employee Promotion Eligibility
-------------------------------------------------
DECLARE
    CURSOR c_prom IS
        SELECT e.emp_name,
               e.salary,
               e.dept_id,
               TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) AS years_worked
        FROM employees e;
    v_name   employees.emp_name%TYPE;
    v_sal    employees.salary%TYPE;
    v_dept   employees.dept_id%TYPE;
    v_years  NUMBER;
    v_avg    NUMBER;
BEGIN
    OPEN c_prom;
    LOOP
        FETCH c_prom INTO v_name, v_sal, v_dept, v_years;
        EXIT WHEN c_prom%NOTFOUND;

        SELECT AVG(salary)
        INTO v_avg
        FROM employees
        WHERE dept_id = v_dept;

        IF v_years > 5 AND v_sal < v_avg THEN
            DBMS_OUTPUT.PUT_LINE(v_name || ' - Eligible for Promotion');
        END IF;
    END LOOP;
    CLOSE c_prom;
END;
/
-------------------------------------------------
-- Exercise 13: Customer Loyalty Program (parameterized cursor)
-------------------------------------------------
DECLARE
    v_cust_id customers.customer_id%TYPE := 1;

    CURSOR c_orders (p_cust_id customers.customer_id%TYPE) IS
        SELECT order_id, total_amount
        FROM orders
        WHERE customer_id = p_cust_id;

    v_order_id    orders.order_id%TYPE;
    v_total_amt   orders.total_amount%TYPE;
    v_points      NUMBER;
BEGIN
    OPEN c_orders(v_cust_id);
    LOOP
        FETCH c_orders INTO v_order_id, v_total_amt;
        EXIT WHEN c_orders%NOTFOUND;

        v_points := v_total_amt / 10;
        DBMS_OUTPUT.PUT_LINE('Order ' || v_order_id ||
                             ' - Amount: ' || v_total_amt ||
                             ' - Points: ' || v_points);
    END LOOP;
    CLOSE c_orders;
END;
/
-------------------------------------------------
-- Exercise 14: Invoice Penalty Calculation
-------------------------------------------------
DECLARE
    CURSOR c_pen IS
        SELECT invoice_id,
               pending_amount,
               due_date
        FROM invoices
        WHERE status = 'PENDING'
          AND due_date < TRUNC(SYSDATE);
    v_inv_id   invoices.invoice_id%TYPE;
    v_pending  invoices.pending_amount%TYPE;
    v_due      invoices.due_date%TYPE;
    v_months   NUMBER;
    v_penalty  NUMBER;
    v_total    NUMBER;
BEGIN
    OPEN c_pen;
    LOOP
        FETCH c_pen INTO v_inv_id, v_pending, v_due;
        EXIT WHEN c_pen%NOTFOUND;

        v_months := FLOOR(MONTHS_BETWEEN(TRUNC(SYSDATE), v_due));
        IF v_months < 0 THEN
            v_months := 0;
        END IF;

        v_penalty := v_pending * 0.02 * v_months;
        v_total := v_pending + v_penalty;

        DBMS_OUTPUT.PUT_LINE('Invoice ' || v_inv_id ||
                             ' -> Pending: ' || v_pending ||
                             ', Months overdue: ' || v_months ||
                             ', Total with penalty: ' || v_total);
    END LOOP;
    CLOSE c_pen;
END;
/
-------------------------------------------------
-- Exercise 15: Product Restocking Suggestion (Electronics)
-------------------------------------------------
DECLARE
    CURSOR c_ele IS
        SELECT product_name, stock_qty
        FROM products
        WHERE UPPER(category) = 'ELECTRONICS';
    v_name  products.product_name%TYPE;
    v_stock products.stock_qty%TYPE;
    v_status VARCHAR2(20);
BEGIN
    OPEN c_ele;
    LOOP
        FETCH c_ele INTO v_name, v_stock;
        EXIT WHEN c_ele%NOTFOUND;

        IF v_stock < 10 THEN
            v_status := 'Critical';
        ELSIF v_stock BETWEEN 10 AND 50 THEN
            v_status := 'Low';
        ELSE
            v_status := 'OK';
        END IF;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Stock: ' || v_stock ||
                             ' - ' || v_status);
    END LOOP;
    CLOSE c_ele;
END;
/
-------------------------------------------------
-- Exercise 16: Monthly Sales Performance
-------------------------------------------------
DECLARE
    CURSOR c_perf IS
        SELECT e.emp_name,
               e.emp_id,
               SUM(s.sale_amount) AS total_sales
        FROM employees e
        JOIN sales s ON e.emp_id = s.emp_id
        WHERE TRUNC(s.sale_date,'MM') = TRUNC(SYSDATE,'MM')
        GROUP BY e.emp_name, e.emp_id;
    v_name   employees.emp_name%TYPE;
    v_id     employees.emp_id%TYPE;
    v_sales  NUMBER;
    v_mark   VARCHAR2(30);
BEGIN
    OPEN c_perf;
    LOOP
        FETCH c_perf INTO v_name, v_id, v_sales;
        EXIT WHEN c_perf%NOTFOUND;

        IF v_sales < 5000 THEN
            v_mark := 'Needs Improvement';
        ELSE
            v_mark := 'Good Performer';
        END IF;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Sales: ' || v_sales ||
                             ' - ' || v_mark);
    END LOOP;
    CLOSE c_perf;
END;
/
-------------------------------------------------
-- Exercise 17: Employee Bonus Distribution
-------------------------------------------------
DECLARE
    CURSOR c_bonus IS
        SELECT emp_name, salary
        FROM employees;
    v_name  employees.emp_name%TYPE;
    v_sal   employees.salary%TYPE;
    v_bonus NUMBER;
BEGIN
    OPEN c_bonus;
    LOOP
        FETCH c_bonus INTO v_name, v_sal;
        EXIT WHEN c_bonus%NOTFOUND;

        IF v_sal < 1000 THEN
            v_bonus := v_sal * 0.15;
        ELSIF v_sal BETWEEN 1000 AND 2000 THEN
            v_bonus := v_sal * 0.10;
        ELSE
            v_bonus := v_sal * 0.05;
        END IF;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Salary: ' || v_sal ||
                             ' - Bonus: ' || v_bonus);
    END LOOP;
    CLOSE c_bonus;
END;
/
-------------------------------------------------
-- Exercise 18: High Value Customer Detection
-------------------------------------------------
DECLARE
    CURSOR c_hvc IS
        SELECT c.customer_name,
               COUNT(o.order_id) AS ord_count,
               SUM(o.total_amount) AS total_val
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        GROUP BY c.customer_name
        HAVING SUM(o.total_amount) > 10000;
    v_name    customers.customer_name%TYPE;
    v_count   NUMBER;
    v_total   NUMBER;
BEGIN
    OPEN c_hvc;
    LOOP
        FETCH c_hvc INTO v_name, v_count, v_total;
        EXIT WHEN c_hvc%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Orders: ' || v_count ||
                             ' - Total: ' || v_total);
    END LOOP;
    CLOSE c_hvc;
END;
/


-- 3rd Exversize conditinals 
----------------------------
-- IF CONDITIONS
----------------------------

-- 1. Salary Adjustment Policy
DECLARE
    v_emp_id   employees.emp_id%TYPE := 101;
    v_salary   employees.salary%TYPE;
    v_new_sal  employees.salary%TYPE;
BEGIN
    SELECT salary
    INTO v_salary
    FROM employees
    WHERE emp_id = v_emp_id;

    IF v_salary < 30000 THEN
        v_new_sal := v_salary * 1.15;
    ELSIF v_salary BETWEEN 30000 AND 50000 THEN
        v_new_sal := v_salary * 1.10;
    ELSE
        v_new_sal := v_salary * 1.05;
    END IF;

    UPDATE employees
    SET salary = v_new_sal
    WHERE emp_id = v_emp_id;

    DBMS_OUTPUT.PUT_LINE('Old salary: ' || v_salary || ' New salary: ' || v_new_sal);
    COMMIT;
END;
/
----------------------------

-- 2. Exam Grading System
DECLARE
    v_marks NUMBER := 78;
    v_result VARCHAR2(20);
BEGIN
    IF v_marks >= 90 THEN
        v_result := 'Excellent';
    ELSIF v_marks BETWEEN 70 AND 89 THEN
        v_result := 'Good';
    ELSIF v_marks BETWEEN 50 AND 69 THEN
        v_result := 'Pass';
    ELSE
        v_result := 'Fail';
    END IF;

    DBMS_OUTPUT.PUT_LINE('Marks: ' || v_marks || ' -> ' || v_result);
END;
/
----------------------------

-- 3. Loan Eligibility Check
DECLARE
    v_salary NUMBER := 45000;
    v_age    NUMBER := 35;
BEGIN
    IF v_salary > 40000 AND v_age < 60 THEN
        DBMS_OUTPUT.PUT_LINE('Eligible for loan');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Not Eligible');
    END IF;
END;
/
----------------------------

-- 4. Stock Discount Application
DECLARE
    v_price      NUMBER := 8500;
    v_discount   NUMBER := 0;
    v_final      NUMBER;
BEGIN
    IF v_price > 10000 THEN
        v_discount := v_price * 0.20;
    ELSIF v_price BETWEEN 5000 AND 10000 THEN
        v_discount := v_price * 0.10;
    END IF;

    v_final := v_price - v_discount;
    DBMS_OUTPUT.PUT_LINE('Original: ' || v_price ||
                         ' Discount: ' || v_discount ||
                         ' Final: ' || v_final);
END;
/
----------------------------

-- 5. Employee Bonus Allocation
DECLARE
    v_emp_id   employees.emp_id%TYPE := 101;
    v_hiredate employees.hire_date%TYPE;
    v_years    NUMBER;
    v_bonus    NUMBER;
BEGIN
    SELECT hire_date
    INTO v_hiredate
    FROM employees
    WHERE emp_id = v_emp_id;

    v_years := TRUNC(MONTHS_BETWEEN(SYSDATE, v_hiredate) / 12);

    IF v_years > 5 THEN
        v_bonus := 5000;
    ELSE
        v_bonus := 2000;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Years: ' || v_years || ' Bonus: ' || v_bonus);
END;
/
----------------------------
-- LOOP
----------------------------

-- 6. ATM Cash Dispensing
DECLARE
    v_amount NUMBER := 7650;
    n500 NUMBER := 0;
    n100 NUMBER := 0;
    n50  NUMBER := 0;
BEGIN
    WHILE v_amount >= 500 LOOP
        n500 := n500 + 1;
        v_amount := v_amount - 500;
    END LOOP;

    WHILE v_amount >= 100 LOOP
        n100 := n100 + 1;
        v_amount := v_amount - 100;
    END LOOP;

    WHILE v_amount >= 50 LOOP
        n50 := n50 + 1;
        v_amount := v_amount - 50;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('500: ' || n500 || ' 100: ' || n100 || ' 50: ' || n50);
END;
/
----------------------------

-- 7. Restaurant Bill Calculation
DECLARE
    v_total NUMBER := 0;
    v_price NUMBER;
BEGIN
    FOR i IN 1..5 LOOP
        IF i = 1 THEN
            v_price := 150;
        ELSIF i = 2 THEN
            v_price := 200;
        ELSIF i = 3 THEN
            v_price := 120;
        ELSIF i = 4 THEN
            v_price := 90;
        ELSE
            v_price := 300;
        END IF;

        v_total := v_total + v_price;
        DBMS_OUTPUT.PUT_LINE('Item ' || i || ' price: ' || v_price);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total bill = ' || v_total);
END;
/
----------------------------

-- 8. Cinema Ticket Booking
DECLARE
    v_start_seat NUMBER := 21;
    v_seats      NUMBER := 10;
    v_end_seat   NUMBER;
BEGIN
    v_end_seat := v_start_seat + v_seats - 1;

    FOR s IN v_start_seat..v_end_seat LOOP
        DBMS_OUTPUT.PUT_LINE('Seat booked: ' || s);
    END LOOP;
END;
/
----------------------------

-- 9. Electricity Bill Slab Calculation
DECLARE
    v_units NUMBER := 350;
    v_bill  NUMBER := 0;
BEGIN
    FOR u IN 1..v_units LOOP
        IF u <= 100 THEN
            v_bill := v_bill + 3;
        ELSIF u <= 300 THEN
            v_bill := v_bill + 5;
        ELSE
            v_bill := v_bill + 7;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Units: ' || v_units || ' Bill: ' || v_bill || ' AFN');
END;
/
----------------------------

-- 10. Library Late Fees
DECLARE
    v_days NUMBER := 9;
    v_fine NUMBER := 0;
BEGIN
    FOR d IN 1..v_days LOOP
        IF d <= 5 THEN
            v_fine := v_fine + 10;
        ELSE
            v_fine := v_fine + 20;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Days late: ' || v_days || ' Fine: ' || v_fine || ' AFN');
END;
/
----------------------------

-- 11. Bank Interest Accumulation (compound yearly)
DECLARE
    v_principal NUMBER := 10000;
    v_rate      NUMBER := 8;   -- 8%
    v_years     NUMBER := 5;
    v_amount    NUMBER;
BEGIN
    v_amount := v_principal;

    FOR y IN 1..v_years LOOP
        v_amount := v_amount * (1 + v_rate / 100);
        DBMS_OUTPUT.PUT_LINE('Year ' || y || ' Amount: ' || v_amount);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Final amount after ' || v_years || ' years = ' || v_amount);
END;
/
----------------------------

-- 12. Student Attendance Record
DECLARE
    v_status VARCHAR2(10);
BEGIN
    FOR d IN 1..30 LOOP
        IF d IN (2,5,7,10) THEN
            v_status := 'Absent';
        ELSE
            v_status := 'Present';
        END IF;

        DBMS_OUTPUT.PUT_LINE('Day ' || d || ': ' || v_status);
    END LOOP;
END;
/
----------------------------
-- CURSOR
----------------------------

-- 13. List Employees in a Department
DECLARE
    v_dept_id employees.dept_id%TYPE := 10;
    CURSOR c_emp IS
        SELECT emp_name, salary
        FROM employees
        WHERE dept_id = v_dept_id;
    v_name   employees.emp_name%TYPE;
    v_sal    employees.salary%TYPE;
BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp INTO v_name, v_sal;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || v_sal);
    END LOOP;
    CLOSE c_emp;
END;
/
----------------------------

-- 14. Update Salaries in Bulk (Salesman)
DECLARE
    CURSOR c_sales IS
        SELECT emp_id, emp_name, salary
        FROM employees
        WHERE job_title = 'Salesman'
        FOR UPDATE;
    v_id   employees.emp_id%TYPE;
    v_name employees.emp_name%TYPE;
    v_sal  employees.salary%TYPE;
BEGIN
    OPEN c_sales;
    LOOP
        FETCH c_sales INTO v_id, v_name, v_sal;
        EXIT WHEN c_sales%NOTFOUND;

        UPDATE employees
        SET salary = v_sal + 2000
        WHERE CURRENT OF c_sales;

        DBMS_OUTPUT.PUT_LINE('Updated: ' || v_name || ' New salary: ' || (v_sal + 2000));
    END LOOP;
    CLOSE c_sales;
    COMMIT;
END;
/
----------------------------

-- 15. Top Student Finder (highest GPA per class)
DECLARE
    CURSOR c_class IS
        SELECT DISTINCT class_id
        FROM students;
    v_class   students.class_id%TYPE;
    v_name    students.student_name%TYPE;
    v_gpa     students.gpa%TYPE;
BEGIN
    OPEN c_class;
    LOOP
        FETCH c_class INTO v_class;
        EXIT WHEN c_class%NOTFOUND;

        SELECT student_name, gpa
        INTO v_name, v_gpa
        FROM students
        WHERE class_id = v_class
          AND gpa = (SELECT MAX(gpa) FROM students WHERE class_id = v_class)
          AND ROWNUM = 1;

        DBMS_OUTPUT.PUT_LINE('Class ' || v_class || ' -> ' || v_name || ' (GPA: ' || v_gpa || ')');
    END LOOP;
    CLOSE c_class;
END;
/
----------------------------

-- 16. Customer Credit Check (unpaid > 5000)
DECLARE
    CURSOR c_cust IS
        SELECT c.customer_name,
               SUM(o.unpaid_amount) AS total_unpaid
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.unpaid_amount > 0
        GROUP BY c.customer_name
        HAVING SUM(o.unpaid_amount) > 5000;
    v_name   customers.customer_name%TYPE;
    v_unpaid NUMBER;
BEGIN
    OPEN c_cust;
    LOOP
        FETCH c_cust INTO v_name, v_unpaid;
        EXIT WHEN c_cust%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' -> Unpaid: ' || v_unpaid);
    END LOOP;
    CLOSE c_cust;
END;
/
----------------------------

-- 17. Service Years Report
DECLARE
    CURSOR c_service IS
        SELECT emp_name, hire_date
        FROM employees;
    v_name  employees.emp_name%TYPE;
    v_hire  employees.hire_date%TYPE;
    v_years NUMBER;
BEGIN
    OPEN c_service;
    LOOP
        FETCH c_service INTO v_name, v_hire;
        EXIT WHEN c_service%NOTFOUND;

        v_years := TRUNC(MONTHS_BETWEEN(SYSDATE, v_hire) / 12);
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || v_years || ' years');
    END LOOP;
    CLOSE c_service;
END;
/
----------------------------

-- 18. Low Stock Notification
DECLARE
    CURSOR c_stock IS
        SELECT product_id, product_name, stock_qty
        FROM products
        WHERE stock_qty < 10
        FOR UPDATE;
    v_id    products.product_id%TYPE;
    v_name  products.product_name%TYPE;
    v_qty   products.stock_qty%TYPE;
BEGIN
    OPEN c_stock;
    LOOP
        FETCH c_stock INTO v_id, v_name, v_qty;
        EXIT WHEN c_stock%NOTFOUND;

        UPDATE products
        SET status = 'Reorder Needed'
        WHERE CURRENT OF c_stock;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Stock: ' || v_qty || ' -> Reorder Needed');
    END LOOP;
    CLOSE c_stock;
    COMMIT;
END;
/
----------------------------

-- 19. Department Salary Report
DECLARE
    CURSOR c_dept IS
        SELECT d.dept_name,
               SUM(e.salary) AS total_sal
        FROM employees e
        JOIN departments d ON e.dept_id = d.dept_id
        GROUP BY d.dept_name;
    v_dept  departments.dept_name%TYPE;
    v_total NUMBER;
BEGIN
    OPEN c_dept;
    LOOP
        FETCH c_dept INTO v_dept, v_total;
        EXIT WHEN c_dept%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_dept || ' -> Total salary: ' || v_total);
    END LOOP;
    CLOSE c_dept;
END;
/
----------------------------

-- 20. Monthly Rent Collection
DECLARE
    CURSOR c_tenant IS
        SELECT t.tenant_name
        FROM tenants t
        WHERE NOT EXISTS (
            SELECT 1
            FROM rent_payments p
            WHERE p.tenant_id = t.tenant_id
              AND TRUNC(p.payment_date,'MM') = TRUNC(SYSDATE,'MM')
        );
    v_name tenants.tenant_name%TYPE;
BEGIN
    OPEN c_tenant;
    LOOP
        FETCH c_tenant INTO v_name;
        EXIT WHEN c_tenant%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Reminder sent to: ' || v_name);
    END LOOP;
    CLOSE c_tenant;
END;
/
