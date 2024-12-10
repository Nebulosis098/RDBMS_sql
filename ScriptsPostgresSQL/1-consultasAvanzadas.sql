--Diapo 140 de ApunteMin.pdf

--Podemos combinar cada autor con todos los demás usando la siguiente sentencia:

select a1.au_lname as nombreAu1, a1.city as ciudadAu1, a2.au_lname as nombreAu2, a2.city as ciudadAu2
	from authors a1 cross join authors a2;
	
--Choca todos con todos, por cada fila de a1 tenemos todas las filas de a2
-- ..obtenemos 529 filas. (cada uno de los 23 autores combinados con 23 autores) 

--Sintaxis equivalente
select a1.au_lname as nombreAu1, a1.city as ciudadAu1, a2.au_lname as nombreAu2, a2.city as ciudadAu2
	from authors a1, authors a2;
	
--Podemos mejorar la consulta a fin de evitar que un autor se “empareje” con si mismo. Por
--ejemplo:
select a1.au_lname as nombreAu1, a1.city as ciudadAu1, a2.au_lname as nombreAu2, a2.city as ciudadAu2
	from authors a1, authors a2
		where a1.au_lname <> a2.au_lname;
		
--Esta consulta no parece ser muy útil, pero podemos adecuarla para -por ejemplo- listar todos
--los autores que viven en una misma ciudad:
select a1.au_lname as nombreAu1, a2.au_lname as nombreAu2, a1.city as ciudadAu1, a2.city as ciudadAu2
	from authors a1, authors a2
		where a1.au_lname <> a2.au_lname and 
			a1.city = a2.city
		order by a1.city desc;
		
--El query funciona bien. El autor Straight vive en Oakland y el autor Green también (A)
--Sin embargo, todavía tenemos el problema de que cada tupla aparece dos veces... Straight se
--“empareja” con Green (A), y está bien, pero también Green se “empareja” con Straight (B).
select a1.au_lname as nombreAu1, a2.au_lname as nombreAu2, a1.city as ciudadAu1, a2.city as ciudadAu2
	from authors a1, authors a2
		where a1.au_lname < a2.au_lname and 
			a1.city = a2.city
		order by a1.city;	
	
-------------------------NATURAL JOIN----------------------------
select *
	from authors a natural join authors b;

-------------------------INNER JOIN----------------------------
/*Un equi JOIN retorna solo las tuplas que poseen valores iguales para las columnas
especificadas.
El operador de comparación siempre es la igualdad (=). JOIN mas usado.
vamos a estar enlazando las tablas
generalmente a través de las columnas que las asocian en el modelo físico (Primary Keys y
Foreign Keys).
*/

select title as Titulo, pub_name as Editorial
	from titles t inner join publishers p 
		on t.pub_id = p.pub_id;
	
--Enlazar más de dos tablas en un Equi INNER JOIN
--queremos obtener los nombres de la editoriales que han editado
--publicaciones del autor con código '998-72-3567'.
select pub_name as editorial
	from publishers p inner join titles t
		on p.pub_id = t.pub_id
					inner join titleauthor ta
		on t.title_id = ta.title_id
	where ta.au_id = '998-72-3567';
	
--Supongamos que queremos obtener un listado de código de editorial, nombre de editorial
--junto a los códigos de publicaciones que han editado.
select p.pub_id as codEditor, pub_name as nomEditor, title_id as codPubli
	from titles t inner join publishers p 
		on t.pub_id = p.pub_id ;
	/*etorna dieciocho filas en el resultado.
	Las filas corresponden a las editoriales que
	poseen títulos publicados
	Podemos recuperar esas editoriales “perdidas” escribiendo, en lugar de un
INNER JOIN, un RIGHT JOIN:
*/
select p.pub_id as codEditor, pub_name as nomEditor, title_id as codPubli
	from titles t right join publishers p 
		on t.pub_id = p.pub_id ;	
	
--El FULL OUTER JOIN considera las dangling tuplas de ambos “lados”. En nuestro ejemplo
--obtenemos el mismo resultado:
select p.pub_id as codEditor, pub_name as nomEditor, title_id as codPubli
	from titles t full outer join publishers p 
		on t.pub_id = p.pub_id ;	

---------------------------------------------------------------------
---------------------------------------------------------------------
-------------------------QUERIES ANIDADOS----------------------------
--obtener el nombre de la editorial que editó la publicación con
--código 'PC8888'
select pub_id 
	from titles
	where title_id = 'PC8888';

select pub_name
	from publishers p 
		where pub_id = (select pub_id 
							from titles
								where title_id = 'PC8888');
	
--La tupla en nuestro caso es ('1389'). Esto es, un único componente CHAR(4) en este caso.
--Si se diera el caso de que (A) produjera más de una tupla o ninguna tupla, obtendríamos un
--error de ejecución.
							
----------------Condiciones que involucran relaciones------------------
-- OPERADOR IN
							
select au_id 
	from authors a 
	where au_id = '172-32-1176' or au_id = '238-95-7766';
							
select address
	from authors a 
		where au_id in (select au_id 
							from authors a 	
							where au_id = '172-32-1176' or au_id = '238-95-7766');
						
-- 	CUANTIFICADOR ALL	
--s <> ALL R es lo mismo que s NOT IN R.
select price
	from titles t 
	where price is not null;

--Query anidado
select title, price
	from titles t 
	where price >= all (select price
							from titles t 
							where price is not null); --Obtenemos el titulo mas caro con esta consulta

-- 	CUANTIFICADOR ANY
--s = ANY R es lo mismo que s IN R.
select price 
	from titles t 
	where price is not null and 
		price > 20;
	
--Query anidado
select title, price 
	from titles t 
	where price > any (select price 
					   		from titles t 
							where price is not null and 
									price > 20);
		
-- SUBQUERIES CORRELACIONADOS	
--empleado más antiguo de cada editorial
select pub_id, fname, lname, hire_date
	from employee e 
	where e.hire_date = (select min(hire_date) 
							from employee e2
							where e2.pub_id  = e.pub_id); --INTERESANTE ESTO
/*preguntamos en un subquery (A) cuál es la fecha más antigua de
contratación para la editorial a la que pertnece el Empleado que estamos procesando en el
outer query.
A medida que se “recorren” las tuplas de employee del outer query, cada tupla proporciona un
valor para e.pub_id (B).
*/
							
-- 	CUANTIFICADOR EXISTS
--El cuantificador EXISTS siempre precede a un subquery, y este subquery es siempre un
--subquery CORRELACIONADO.
							
--publicaciones que se vendieron en años diferentes a 1993 y 1994.						
select title, t.title_id
	from titles t 
	where exists ();


							