-- Table employees

-- | id | name | city | salary | dept_id |

-- Table departments

-- | dept_id | dept_name |

-- LEAD & LAG Window Function Questions

-- Q1. Show salary along with previous salary
   select e.name, e.salary, lag(e.salary) 
   over(order by e.salary) as previous_salary
   from employees e;

-- Q2. Find employees whose salary is greater than     
       previous employee
    select * from (select *, lag(e.salary) over(order by   
    e.salary) as previous_salary from employees e) t
    where salary > previous_salary;

-- Q3. Find employees whose salary decreased compared to 
       previous
    select * from (select *, lag(e.salary) over(order by   
    e.salary) as previous_salary from employees e) t
    where salary < previous_salary;

-- Q4. Show salary along with next salary
   select e.name, e.salary, lead(e.salary) 
   over(order by e.salary) as next_salary from employees e;

-- Q5. Find employees whose salary is less than next 
       employee
   select * from (select *, lead(e.salary) over(order by 
   e.salary) as next_salary from employees e)t
   where salary < next_salary;

-- Q6. Find salary difference between current and previous employee
   select e.name,
   COALESCE(e.salary - lag(e.salary)over(order by e.salary),0) as salary_diff_from_prev
   from employees e;

-- Q7. Find percentage increase from previous salary
   with salary_percent_increase as (select e.salary, lag(e.salary)over(order by e.salary) as previous_salary
   from employees e)
   select salary,previous_salary,
          CASE
       	      WHEN previous_salary IS NULL THEN NULL
       	      ELSE (salary - previous_salary/previous_salary * 100) 
       END as percentage_increase
   from salary_percent_increase;
   

-- Q8. Find employees who have highest jump in salary
   with highest_jump_calc as (
   select e.id,e.name,
   (e.salary - lag(e.salary)over(order by e.salary)) as salary_diff_from_prev
   from employees e),
   ranked as (select *, dense_rank() over(order by salary_diff_from_prev desc) as rn 
   from highest_jump_calc
   where salary_diff_from_prev is not null)
   select * from ranked where rn = 1;
   
