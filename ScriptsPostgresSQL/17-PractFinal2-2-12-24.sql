---------------------------------EJERCICIO 1--------------------------------
--Inciso A
-- Creamos la secuencia para el ranking
create sequence rank_empleados_2 start with 1 increment by 1;

-- Borramos funcion
drop function f_calcular_performance_empleados2(numeric);

-- Creamos la funcion
create or replace function f_calcular_performance_empleados2(anio numeric)
returns table(posicion bigint,
			  apenom text,
			  sucurssal text,
			  total_facturado numeric(38,2),
			  cant_total_facturas bigint,
			  promedio_facturado_xFactura numeric(38,2)
)
language plpgsql
as
$function$
begin  
	return query

	select row_number() over (order by sum(f.total) desc) as posicion,
		   coalesce(pf.apellido || ', ' || pf.nombre, 'Desconocido') as apenom,
		   coalesce(s.descripcion || ', ' || l.descripcion, 'Sucursal desconocida') as sucursal,
		   sum(f.total) as total_facturado,
		   count(distinct f.id) as cant_total_facturas,
		   sum(f.total) / count(distinct f.id) as promedio_facturado_xFactura
		from persona.empleado e 
				inner join persona.persona_fisica pf on e.id_persona_fisica = pf.id 
				inner join persona.sucursal s on s.id = e.id_sucursal 
				inner join persona.localidad l on s.id_localidad = l.id 
				inner join venta.factura f on f.id_empleado = e.id 
		where extract(year from f.fecha) = anio
		group by e.id, 2, 3
		order by 4 desc;

end
$function$

-- Testing
select * from f_calcular_performance_empleados2(2022);


-------- Inciso B

select * from f_calcular_performance_empleados2(cast(extract(year from current_date) - 2 as integer));

-------- Inciso C
select * 
	from f_calcular_performance_empleados2(cast(extract(year from current_date) - 2 as integer)) 
	where apenom like '%Garcia%';

-------- Inciso D
/*Codificar un script que, utilizando la función f_calcular performance_empleados(anio), calcule y almacene en una 
tabla denominada top3_empleados _anual los tres empleados con mayor facturación anual para cada año en el que se 
hayan confirmado ventas. El script debe identificar todos los años en los que existan ventas confirmadas y, para 
cada uno de ellos, calcular el ránking de los primeros tres empleados.

El script debe:
- Eliminar el contenido existente de la tabla top3_empleados _anual al inicio del script.
- Insertar en la tabla los resultados de los tres empleados con mayor facturación anual para cada año.
- Devolver los datos almacenados en la tabla mediante una consulta. Ordenar por año y número en el ránking.

Luego de la ejecución del script la tabla debe quedar disponible para posteriores consultas o usos que se le quieran dar.
Se asume que la tabla tops empleados anual ya existe en la base de datos con la estructura necesaria para almacenar los resultados.*/

select distinct(extract(year from f.fecha)) from venta.factura f; 

select * from f_calcular_performance_empleados2(anio) limit 3;

do
$$
declare 
	anio numeric;
	cursorAnio cursor for select distinct(extract(year from f.fecha)) from venta.factura f; 
begin
	open cursorAnio;

	delete * from 

	loop
		fetch next from cursorAnio into anio
		select * from f_calcular_performance_empleados2(cast(anio as integer)) limit 3;

	end loop;
	close cursorAnio
end
$$;

-------- Inciso E
-- e. Codificar un script que muestre el empleado #1 del ránking ordenado por año, utilizando la tabla del ejercicio d.


---------------------------------EJERCICIO 2--------------------------------
/*
a Las tablas presentadas en el ejercicio 1 no tienen ningún indice creado. ¿Sobre qué columnas recomendarías crear indices para optimizar los 
joins y mantener la integridad referencial?*/

create index id_suc_empleado on persona.empleado(id_sucursal);
-- etc... Todas las fk que no son AK (Por defecto ya tienen index) y columnas que resulten utiles para filtrar busquedas (fechas x ejemplo).

/*b. Los usuarios han reportado que las consultas relacionadas con facturas cuyo estado actual es confirmada ("OK*) están demorando mucho 
 * en dar respuesta. Se supone que la consulta principal codificada en las aplicaciones es:

SELECT f.*
	FROM venta. factura f
		JOIN venta.factura_estado fe ON f.id_estado_actual = fe.id
	WHERE fe.tipo estado = 'oK';

Generalmente también agregan un criterio del tipo: f. fecha_registro ›- yyyy-mm-dd.
¿Recomendaría la creación de algún indice adicional, además de los mencionados en el punto a, para mejorar el rendimiento de esta consulta? 
Escribir los comandos create index y justificar la respuesta*/

--Si, en tipo estado y en la fecha.

---------------------------------EJERCICIO 3--------------------------------
/*La tabla factura se relaciona con la tabla promocion. La tabla promoción tiene un atributo "descuento", que es un valor entre O y 100, 
que autoriza a aplicar descuentos sobre las facturas. Este descuento, se calcula sobre el "total" de la factura y queda expresado en pesos en la
columna "descuento" (este seria el descuento aplicado).

Se requlere coditicar un trigger en Postgresql que impida la insercion de filas en factura, si el descuento excede al importe autorizado seguin
la tabla promocion.
Ejemplo: Si la tabla promocion existe una fila que indica "Venta de contado en efectvo" con un descuento del 20%, y se ingresa una facura
por $1.200,000,-, que referencia a esta promoción, el total de descuento no puede exceder los $240.000,-
Si no hay promoción asociada a la factura, no se deben aceptar descuentos.*/

create or replace function f_conrolar_descuento()
returns trigger
language plpgsql
as 
$function$
declare 
	descuento_permitido numeric(38,2);
begin 
	
	if new.id_promocion is not null then
		descuento_permitido := select new.total * pr.descuento
								from venta.promocion pr
								where pr.id = new.id_promocion;
		else 
			descuento_permitido := 0;
	end if;

	
	if (new.id_promocion is null and new.descuento <> 0) then 
		raise exception 'No es posible aplicar descuento en esta factura.';
		rollback;
	else if (new.descuento > descuento_permitido )
		raise exception 'Error: El descuento no puede ser superior a%' || ' $' || descuento_permitido;
		rollback;
	else 
		return new;
	
	end if;

end
$function$

-- Creamos el trigger
create trigger tgr_controlar_descuento
before insert on venta.factura
for each row
execute f_controlar_descuento();

---------------------------------EJERCICIO 4--------------------------------
/*Codificar una herramienta para facilitar la administración de permisos en la base de datos "Gestión". 
 * La herramienta debe permitir conceder o revocar privilegios a usuarios según el tipo de aplicación con la que vayan a interactuar. 
 * En esta base de datos, conviven tres aplicaciones con los siguientes requerimientos de acceso:

App de RRHH: Permite insertar, borrar y actualizar datos en todas las tablas del esquema persona
App de Ventas: Solo puede consultar las tablas del esquema persona. Puede insertar, borrar y actualizar datos en las tablas de los esquemas producto y venta.
App de Compras: Solo puede consultar las tablas del esquema persona. Puede insertar, borrar y actualizar datos en las tablas del
esquema producto y compra.

El script debe recibir como parámetros:

v_usuario: nombre del usuario al que se le actualizaran los permisos.
v_accion: indicación de si se deben conceder ('Conceder) o revocar (Revocar) permisos.
v_tipo_app: tipo de aplicación con la que interactuará el usuario (RRHH", 'VENTAS', 'COMPRAS).

El script debe leer las tablas del diccionario de datos para identificar las tablas en cada esquema y ejecutar las instrucciones SQL 
para conceder o revocar los permisos.

Incluir un ejemplo de como se invoca al script/función/procedimiento almacenado.*/

create or replace function f_administrar_permisos(v_usuario text, v_accion text, v_tipo_app text)
returns void
language plpgsql
as $function$
	declare 
		cursorTablas cursor for select * from information_schema.tables;
		tabla record;
	begin
		open cursorTablas;
		loop
			fetch next from cursorTablas into tabla;
					-- Tipo de aplicacion RRHH
					if (v_tipo_app = 'RRHH') then
						if (v_accion like '%Conceder%') then
							execute 'grant insert, update, delete on ' || tabla.table_name || ' to ' || v_usuario;
						else 
							execute 'revoke insert, update, delete on ' || tabla.table_name || ' from ' || v_usuario;
						end if;
					end if;
					-- Tipo de aplicacion VENTAS
					if (v_tipo_app = 'VENTAS') then
						if (v_accion like '%Conceder%') then
							if (tabla.table_schema = 'persona') then
								execute 'grant select on ' || tabla.table_name || ' to ' || v_usuario;
							elsif (tabla.table_schema in ('producto', 'venta')) then
								execute 'grant insert, update, delete on ' || tabla.table_name || ' to ' || v_usuario;
							end if;
						else 
							if (tabla.table_schema = 'persona') then
								execute 'revoke select on ' || tabla.table_name || ' from ' || v_usuario;
							elsif (tabla.table_schema in ('producto', 'venta')) then
								execute 'revoke insert, update, delete on ' || tabla.table_name || ' from ' || v_usuario;
							end if;
						end if;
					end if;
					-- Tipo de aplicacion COMPRAS
					if (v_tipo_app = 'COMPRAS') then
						if (v_accion like '%Conceder%') then
							if (tabla.table_schema = 'persona') then
								execute 'grant select on ' || tabla.table_name || ' to ' || v_usuario;
							elsif (tabla.table_schema in ('producto', 'compra')) then
								execute 'grant insert, update, delete on ' || tabla.table_name || ' to ' || v_usuario;
							end if;
						else 
							if (tabla.table_schema = 'persona') then
								execute 'revoke select on ' || tabla.table_name || ' from ' || v_usuario;
							elsif (tabla.table_schema in ('producto', 'compra')) then
								execute 'revoke insert, update, delete on ' || tabla.table_name || ' from ' || v_usuario;
							end if;
						end if;
					end if;
		end loop;
		close cursorTablas;
	end
$function$;





