/*
La función f_calcular_performance_empleados(anio) calcula la capacidad de ventas de los empleados basado en el monto total 
facturado durante un año. Está codificada de esta manera:

CREATE OR REPLACE FUNCION _calcular_performance_empleados (p_anio INTEGER)
ranking INTEGER, - Posición: 1 para el que mas facturó, 2 para el segundo y asi sucesivamente.
apellido_nombre TEXT, total_facturado NUMERIC(38, 2), cantidad_facturas INTEGER, promedio_facturacion NUMERIC(38, 2)

a. Utilizando la función _calcular_performance_empleados() codificar una consulta SQL que muestre los datos de los tres 
primeros empleados del ranking para cada uno de los últimos tres años (a partir del año anterior al actual).
La salida debe incluir las columnas: año, ranking, apellido_nombre, total_facturado y una columna adicional llamada resaltar
que contenga un asterisco (*) si el total_facturado es mayor a 500.000; en caso contrario, debe estar vacía. 
Los resultados deben ordenarse por año (ascendente) y ranking (ascendente).*/

select * from f_calcular_performance_empleados(2022);

select extract(year from current_date) - 1;

select * from f_calcular_performance_empleados(2022) limit 3;

select extract(year from current_date) - 1 as anio, 
	   pe.posicion as Ranking,
	   pe.apenom as Apellido_Nombre,
	   pe.monto_total as Total_Facturado,
	   case when pe.monto_total > 500000 then '*' else '' end as Resaltar
from f_calcular_performance_empleados(cast(extract(year from current_date) - 1 as integer)) pe
where pe.posicion <= 3
union all
select extract(year from current_date) - 2 as anio, 
	   pe.posicion as Ranking,
	   pe.apenom as Apellido_Nombre,
	   pe.monto_total as Total_Facturado,
	   case when pe.monto_total > 500000 then '*' else '' end as Resaltar
from f_calcular_performance_empleados(cast(extract(year from current_date) - 2 as integer)) pe
where pe.posicion <= 3
union all
select extract(year from current_date) - 3 as anio, 
	   pe.posicion as Ranking,
	   pe.apenom as Apellido_Nombre,
	   pe.monto_total as Total_Facturado,
	   case when pe.monto_total > 500000 then '*' else '' end as Resaltar
from f_calcular_performance_empleados(cast(extract(year from current_date) - 3 as integer)) pe
where pe.posicion <= 3
order by anio, Ranking;

/*b. Utilizando la función _calcular_performance_empleados(), crear una consulta SQL que muestre, para los últimos tres
años (a partir del año anterior al actual), el total facturado por los primeros tres vendedores del ránking y el total
facturado por el resto de los vendedores. La salida debe incluir las siguientes columnas:

año: Año de las ventas.
total_facturado_top3: Total facturado por los tres primeros vendedores del ránking en ese año.
total_facturado_resto: Total facturado por el resto de los vendedores en ese año.

Los resultados deben estar ordenados por año de forma ascendente.*/

select extract(year from current_date) - 1 as anio, 
       sum(case when pe.posicion <= 3 then pe.monto_total else 0 end) as total_facturado_top3,
       sum(case when pe.posicion > 3 then pe.monto_total else 0 end) as total_facturado_resto
from f_calcular_performance_empleados(cast(extract(year from current_date) - 1 as integer)) pe
union all
select extract(year from current_date) - 2 as anio, 
       sum(case when pe.posicion <= 3 then pe.monto_total else 0 end) as total_facturado_top3,
       sum(case when pe.posicion > 3 then pe.monto_total else 0 end) as total_facturado_resto
from f_calcular_performance_empleados(cast(extract(year from current_date) - 2 as integer)) pe
union all
select extract(year from current_date) - 3 as anio, 
       sum(case when pe.posicion <= 3 then pe.monto_total else 0 end) as total_facturado_top3,
       sum(case when pe.posicion > 3 then pe.monto_total else 0 end) as total_facturado_resto
from f_calcular_performance_empleados(cast(extract(year from current_date) - 3 as integer)) pe
order by anio;

/*Ejercicio 2: Jerarquía de empleados
a. Codificar una consulta SQL que permita identificar los empleados que se desempeñan como jefes. Mostrar su código, nombre 
y apellido y la cantidad de empleados que tienen a su cargo. Ordenar por código.*/

select e.codigo_empleado as CodigoEmpleado,
       pf.apellido || ', ' || pf.nombre as apenom,
       count(distinct e2.id) as CantidadEmpleadosACargo
from persona.empleado e
    inner join persona.persona_fisica pf
        on e.id_persona_fisica = pf.id
    inner join persona.empleado e2
        on e.id = e2.id_jefe
where e.id_jefe is null
group by 1, 2
order by 1;

/*b. Crear una consulta SQL que muestre todos los empleados incluyendo, para aquellos que tienen un jefe, el código y nombre completo 
del jefe directo. Para los empleados que no tienen jefe, la columnas correspondientes al jefe debe mostrarse con NULL. La salida 
debe incluir las siguientes columnas:

codigo: Código del empleado.
nombre: Nombre completo del empleado (nombre y apellido concatenados).
codigo_jefe: Código del jefe directo (o NULL si el empleado no tiene jefe).
nombre_jefe: Nombre completo del jefe directo (nombre y apellido concatenados).

Los resultados deben estar ordenados de forma ascendente por el código del empleado.*/

SELECT e.codigo_empleado AS codigoEmpleado,
	   pf.apellido || ', ' || pf.nombre as apeNom,
	   e.id_jefe as codJefeDirecto
	   pf2.apellido || ', ' || pf2.nombre as apeNomJefeDirecto,
	from persona.empleado e 
			inner join persona.persona_fisica pf on e.id_persona_fisica = pf.id 
			inner join persona.persona_fisica pf2 on e.id_jefe = pf2.id 
	group by 1
	order by 1;

/*Ejercicio 3: Agregado de controles
a. Crear un trigger en PostgreSQL para la tabla empleado que impida la actualización de una relación de dependencia si el jefe ya 
tiene más de 3 empleados que dependen de él. El control debe realizarse tanto al registrar nuevos empleados como al actualizar 
información.*/

create or replace function t_maximos_acargo()
returns trigger 
language plpgsql
as 
$function$
begin	
    if (select count(*) from persona.empleado where id_jefe = new.id_jefe) > 3 then
        raise exception 'El jefe ya tiene 3 empleados a cargo';
    end if;
    return new;

end
$function$;


create trigger tgr_maximos_acargo
before insert or update on persona.empleado 
for each row 
execute procedure t_maximos_acargo();

/*b. Dada la tabla empleado, agregar una restricción declarativa que impida que un empleado se tenga a si mismo como jefe. Sí un 
empleado no tiene jefe, la restricción no debe aplicar y el registro debe considerarse válido.*/

alter table persona.empleado add constraint tu_propio_jefe check(id <> id_jefe or id_jefe is null);

/*Ejercicio 4: Bloqueo optimista
a. Agregar columna version:
Añadir a las tablas venta.factura y venta.factura_estado una columna denominada version de tipo entero, de ingreso obligatorio. 
Esta columna debe registrar la cantidad de actualizaciones realizadas en cada fila. El valor inicial declarado por defecto debe 
ser 0 para las inserciones y se incrementará con cada actualización. Considerar que la tabla puede tener filas previamente 
cargadas y no se quieren perder.*/



/*b. Ejemplo de inserción en factura y factura_estado:
Insertar una nueva factura en estado
"En trámite" utilizando secuencias para numerar los ids. Actualizar la columna
id _estado_actual de la tabla venta.factura para reflejar el estado actual.*/


/*c. Ejemplo de actualización del estado:
Cambiar el estado de la factura insertada en el punto anterior a "Confirmado".
estado actual de la factura.*/


/*d. Script para actualizar el total de la factura:
Implementar un script en PostgreSQL que:
• Inicie transacción.
• Lea el valor actual del total de la factura en una variable.
Aumente el total en un 10%.
Actualice con el valor calculado los datos de la factura, verificando que no haya ocurrido otra actualización durante la transacción. Si hubiera inconsistencias, se debe cancelar la transacción.
• Confirmar la transaccion.*/

-----PRÁCTICA PARA GENERAR LA FUNCIÓN QUE VIENE DADA EN EL ENUNCIADO EJERCICIO 1-----
-- DROP FUNCTION public.f_calcular_performance_empleados(int4);

CREATE OR REPLACE FUNCTION public.f_calcular_performance_empleados(anio integer)
 RETURNS TABLE(posicion bigint, apenom text, sucursal text, monto_total numeric, cantidad_fact bigint, promedio_factura numeric)
 LANGUAGE plpgsql
AS $function$
begin

	PERFORM setval('perf_empleados_seq', 1, false);
	
	return query
	select -- nextval('perf_empleados_seq') as posicion,
           ROW_NUMBER() OVER (ORDER BY sum(f.total) DESC) AS posicion, --Copilot suggestion
		   pf.apellido || ', ' || pf.nombre as apenom,
		   s.descripcion || ', ' || l.descripcion as sucursal,
		   sum(f.total) as monto_total,
		   count(distinct f.id) as cantidad_fact,
		   sum(f.total)/count(distinct f.id) as promedio_factura
	from persona.empleado e inner join venta.factura f 
		 						on e.id = f.id_empleado
		 					inner join persona.persona_fisica pf
								on e.id_persona_fisica = pf.id
							inner join persona.sucursal s
								on e.id_sucursal = s.id
							inner join persona.localidad l
								on s.id_localidad = l.id
	where f.fecha is not null and extract(year from f.fecha) = anio
	group by 2, 3
	order by monto_total desc;
end;
$function$
;