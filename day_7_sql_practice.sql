-- Day 7 sql practice

-- Table employees

-- | id | name | city | salary | dept_id | manager_id | joining_date

-- Table departments

-- | dept_id | dept_name |

-- Q1. Find employees whose salary is top 3 in company but NOT top 2 in their department

   with top_3 as (select e.id,e.name,d.dept_name,e.salary,
              dense_rank()over(order by salary desc)as rank_
              from employees e join departments d on e.dept_id = d.dept_id),
   top_2_dept as (select e.id,e.name,d.dept_id,d.dept_name,e.salary,
              dense_rank()over(partition by dept_id order by salary desc)as ranked
              from employees e join departments d on e.dept_id = d.dept_id)
   select t.id,t.name,t1.dept_id,t1.dept_name,t.rank_,t1.ranked 
   from top_3 t join top_2_dept t1 on t.id = t1.id
   where t.rank_<=3 and t1.ranked > 2;

-- Q2. Find employees who have same salary as their manager
   select e1.id,e1.name,e2.id as manager_id,e2.name as manager_name,e1.salary
   from employees e1 join employees e2 on e1.manager_id = e2.id 
   where e1.salary = e2.salary;

-- Q3. Find departments where no employee earns less than 50k
   select d.dept_name
   from departments d join employees e on d.dept_id = e.dept_id
   group by d.dept_name 
   having min(e.salary) >=50000;

-- Q4. Find employees whose salary is greater than median salary of their department
   with ranking as (select e.id,e.name,d.dept_id,d.dept_name,e.salary,
		    row_number()over(partition by d.dept_id order by e.salary) as rn,
		    count(*)over(partition by d.dept_id) as cnt
		    from employees e join departments d on e.dept_id = d.dept_id),
	 median_val as(select dept_id,avg(salary) as median_salary
	 	       from ranking where rn in (floor((cnt+1)/2.0),ceil((cnt+1)/2.0))
	 	       group by dept_id)
	 select r.name,r.dept_name,r.salary,median_salary
	 from ranking r join median_val m on r.dept_id = m.dept_id 
	 where r.salary > m.median_salary;

-- Q5. Find employees who have at least 2 people earning less than them in same department
   with ranked as (select e.id,e.name,d.dept_id,d.dept_name,e.salary,
		   row_number()over(partition by d.dept_id order by e.salary desc) as rank_
		   from employees e join departments d on e.dept_id = d.dept_id)
   select name,dept_name,salary from ranked where rank_>2;

-- Q6. Find employees whose salary is greater than all employees in another department
   with ranked as (select e.id,e.name,d.dept_id,d.dept_name,e.salary,
		   dense_rank()over(partition by d.dept_id order by e.salary desc) as rank_
		   from employees e join departments d on e.dept_id = d.dept_id)
	 select name,dept_name,salary from ranked 
	 where rank_= 1 and salary = (select max(salary) from ranked where rank_=1)

-- Q7. Find employees whose salary is between 2nd and 5th highest salary
   with ranking as (select e.id,e.name,d.dept_id,d.dept_name,e.salary,
		    dense_rank()over(order by e.salary desc) as ranked
		    from employees e join departments d on e.dept_id = d.dept_id)
	 select name,dept_name,salary from ranking 
	 where ranked > 2 and ranked < 5;

-- Q8. Find employees who have same rank in both department and global ranking

   with global_rank as (select e.id,e.name,d.dept_name,e.salary,
              		dense_rank()over(order by salary desc)as rank_
              		from employees e join departments d on e.dept_id = d.dept_id),
        dept_rank as (select e.id,e.name,d.dept_id,d.dept_name,e.salary,
              	      dense_rank()over(partition by dept_id order by salary desc)as ranked
              	      from employees e join departments d on e.dept_id = d.dept_id)
  	select g.id,g.name,d.dept_id,d.dept_name,g.salary,g.rank_,d.ranked 
  	from global_rank g join dept_rank d on g.id = d.id
  	where g.rank_=d.ranked;


