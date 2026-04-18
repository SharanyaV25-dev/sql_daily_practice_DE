-- Day 9 sql practice

-- Table employees

-- | id | name | city | salary | dept_id | manager_id | joining_date

-- Table departments

-- | dept_id | dept_name |

-- Q1. Find employees who : earn more than department average AND are NOT in top 2 salaries of their department

   with dept_ranking as(select e.id,e.name,d.dept_id,d.dept_name,e.salary,
			dense_rank()over(partition by d.dept_id order by e.salary desc)as ranked,
			round(avg(e.salary)over(partition by d.dept_id),2) as dept_avg_salary
			from employees e join departments d on e.dept_id = d.dept_id)
	 select name,dept_name,salary,dept_avg_salary,ranked
	 from dept_ranking where salary > dept_avg_salary and ranked > 2;

-- Q2. Find departments where: total salary > 200k AND average salary > company average salary

   with dept_total as (select dept_id,sum(salary) as total_salary
		       from employees
		       group by dept_id),
        dept_avg as (select dept_id,round(avg(salary),2) as avg_salary
		     from employees
		     group by dept_id)
   select dt.dept_id 
   from dept_total dt join dept_avg da on dt.dept_id = da.dept_id 
   where dt.total_salary > 200000 and da.avg_salary > (select avg(salary) from employees);

-- Q3. Find employees whose salary is: higher than their manager AND also higher than department average
   
   with dept_avg as (select e.name,e.salary,e1.name as manager_name, e1.salary as manager_salary,
	 	     round(avg(e.salary)over(partition by e.dept_id),2) as dept_avg_salary
	 	     from employees e join employees e1 on e.manager_id = e1.id)
	 select * from dept_avg where salary > manager_salary and salary > dept_avg_salary;

-- Q4. Find employees whose salary increased compared to previous employee (based on joining_date within same department)
   
   with previous_salary as (select id,name,dept_id,salary,joining_date,
       			    lag(salary)over(partition by dept_id order by joining_date) as prev_sal
       			    from employees)
        select * from previous_salary where prev_sal is not null and salary > prev_sal;

-- Q5. Find top 3 highest paid employees per department
   
   with dept_highest_paid as (select name,dept_id,salary,
   			      dense_rank()over(partition by dept_id order by salary desc) as high_pay_ranking
   			      from employees)
   	 select * from dept_highest_paid where high_pay_ranking <=3;

-- Q6. Find departments where: median salary > company average salary

   with ranking as (select e.name,d.dept_id,d.dept_name,e.salary,
   		     row_number()over(partition by d.dept_id order by salary) as rn,
   		     count(*)over(partition by d.dept_id) as cnt
                    from employees e join departments d on e.dept_id  = d.dept_id),
      median_value as (select * from ranking
      		       where rn in (floor(cnt+1/2.0),ceil(cnt+1/2.0)))
      select name,dept_name,salary from median_value where salary > (select avg(salary) from employees);

-- Q7. Find employees who earn more than 75% of employees in their department

   with percentage_distribution as (select e.name,d.dept_name,e.salary,
				    round(cume_dist()over(partition by d.dept_id order by salary),2) as percent_distri
				    from employees e join departments d on e.dept_id = d.dept_id)    
	 select * from percentage_distribution where percent_distri > 0.75;

-- Q8. Find employees who: are in top 3 of their department AND top 10 globally AND contribute > 20% to their department salary

   with dept_ranking as (select e.id,d.dept_name,e.salary,
			 dense_rank()over(partition by d.dept_id order by e.salary desc) as d_rank,
			 dense_rank()over(order by salary desc) as g_rank
			 from employees e join departments d on e.dept_id = d.dept_id),
	 percentage_distribution as (select e.id,e.name,d.dept_name,e.salary,
				     round(cume_dist()over(partition by d.dept_id order by salary),2) as percent_distri
				     from employees e join departments d on e.dept_id = d.dept_id)    
	select p.name,d.dept_name,d.salary,g_rank,d_rank,percent_distri
	from dept_ranking d join percentage_distribution p on d.id = p.id
	where d.d_rank <=3 and d.g_rank <=10 and p.percent_distri > 0.2;

  
   
