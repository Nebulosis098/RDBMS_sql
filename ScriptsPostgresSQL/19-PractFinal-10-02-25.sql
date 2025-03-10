/*Ejercicio 1:
Codificar una función en PostgreSQL. denominada f_productos_mas_vendidos() que permita obtener los productos que figuran en más 
facturas, considerando solamente aquellos que están presentes mas de "n" veces (siendo n un parámetro de la función). La salida de la
función deberá retornar registros del tipo: (producto integer, cantidad integer);*/

drop function f_productos_mas_vendidos(minimoN integer);

create or replace function f_productos_mas_vendidos(minimoN integer)
returns table(producto varchar(50), cantidad bigint)
language plpgsql
as 
$function$
begin
	return query
	select p.descripcion as producto,
		   count(distinct fd.id_factura) as cantidad
		from producto.producto p 
				inner join venta.factura_detalle fd on fd.id_producto = p.id
	 	group by p.id, p.descripcion
		having count(distinct fd.id_factura) > minimoN
		order by cantidad desc;
	
end
$function$;

select * from venta.factura_detalle fd;
select * from producto.producto p ;

-- Function test
select * from f_productos_mas_vendidos(52);

-----------------------------------------------------------------------------------------------------------------------------------------------------------
/*Ejercicio 2:
Codificar una funcion denominada f_productos_afines() par obtener grupos de tres articulos que aparecen juntos en la misma factura mas veces
considerando un umbral minimo a tener en cuenta a partir del cual se contabilizan. (TABLA EJEMPLO).

En esta salida se utiliza como umbral 5 ocurrencias; de haber menos no se tiene en cuenta esa combinación. Puede verse que hay 37 facturas
que contienen simultaneamente los productos 230, 231 y 233. La salida de la función debe retornar registros de acuerdo con lo mostrado en
la tabla anterior. La función debe tener al umbral como parámetro.*/



select * from f_productos_afines(5);

-- solucion propuesta por COPILOT que hay que revisar que hace

/*
create or replace function f_productos_afines(umbral integer)
returns table(producto1_Id bigint, cant_prod_1 bigint, producto2_Id bigint, cant_prod_1y2 bigint, producto3_Id bigint, cant_prod_1y2y3 bigint)
language plpgsql
as 
$function$
begin 
	return query

	select p1.id_producto as producto1_Id,
		   count(distinct f1.id_factura) as cant_prod_1,
		   p2.id_producto as producto2_Id,
		   count(distinct f2.id_factura) as cant_prod_1y2,
		   p3.id_producto as producto3_Id,
		   count(distinct f3.id_factura) as cant_prod_1y2y3
	from venta.factura_detalle f1
	join venta.factura_detalle f2 on f1.id_factura = f2.id_factura and f1.id_producto < f2.id_producto
	join venta.factura_detalle f3 on f2.id_factura = f3.id_factura and f2.id_producto < f3.id_producto
	join producto.producto p1 on f1.id_producto = p1.id
	join producto.producto p2 on f2.id_producto = p2.id
	join producto.producto p3 on f3.id_producto = p3.id
	group by p1.id_producto, p2.id_producto, p3.id_producto
	having count(distinct f1.id_factura) >= umbral
	order by cant_prod_1y2y3 desc;

end
$function$;
*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------
/*Ejercicio 3:
Codificar los scripts necesarios para agregar a la tabla producto una clave alternativa, conformada por el atributo codigo_nemo varchar(20),
que admita valores nulos. Este atributo representa "códigos nemotécnicos" que se usan para identificar algunos productos, pero no todos los
productos tienen este dato.
Al codificar el script considerar que la tabla tiene registros cargados y no se desean perder.
Implementar una alternativa de restricción de unicidad que pueda implementarse en PostgreSQL y una variante para poder implementarla en
SQL Server.*/

select * from producto.producto p;

alter table producto.producto add column codigo_nemo varchar(20) null;
alter table producto.producto add constraint ak_codigo_nemo unique(codigo_nemo);

-- Testing 
update producto.producto set codigo_nemo = 'NisutaViejoNomas' where id = 79;

-- hay que resolver un issue con una funcion de auditoria que aparentemente la usa un trigger pero no lo encuentro
select * 
	from information_schema
	where table_schema = 'producto' and 
			table_name = 'auditoria_producto';

-----------------------------------------------------------------------------------------------------------------------------------------------------------
/*EJERCICIO 4
Codificar una sentencia SQL simple que permita mostrar la cantidad de facturas por cliente, incluyendo también la cantidad de aquellas
facturas para las que no se haya registrado cliente (en general, las facturas que no referencian clientes son aquellas que se realizan a
"Consumidor Final" ). Para el c a s o d e l a s f a c t u r a s q u e t i e n e n r e g i s t r a d o c l i e n t e , 
m o s t a r e l c o d i g o : p a r a e l c a s o d e f a c t u r a s a c o n s u m i d o r f i n a l
mostrar un "-1" en su lugar.*/

select case when id_cliente is not null then id_cliente else -1 end as codCliente,
	   case when pf.id_persona = c.id_persona then pf.apellido || ', ' || pf.nombre else pj.denominacion end as apenom, 
	   count(distinct f.id) as cantFacturas
	from venta.factura f 
			inner join persona.cliente c on c.id = f.id_cliente 
			inner join persona.persona_fisica pf on pf.id_persona = c.id_persona
			inner join persona.persona_juridica pj on pj.id_persona = c.id_persona 
	group by case when id_cliente is not null then id_cliente else -1 end,
			 case when pf.id_persona = c.id_persona then pf.apellido || ', ' || pf.nombre else pj.denominacion end
	order by cantFacturas desc;


select * from persona.cliente c ;
select id_cliente from venta.factura f;




