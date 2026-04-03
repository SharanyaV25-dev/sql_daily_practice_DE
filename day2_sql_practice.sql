-- Table employees

-- | id | name | city | salary | dept_id |

-- Table departments

-- | dept_id | dept_name |

-- Window Function Questions

-- Q1.Assign row number to each employee by salary (highest first)
   select *, row_number() over(order by e.salary desc) 
   as RowNum from employees e;

-- Q2. Rank employees based on salary (handle ties)
   select *, dense_rank() over(order by e.salary desc) as
   DenseRank from employees e;

-- Q3. Find top 2 highest paid employees in each city
   with highest_paid as(select *, row_number()
   over(partition by e.city order by e.salary desc) as rn
   from employees e)
   select * from highest_paid where rn <=2;

-- Q4. Find lowest salary employee in each department
   with lowest_salary as(select d.dept_name,e.salary,row_number()
   over(partition by d.dept_id order by e.salary asc) as RowNum
   from employees e join departments d on e.dept_id = d.dept_id)
   select * from lowest_salary where RowNum = 1;

-- Q5. Find cumulative salary (running total)
   select * , sum(e.salary) over(order by e.id) as running_salary from employees e;

-- Q6. Find second highest salary using window function
   with second_highest as(select *, row_number()
   over(order by e.salary desc) as rn
   from employees e)
   select * from second_highest where rn = 2;
