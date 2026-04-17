-- Day 8 sql practice

-- Table employees

-- | id | name | city | salary | dept_id | manager_id | joining_date

-- Table departments

-- | dept_id | dept_name |

-- Q1 — Find employees who are in top 5 salaries globally BUT not in top 3 of their department

   with global_ranking as (select e.id,e.name,e.salary,
			   dense_rank()over(order by salary desc) as g_rank
			   from employees e join departments d on e.dept_id = d.dept_id),
	dept_ranking as (select e.id,d.dept_name,e.salary,
			 dense_rank()over(partition by d.dept_id order by e.salary desc) as d_rank
			 from employees e join departments d on e.dept_id = d.dept_id)
	select g.name,d.dept_name,d.salary
	from global_ranking g join dept_ranking d on g.id = d.id
	where g_rank <=5 and d_rank > 3;

-- Q2 - Find employees who have 2nd highest salary in each department

   with ranking as(select e.id,e.name,d.dept_name,e.salary,
			   dense_rank()over(partition by d.dept_id order by salary desc) as rank_
			   from employees e join departments d on e.dept_id = d.dept_id)
	 select id,name,dept_name,salary from ranking where rank_ = 2;

-- Q3 - Find employees whose salary is greater than every employee in at least one other department
  
   with dept_max as(select dept_id,max(salary) as max_sal
			     from employees
			     group by dept_id)
   select e.id,e.name,e.dept_id,e.salary
   from employees e
   where exists(select 1 from dept_max d
             where d.dept_id != e.dept_id 
             and e.salary > d.max_sal)

-- Q4 - For each department, show: employee name, salary, running total of salary (ascending order)
   
   select e.name, e.dept_id,e.salary,
          sum(e.salary)over(partition by e.dept_id order by e.salary) as running_total
          from employees e;

-- Q5 - Find employees where salary difference with previous employee (within department, ordered by salary) is greater than 10k
   with sal_diff_calc as (select e.name,d.dept_name,e.salary,
          		  e.salary - lag(e.salary)over(partition by d.dept_id order by e.salary) as salary_difference
          		  from employees e join departments d on e.dept_id  = d.dept_id)
        select * from sal_diff_calc where salary_difference > 10000;

-- Q6 - Rank employees within department based on percentage contribution to total department salary
    
   with dept_total_salary as (select e.id,d.dept_id,e.name,d.dept_name,e.salary,
			      round(e.salary*100.0/sum(e.salary)over(partition by d.dept_id),2) as percent_contribution
			      from employees e join departments d on e.dept_id = d.dept_id)
	  select name,dept_name,salary,percent_contribution,
			 dense_rank()over(partition by dept_id order by percent_contribution desc) as dept_percentage_ranking
			 from dept_total_salary;


-- Q7 - Find the latest joined employee in each department

   select dept_id, max(joining_date)
   from employees
   group by dept_id;

-- Q8 - Employees earning more than 80% of company
   
   with percentage_distribution as (select e.name,d.dept_name, e.salary, e.joining_date,
       				    round(cume_dist() over(order by salary),2) as perc_contri
	   			    from employees e join departments d on e.dept_id = d.dept_id) 
   select * from percentage_distribution where perc_contri > 0.8;
   
-- Q9 - Find employees whose salary is above department average

   with avg_sal_dept as (select e.id,e.name,e.dept_id,e.salary,
		         round(avg(e.salary)over(partition by e.dept_id),2) as avg_sal
			 from employees e)
   select * from avg_sal_dept where salary > avg_sal;

-- Q10 - Find employees who are: top 3 in department AND top 10 overall AND joined after 2020
   
   with dept_ranking as (select e.id,d.dept_name,e.salary,
			 dense_rank()over(partition by d.dept_id order by e.salary desc) as d_rank
			 from employees e join departments d on e.dept_id = d.dept_id),
	global_ranking as (select e.id,e.name,e.salary,e.joining_date,
			   dense_rank()over(order by salary desc) as g_rank
			   from employees e join departments d on e.dept_id = d.dept_id)
	select g.name,d.dept_name,d.salary,g.joining_date
	from dept_ranking d join global_ranking g  on d.id = g.id
	where d_rank <= 3 and g_rank <= 10 and year(g.joining_date) > 2020 ;