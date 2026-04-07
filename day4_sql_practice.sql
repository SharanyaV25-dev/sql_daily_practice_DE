-- Day 4 
-- Table employees

-- | id | name | city | salary | dept_id |

-- Table departments

-- | dept_id | dept_name |


-- Q1. Find top 3 highest paid employees per department
   with top_highest_paid as (
          select e.id, e.name, d.dept_name,
   	  dense_rank() over(partition by d.dept_id order by e.salary desc) as ranked 
          from employees e join departments d on e.dept_id = d.dept_id)
   select * from top_highest_paid where ranked <=3;

-- Q2. Find employees who earn more than department average
   with dept_avg as (select e.name,e.salary,d.dept_name,avg(e.salary)over(partition by d.dept_id) as avg_salary from employees e 
   join departments d on e.dept_id = d.dept_id)
   select * from dept_avg where salary > avg_salary;

-- Q3. Find departments with highest total salary
   with tot_sal as(select d.dept_id,sum(e.salary) as total_salary from employees e 
   join departments d on e.dept_id = d.dept_id
   group by d.dept_id),
   ranked as(select *,dense_rank()over(order by total_salary desc) as rankk from tot_sal)
   select * from ranked where rankk = 1;
   
-- Q4. Find employees whose salary rank is within top 2 globally
   with top_ranked as  (
          select e.id, e.name, d.dept_name, e.salary,
   	  dense_rank() over(order by e.salary desc) as ranked 
          from employees e join departments d on e.dept_id = d.dept_id)
   select * from top_ranked where ranked <=2;

-- Q5. Find employees whose salary is same as another employee
   select * from employees
   where salary in (
    select salary from employees
    group by salary
    having count(*) > 1)
    order by salary desc;

-- Q6. Find 2nd highest salary in each department
   with second_highest as (select d.dept_name,e.salary,
   dense_rank() over(partition by d.dept_id order by e.salary desc) as rn 
   from employees e join departments d on e.dept_id = d.dept_id)
   select dept_name,salary from second_highest where rn = 2;

-- Q7. Find employees whose salary is greater than company average
   select * from employees e
   where e.salary >
   (select avg(salary) from employees);

-- Q8. Find total salary contribution % per employee in their department
   select e.name,d.dept_name,e.salary, 
   (e.salary / sum(e.salary) over(partition by d.dept_id))*100.0 as contribute_percentage
   from employees e join departments d on e.dept_id = d.dept_id;
    