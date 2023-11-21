#SQL ASSINGMENT 2 (HUSSAIN DS4 VIOLET)

#Disabling SQL Safe Updates
set sql_safe_updates=0;

select * from procedureshistory;

#Updating Date format and renaming Date column to dates
alter table procedureshistory change Date Dates text;
update procedureshistory
set dates = str_to_date(dates, '%Y-%m-%d');
alter table procedureshistory
modify dates date;

#Changing data type of Proceduresubcode from text to int
alter table proceduresdetails
modify ProcedureSubCode int;
select * from proceduresdetails;

#Setting Primary Key
select * from petowners;
alter table petowners
add primary key (ownerid);

select * from pets;
alter table pets
add primary key (PetID(255));

/*1. List the names of all pet owners along with the names of their pets.*/

select po.ownerid, po.name, po.surname, pt.name as pet_name
from petowners po
inner join pets pt on pt.OwnerID = po.OwnerID;

/*2. List all pets and their owner names, including pets 
that don't have recorded owners.*/

select pt.name as pet_name, po.ownerid, po.name, po.surname
from pets pt
left join petowners po on pt.OwnerID = po.OwnerID;

select * from pets;

/*3. Combine the information of pets and their owners, including those pets
without owners and owners without pets.*/

select pt.*, po.*
from pets pt
left join petowners po on po.ownerid = pt.OwnerID; 


/*4. Find the names of pets along with their owners' names and 
the details of the procedures they have undergone.*/

select * from proceduresdetails;
select pt.petid, po.ownerId, pt.name as pet_name, po.name as owner_name, 
pcd.proceduretype, pcd.description, pch.dates, pch.ProcedureType
from petowners po
inner join pets pt on pt.OwnerID = po.OwnerID
inner join procedureshistory pch on pt.PetID = pch.petid
inner join proceduresdetails pcd on pch.ProcedureSubCode= pcd.proceduresubcode;


/*5. List all pet owners and the number of dogs they own.*/

select po.ownerid, po.name as owner_name, count(pt.petId) as count_of_dogs
from petowners po 
left join pets pt on po.OwnerID = pt.OwnerID 
where pt.kind = "Dog"
group by po.OwnerID, po.name;


/*6. Identify pets that have not had any procedures.*/

select pt.petid, pt.name, pch.dates, pch.proceduretype
from pets pt
left join procedureshistory pch on pt.PetID = pch.PetID and pch.PetID = null;

/*7. Find the name of the oldest pet.*/
#1 method
select petid, name, age from pets
order by age desc
limit 3;

#2 method
select petid, name, age
from pets
where age = (select MAX(age) from pets);

/*8. List all pets who had procedures that cost 
more than the average cost of all procedures.*/

SELECT pt.petid, pt.name AS pet_name, pcd.price, 
(SELECT round(AVG(price),0) FROM proceduresdetails) as avg_cost
FROM pets pt
LEFT JOIN procedureshistory pch ON pt.PetID = pch.PetID
LEFT JOIN proceduresdetails pcd ON pcd.ProcedureSubCode = pch.ProcedureSubCode
WHERE pcd.price > (SELECT round(AVG(price),0) as avg_cost FROM proceduresdetails);


/*9. Find the details of procedures performed on 'Cuddles'.*/

select pt.petid, pt.name, pch.dates, pch.proceduretype, pcd.description, pcd.price
from proceduresdetails pcd
join procedureshistory pch on pcd.ProcedureSubCode = pch.ProcedureSubCode
join pets pt on pch.PetID = pt.PetID
where name = "cuddles";

/*10. Create a list of pet owners along with the total cost they have spent on
procedures and display only those who have spent above the average
spending.*/

select ownerid, name as owner_name, total_spent, round(avg_spending,0) as avg_spent
from 
	(select po.ownerid, po.name, sum(pcd.price) as total_spent, avg(sum(pcd.price)) over () as avg_spending
	from petowners po
	left join pets pt on po.OwnerID = pt.OwnerID
	left join procedureshistory pch on pt.PetID = pch.PetID
	left join proceduresdetails pcd on pch.ProcedureSubCode = pcd.ProcedureSubCode
	group by po.OwnerID, po.name) as spending
where total_spent>avg_spending;

/*11. List the pets who have undergone a procedure called 'VACCINATIONS'.*/
select pt.petid, pt.name, pch.proceduretype
from pets pt
join procedureshistory pch on pch.PetID = pt.PetID
where ProcedureType= "vaccinations";

/*12. Find the owners of pets who have had a procedure called 'EMERGENCY'.*/
select po.OwnerID, po.name, po.surname, pch.proceduretype, pcd.Description
from petowners po
join pets pt on pt.OwnerID= po.OwnerID
join procedureshistory pch on pt.PetID = pch.PetID
join proceduresdetails pcd on pch.ProcedureSubCode = pcd.ProcedureSubCode
where pcd.Description= "Emergency";


/*13. Calculate the total cost spent by each pet owner on procedures.*/
select distinct(po.ownerid) as owner_id, po.name, po.surname, sum(pcd.price) as total_spent
from petowners po
	left join pets pt on pt.OwnerID = po.OwnerID
	left join procedureshistory pch on pt.petid =pch.PetID
	left join proceduresdetails pcd on pch.ProcedureSubCode = pcd.ProcedureSubCode
group by owner_id, po.name, po.surname;

/*14. Count the number of pets of each kind.*/

select kind, count(kind) as number_of_kind
from pets
group by kind; 

/*15. Group pets by their kind and gender and count the number of pets in each
group.*/
select kind, gender, count(petid) from pets
group by kind, gender; 

/*16. Show the average age of pets for each kind, but only for kinds that have more
than 5 pets.*/
select kind, round(avg(age), 1) as avg_age 
from pets
group by kind
having count(kind)>5;

/*17. Find the types of procedures that have an average cost greater than $50.*/
select proceduretype, round(avg(price), 1) as avg_price
from proceduresdetails
group by ProcedureType
having avg_price>50;

/*18. Classify pets as 'Young', 'Adult', or 'Senior' based on their age. 
Age less then 3 Young, Age between 3and 8 Adult, else Senior*/

select petid, kind, age,
case
	when age < 3 then "Young"
    when age > 3 and age < 8 then "Adult"
    else "Senior"
    end as Age_Group
from pets;

/*19. Calculate the total spending of each pet owner on procedures, labeling them
as 'Low Spender' for spending under $100, 'Moderate Spender' for spending
between $100 and $500, and 'High Spender' for spending over $500.*/

select distinct(po.ownerid) as owner_id, po.name, po.surname, sum(pcd.price) as total_spent,
case
	when sum(pcd.price) < 100 then "Low Spender"
    when sum(pcd.price) > 100 and sum(pcd.price) < 500 then "Moderate Spender"
    when sum(pcd.price) > 500 then "High Spender"
    when sum(pcd.price) is null then "No Spending"
    end as Spent_group
from petowners po
	left join pets pt on pt.OwnerID = po.OwnerID
	left join procedureshistory pch on pt.petid =pch.PetID
	left join proceduresdetails pcd on pch.ProcedureSubCode = pcd.ProcedureSubCode
group by owner_id, po.name, po.surname;


/*20. Show the gender of pets with a custom label ('Boy' for male, 'Girl' for female).*/
select petid, gender, 
case 
	when gender = 'Male' then "Boy"
    when gender = 'Female' then "Girl"
    end as Gender_group
from pets;

/*21. For each pet, display the pet's name, the number of procedures they've had,
and a status label: 'Regular' for pets with 1 to 3 procedures, 'Frequent' for 4 to
7 procedures, and 'Super User' for more than 7 procedures.*/

select pt.PetID, pt.Name, count(pch.ProcedureType) as No_of_procedures,
case
	when count(pch.ProcedureType) <= 3 then "Regular"
    when count(pch.ProcedureType) between 4 and 7 then "Frequent" 
    when count(pch.ProcedureType) > 7 then "Super User"
    end as Status
from pets pt
join procedureshistory pch on pt.PetID = pch.PetID
group by pt.PetID, pt.Name;	


/*22. Rank pets by age within each kind.*/
select petid, age, kind,
rank () over (partition by kind order by age desc) as rank_age
from pets;

/*23. Assign a dense rank to pets based on their age, regardless of kind.*/
select petid, age,
dense_rank () over (order by age desc) as rank_age
from pets;

/*24. For each pet, show the name of the next and previous pet in alphabetical order.*/
select petid, name, 
lead (name, 1) over (order by name) as next_name,
lag (name,1) over (order by name) as previous_name
from pets;

/*25. Show the average age of pets, partitioned by their kind.*/
select PetID, kind, round(avg(age) over (partition by kind) ,1) as avg_age
from pets;

/*26. Create a CTE that lists all pets, then select pets older than 5 years from the
CTE.*/

with pets_cte as (
	select * from pets
    )
    
select * from pets_cte
where age>5;
    