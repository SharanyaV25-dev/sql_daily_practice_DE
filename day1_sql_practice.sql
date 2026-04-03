-- Table employees

-- | id | name | city | salary | dept_id |

-- Table departments

-- | dept_id | dept_name |

-- PART 1: BASIC + FILTERING

-- 1. Get all employees data
   select * from employees;

-- 2. Get only name and salary columns
   select e.name, e.salary from employees e;

-- 3. Find employees with salary greater than 50,000
   select * from employees e where e.salary > 50000;

-- 4. Find employees from Chennai
   select * from employees e where e.city = 'Chennai';

-- 5. Find employees from Chennai with salary > 40,000
   select * from employees e 
   where e.city = 'Chennai' and e.salary > 40000;

-- 6. Get employees sorted by salary (highest first)
   select * from employees e 
   order by e.salary desc;

-- 7. Get top 3 highest paid employees
   select * from employees e 
   order by e.salary desc limit 3;

-- PART 2: JOINS (VERY IMPORTANT)

-- 8. Get employee names along with their department names
   select e.name, d.dept_name from employees e inner join
   departments d on e.dept_id = d.dept_id;

-- 9. Get all employees even if they don’t have a department
   select * from employees e left join departments d
   on e.dept_id = d.dept_id;

-- 10. Count number of employees in each department
   select d.dept_name,count(e.id) as employees_count
   from employees e join departments d  
   on e.dept_id = d.dept_id
   group by d.dept_name;

-- PART 3: GROUP BY + AGGREGATION

-- 11. Find total salary per city
   select e.city, sum(e.salary) as total_salary
   from employees e
   group by e.city;

-- 12. Find average salary per city
   select e.city, avg(e.salary) as average_salary
   from employees e
   group by e.city;

-- 13. Count number of employees per city
   select e.city, count(e.id) as employees_count
   from employees e
   group by e.city;

-- 14. Find cities where employee count > 1
   select e.city, count(e.id) as employees_count
   from employees e
   group by e.city having count(e.id) > 1;

-- 15. Find maximum salary in each department
   select d.dept_name, max(e.salary) as maximum_salary
   from employees e join departments d  
   on e.dept_id = d.dept_id
   group by d.dept_name;

-- PART 4: INTERVIEW-LEVEL

-- 16. Find second highest salary
   select max(e.salary) as second_highest_salary
   from employees e
   where e.salary <(select max(e.salary) from employees e);

-- 17. Find employees who earn more than average salary       
   select * from employees e where 
   e.salary > (select avg(e.salary) from employees e);

-- 18. Find duplicate employees based on name and city
   select e.name,e.city from employees e
   group by name,city
   having count(*) > 1;

-- 19. Find duplicate records based on name and city
   with duplicate_records as(select *,
   ROW_NUMBER() over(partition by name,city order by id
   as rn from employees)
   select * from duplicate_records where rn > 1;

  