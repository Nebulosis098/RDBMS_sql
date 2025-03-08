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
• total_facturado_top3: Total facturado por los tres primeros vendedores del ránking en ese año.
total_facturado_resto: Total facturado por el resto de los vendedores en ese año.
Los resultados deben estar ordenados por año de forma ascendente.*/




-- Pseudocode for the required query

-- Define the main query structure
SELECT 
    year, 
    SUM(total_facturado_top3) AS total_facturado_top3, 
    SUM(total_facturado_resto) AS total_facturado_resto
FROM (
    -- For each of the last three years
    FOR each year in (current year - 1, current year - 2, current year - 3)
    DO
        -- Calculate total facturado for top 3 employees
        SELECT 
            year,
            SUM(monto_total) AS total_facturado_top3,
            0 AS total_facturado_resto
        FROM 
            f_calcular_performance_empleados(year)
        WHERE 
            posicion <= 3
        GROUP BY 
            year

        UNION ALL

        -- Calculate total facturado for the rest of the employees
        SELECT 
            year,
            0 AS total_facturado_top3,
            SUM(monto_total) AS total_facturado_resto
        FROM 
            f_calcular_performance_empleados(year)
        WHERE 
            posicion > 3
        GROUP BY 
            year
    END FOR
) AS combined_results
GROUP BY 
    year
ORDER BY 
    year ASC;


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