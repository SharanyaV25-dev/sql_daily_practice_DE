-- Day 5 sql practice

-- Table employees

-- | id | name | city | salary | dept_id | manager_id | joining_date

-- Table departments

-- | dept_id | dept_name |

-- Q1 - Highest Paid Employee per Department (Return full row)
   with high_sal as (select e.name, d.dept_name,e.salary,
                     max(e.salary) over(partition by e.dept_id) as highest_salary
                     from employees e join departments d on e.dept_id = d.dept_id)
   select * from high_sal where salary = highest_salary;

-- Q2 - Employees earning more than their manager
   select e.name,e.salary
   from employees e join employees m on e.manager_id = m.id 
   where e.salary > m.salary;
   

-- Q3 - Find employees who are in top 3 salaries across entire company AND top 2 in their department
   with ranking as (select e.id,e.name,d.dept_name,e.salary,
                    dense_rank() over(order by e.salary desc) as global_rank,
                    dense_rank() over(partition by d.dept_id order by e.salary desc) as dept_rank
                    from employees e join departments d on e.dept_id = d.dept_id) 
   select * from ranking where global_rank <= 3 and dept_rank <= 2;

-- Q4. Find departments where average salary is greater than overall company average
   select d.dept_name, round(avg(e.salary),2) as avg_dept_sal
   from employees e join departments d on e.dept_id = d.dept_id
   group by d.dept_name
   having avg_dept_sal > (select avg(salary) from employees);

-- Q5. Find employees whose salary is above department average BUT below company average
   with dept_avg as (select e.id,e.name,d.dept_name,e.salary, 
                     avg(e.salary)over(partition by d.dept_id) as avg_
                     from employees e join departments d on e.dept_id = d.dept_id)
   select * from dept_avg where salary > avg_ and salary < (select avg(salary) from employees);

-- Q6. Find employees who joined after the highest paid employee in their department
   with max_sal as (select e.name,d.dept_name,e.salary,e.joining_date,
                    first_value(joining_date)over(partition by e.dept_id order by e.salary desc) as highest_paid_joining_date
                    from employees e join departments d on e.dept_id = d.dept_id)
   select name,dept_name,salary,joining_date from max_sal where joining_date > highest_paid_joining_date;

-- Q7. Find salary gap between highest and lowest salary in each department
   select dept_name, max(e.salary) - min(e.salary) as salary_gap
   from employees e join departments d on e.dept_id = d.dept_id
   group by dept_name;

-- Q8. Find employees who have the same salary AND same department  
   with same_stats as(select e.name,d.dept_name,e.salary,
                      row_number() over(partition by e.salary,d.dept_name order by e.salary, d.dept_name desc) as rn
                      from employees e join departments d on e.dept_id = d.dept_id)
   select name,dept_name,salary from same_stats where rn >1;


  