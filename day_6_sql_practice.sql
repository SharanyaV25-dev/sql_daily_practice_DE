-- Day 6 sql practice

-- Table employees

-- | id | name | city | salary | dept_id | manager_id | joining_date

-- Table departments

-- | dept_id | dept_name |

-- Q1. Find employees who have same salary in different departments
with valid_salaries as (select salary from employees
						group by salary
						having count(distinct dept_id) > 1)
select e.id, e.name, d.dept_name, e.salary
       from employees e join departments d on e.dept_id = d.dept_id
 	   where e.salary in (select salary from valid_salaries);

-- Q2. Find department where max salary employee joined earliest
with max_sal_dept as(select e.name,d.dept_name,e.salary,e.joining_date,
                     dense_rank()over(partition by d.dept_id order by e.salary desc) as rnk_
                     from employees e join departments d on e.dept_id = d.dept_id),
          ranked as(select *,
                    row_number()over(order by joining_date) as rnkk
                    from max_sal_dept where rnk_=1)
          select dept_name from ranked where rnkk =1;   
                 
-- Q3. Find employees whose salary is greater than avg of top 3 salaries
with sal_sort as(select e.name,e.salary,
                  dense_rank()over(order by salary desc)as rnk
                  from employees e),
top_3_avg as(select round(avg(salary),2) as top_3_avg_Sal
             from sal_sort where rnk <=3)
select name,salary,top_3_avg_Sal from sal_sort,top_3_avg where salary > top_3_avg_Sal;

-- Q4. Find employees who are not highest but still above department avg
with dept_avg as (select e.name,d.dept_name,e.salary,e.dept_id,
 	   			  avg(e.salary)over(partition by d.dept_id) as dept_avg_sal
 	   			  from employees e join departments d on e.dept_id = d.dept_id),
 	 ranked as (select *,dense_rank()over(partition by dept_id order by salary desc) as rank_
 	            from dept_avg)
select * from ranked where rank_ > 1 and salary > dept_avg_sal;

-- Q5. Find department with most number of high salary employees (>60k)
with dept_high_sal_count as(select dept_id,count(salary) as cnt
							from employees where salary > 60000 group by dept_id),
				   ranked as(select *, dense_rank()over(order by cnt desc) as ranking from dept_high_sal_count)
select r.dept_id,d.dept_name from ranked r join departments d on r.dept_id = d.dept_id where ranking = 1;

-- Q6. Find employees whose salary is increasing compared to both previous AND next
with prev_next_sal as (select name,dept_id,salary,
       				   lag(salary)over(partition by dept_id order by id) as prev_sal,
       			 	   lead(salary)over(partition by dept_id order by id) as next_sal
       				   from employees)
select * from prev_next_sal where prev_sal is not null and next_sal is not null 
and salary> prev_sal and salary>next_sal;

-- Q7. Find employees whose salary is median salary of company
with ranked as (select name,salary,
       			row_number() over(order by salary) as rn,
       			count(*)over() as cnt
				from employees),
filter_median as (select * from ranked where rn in (floor((cnt+1)/2.0), ceil((cnt+1)/2.0)))
select name,salary from filter_median;
                  
       