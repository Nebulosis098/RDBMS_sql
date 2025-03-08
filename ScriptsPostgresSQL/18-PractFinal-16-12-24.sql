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

/*b. Utilizando la función _calcular_performance_empleados(), crear una consulta SQL que muestre, para los últimos tres
años (a partir del año anterior al actual), el total facturado por los primeros tres vendedores del ránking y el total
facturado por el resto de los vendedores. La salida debe incluir las siguientes columnas:
año: Año de las ventas.
• total_facturado_top3: Total facturado por los tres primeros vendedores del ránking en ese año.
total_facturado_resto: Total facturado por el resto de los vendedores en ese año.
Los resultados deben estar ordenados por año de forma ascendente.*/


-----PRÁCTICA PARA GENERAR LA FUNCIÓN QUE VIENE DADA EN EL ENUNCIADO-----
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



create or replace function f_calcular_performance_empleados(anio integer)
returns table (
    ranking int,
    apellido_nombre VARCHAR(32),
    sucursal_localidad VARCHAR(64),
    total_facturado numeric(38, 2),
    cantidad_facturas int,
    promedio_facturado numeric(38, 2)
)
language plpgsql
as
$funcion$

begin 

    
end
$function$;