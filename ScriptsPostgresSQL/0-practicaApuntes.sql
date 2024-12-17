select title_id, title, "type", price, (price*1.08) as Incrementado from titles t 
	order by "type", title;

-- Modifique la consulta del ejercicio anterior a fin de obtener los datos por orden descendente de
--precio actualizado.

select title_id, title, "type", price, (price*1.08) as Incrementado from titles t 
	order by Incrementado desc;

--Tambien se puede indicar el num de columna por la que queremos ordenar
select title_id, title, "type", price, (price*1.08) as Incrementado from titles t 
	order by 4 desc;  

--El operador de concatenación en PostgreSQL es ||. Los literales en la lista de
--salida del SELECT deben encerrarse entre comillas simples
select 'El apellido del empleado es ' || lname as "Dato empleado"	
	from employee e;
	
-- Obtenga en una única columna el apellido y nombres de los autores separados por coma
--con una cabecera de columna Listado de Autores. Ordene el conjunto resultado.
select au_lname || ', ' || au_fname as "Listado de Autores" 
	from authors a 
		order by au_lname;
		
/*
Los motores de bases de datos muchas veces proporcionan conversión entre tipos de datos
automática. Otras veces, tenemos que hacer nosotros mismos una conversión explícita entre
tipos.
Siempre es más seguro que tengamos el control total sobre el código, y esto lo logramos
haciendo la conversión explícita entre tipos de datos	

Obtenga un conjunto resultado para la tabla de
publicaciones que proporcione, para cada fila, una
salida como la siguiente.

Conversión de datos numéricos a caracter
Podemos convertir datos numéricos a caracter de manera explícita usando la función CAST:
CAST (columna-a-convertir AS tipo-de-dato-destino)
*/

--Ejemplo 
select price::varchar(5)
	from titles;
	
--Reslucion de consulta pedida
select title_id || 'posee un valor de $' || price::varchar(5) as Listado	
	from titles t 
		where price is not null
		order by title_id;
	
--Utilizacion del where con condicinales
select title as Titulo, price as Precio 
	from titles t
		where price <= 13
		order by price desc;
	
--Obtenga los apellidos y fecha de contratación de todos los empleados que fueron contratados
--entre el 01/01/1991 y el 01/01/1992. Use el predicado BETWEEN para elaborar la condición.
select lname || ', ' || fname as empleado, hire_date as fecha_contratacion
	from employee e 
		where hire_date between '01/01/1991' and '01/01/1992';

/*Obtenga los códigos, domicilio y ciudad de los autores con código 172-32-1176 y 238-95-7766. 
Utilice el operador IN para definir la condición de búsqueda.
Modifique la consulta para obtener todos los autores que no poseen esos códigos.*/
select au_id as codigo, address as domicilio, city as ciudad  
	from authors a 
	where au_id in('172-32-1176','238-95-7766');

--Obtenga código y título de todos los títulos que incluyen la palabra Computer en su título.
select title_id as codigo, title as titulo
	from titles t
		where title like '%Computer%';

select pub_name as Nombre, city as Ciudad, state as Estado, country as Pais
	from publishers p 
		where state is null;
	
select * from titles t 
	limit 10;

--------------------------SUBQUERIES EN CLAUSULAS FROM------------------------

