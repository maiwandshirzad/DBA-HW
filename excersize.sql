
-- cursor
DECLARE
  CURSOR c1 IS SELECT first_name, last_name FROM employees;
  v_fname employees.first_name%TYPE;
  v_lname employees.last_name%TYPE;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO v_fname, v_lname;
    EXIT WHEN c1%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_fname || ' ' || v_lname);
  END LOOP;
  CLOSE c1;
END;
/

  -- with for loop
BEGIN
  FOR rec IN (SELECT * FROM employees) LOOP
    DBMS_OUTPUT.PUT_LINE(rec.first_name);
  END LOOP;
END;
/


-- Exception Handling
BEGIN
  SELECT salary INTO v_sal FROM employees WHERE id = 999;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Employee not found');
END;
/

-- User-defined Exception
DECLARE
  e_low_salary EXCEPTION;
  v_sal NUMBER := 1000;
BEGIN
  IF v_sal < 2000 THEN
    RAISE e_low_salary;
  END IF;
EXCEPTION
  WHEN e_low_salary THEN
    DBMS_OUTPUT.PUT_LINE('Salary is too low.');
END;
/

-- Procedures Example
CREATE OR REPLACE PROCEDURE show_name(p_id NUMBER) AS
  v_name VARCHAR2(100);
BEGIN
  SELECT first_name INTO v_name FROM employees WHERE id = p_id;
  DBMS_OUTPUT.PUT_LINE('Employee: ' || v_name);
END;
/
-- Call it:
BEGIN
  show_name(1);
END;
/


 -- Functions Example
CREATE OR REPLACE FUNCTION get_sal(p_id NUMBER)
RETURN NUMBER AS
  v_sal NUMBER;
BEGIN
  SELECT salary INTO v_sal FROM employees WHERE id = p_id;
  RETURN v_sal;
END;
/
-- Use in SQL:
SELECT get_sal(1) FROM dual;


-- Trigger Example
CREATE OR REPLACE TRIGGER trg_log_salary
AFTER UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
  INSERT INTO salary_log(emp_id, old_sal, new_sal, changed_on)
  VALUES(:OLD.id, :OLD.salary, :NEW.salary, SYSDATE);
END;
/

-- Package
--Package Specification:
CREATE OR REPLACE PACKAGE emp_pkg AS
  PROCEDURE show_employee(p_id NUMBER);
  FUNCTION get_salary(p_id NUMBER) RETURN NUMBER;
END emp_pkg;
/

--Package Body:
CREATE OR REPLACE PACKAGE BODY emp_pkg AS
  PROCEDURE show_employee(p_id NUMBER) IS
    v_name VARCHAR2(50);
  BEGIN
    SELECT first_name INTO v_name FROM employees WHERE id = p_id;
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name);
  END;

  FUNCTION get_salary(p_id NUMBER) RETURN NUMBER IS
    v_sal NUMBER;
  BEGIN
    SELECT salary INTO v_sal FROM employees WHERE id = p_id;
    RETURN v_sal;
  END;
END emp_pkg;
/
