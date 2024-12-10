/*Comparación (=)
• Recuperar todos los productos cuyo precio sea mayor a 100500.
• Recuperar todos los atributos de la/s factura/s cuyo número sea 110
*/
select * from producto.producto p where p.precio_unitario > 100500;

select * from venta.factura f where numero = 110;

/*
2. Predicado BETWEEN
• Mostrar los productos cuyo precio esté entre 100500 y 100555.
• Recuperar las ventas realizadas entre el 1 de enero y el 30 de junio del año pasado.
*/
select * from producto.producto p where precio_unitario between 100500 and 100555;

select fecha from venta.factura f;

select * from venta.factura f where fecha between '2023-01-01' and '2023-06-30';

/*
3. Predicado IN o NOT IN
• Mostrar los productos cuyo identificador de subcategoría esté en el conjunto (1, 3, 5).
• Recuperar los clientes que pertenezcan a las ciudades (Santa Fe, Rosario, Paraná).
*/
select * from producto.producto p where id_subcategoria in(1,3,5);

select * 
	from persona.cliente c inner join persona.persona p on p.id = c.id_persona
		 				   inner join persona.localidad l on p.id_localidad = l.id	
	where l.descripcion in ('Santa Fe', 'Rosario', 'Paraná');

/*4. Predicado LIKE o NOT LIKE
• Recuperar los nombres de las marcas cuyo nombre comience con la letra “S”.
• Mostrar las descripciones de los productos que contengan la palabra “USB” y la
palabra “Adaptador”.
*/
select * from producto.marca m where descripcion like 'S%';

select * from producto.producto p where descripcion like '%USB%' or 
										descripcion like '%Adaptador%';

/*5. Predicado NULL
• Mostrar todos los registros de la tabla producto donde el “id” de subcategoría no esté
registrado.
• Recuperar los clientes cuyo email esté registrado. Recuperar codigo_cliente,
fecha_alta, e-mail y apellido y nombre o denominación (según se trate de persona
física o jurídica)
*/
select * from producto.producto p where id_subcategoria is null;

select * from persona.cliente c left join persona.persona p on c.id_persona = p.id 
			where p.email is not null;
		
select c.codigo, c.fecha_alta, p.email, pf.apellido, pf.nombre, pj.denominacion 
	from persona.cliente c inner join persona.persona p on c.id_persona = p.id 
						   left outer join persona.persona_fisica pf on pf.id_persona = p.id
						   left outer join persona.persona_juridica pj on pj.id_persona = p.id 
	where p.email is not null;
									
/*6. Predicado EXISTS
• Recuperar las categorías de productos que tienen al menos un producto asociado.
• Mostrar las marcas que tienen productos con precio mayor a 100.500.
*/
select * 
	from producto.categoria c 
	where exists (select * 
					from producto.subcategoria s inner join producto.categoria c2 
						on s.id_categoria = c2.id
												 inner join producto.producto p 
						on s.id = p.id_subcategoria); 
					
select * 
	from producto.marca m 
		where exists (select * 
						from producto.producto p where p.precio_unitario > 100500);

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-------------------------------FUNCIONES AGREGADAS---------------------------------

/*1. Funciones Agregadas Básicas
• Obtener el promedio del monto facturado por mes, utilizando la fecha de la factura
para agrupar y calcular el promedio del campo total en la tabla factura.

• Mostrar la cantidad total (COUNT) de clientes registrados.

• Recuperar el precio mínimo (MIN) y máximo (MAX) de los productos por marca.
Mostrar y ordenar por descripción de la marca.

• Mostrar la sumatoria (SUM) de todas las ventas registradas.
*/
select to_char(fecha, 'YYYY-MM') as mes, avg(total) as promFacturado
	from venta.factura f 
	group by to_char(fecha, 'YYYY-MM');
					
select count(*) from persona.cliente c;

select m.descripcion as marca, min(precio_unitario) as precioMinimo, max(precio_unitario) as precioMaximo
	from producto.producto p inner join producto.marca m on p.id_marca = m.id
	group by m.descripcion 
	order by m.descripcion;

select sum(total) from venta.factura f;

-----------------------------Subconsultas-------------------------------------
/*1. Subconsultas Anidadas
• Mostrar los productos cuyo precio sea mayor al precio promedio de todos los
productos.

2. Subconsultas Correlacionadas
• Recuperar las marcas que tienen más productos definidos que la marca "Adata".

• Contar las facturas de venta, cuyo monto sea mayor que el promedio por factura del
mes. Mostrar año, mes y cantidad de facturas.

• Mostrar los nombres de todas las marcas que tengan una cantidad de productos
definida mayor a 15.
*/

select avg(precio_unitario) from producto.producto;

-- Precio a superar 100502.494505494505

select * 
	from producto.producto p 
		where p.precio_unitario > (select avg(precio_unitario) from producto.producto );

select count(*)
	from producto.marca m inner join producto.producto p 
		on m.id = p.id_marca 
	where m.descripcion like '%Adata%';
	
select * 
	from producto.marca m 
	where (select count(*) from producto.producto p where m.id = p.id_marca)
		> (select count(*) from producto.marca m2 inner join producto.producto p2 on m2.id = p2.id_marca 
			where m2.descripcion = 'Adata');
			
select to_char(fecha, 'YYYY-MM') as fecha, count(*) as cantidad
	from venta.factura f 
	where f.total > (select avg(total)
						from venta.factura f2 where to_char(f.fecha, 'YYYY-MM') = to_char(f2.fecha, 'YYYY-MM'))
	group by to_char(fecha, 'YYYY-MM')
	order by to_char(fecha, 'YYYY-MM');

select m.descripcion as marca
	from producto.marca m
	where 15 < (select count(*)
					from producto.producto p where p.id_marca = m.id)
	order by m.descripcion;
	
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-------------------------------JOINs-----------------------------------------------

/*1. Equidistantes
• Recuperar el nombre de las marcas y los productos de cada una, utilizando un JOIN.
Mostrar las columnas de ambos (nombre_marca, nombre_producto).

• Mostrar los productos y sus categorías, pero limitando la salida a los productos con
precios mayores a 100.500.
*/


/*2. Con Condiciones
• Recuperar los productos y sus respectivas categorías, mostrando solo aquellos cuyo
precio esté entre 100000 y 100500. Si los productos no están categorizados incluirlos
de todos modos.
*/

/*3. No Equidistantes (Theta Join)
• Recuperar los productos cuyo precio sea mayor al precio de otra marca (utilizando un
join con condición).
*/

/*4. Join de varias tablas
• Mostrar los productos, sus marcas, y las categorías a las que pertenecen, utilizando
un join de más de dos tablas.
*/

/*5. Joins Externos
• Recuperar todas las marcas y sus productos, incluyendo aquellas marcas que no
tienen productos asociados (LEFT OUTER JOIN).*/
