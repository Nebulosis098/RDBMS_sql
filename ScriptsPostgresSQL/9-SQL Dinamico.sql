--------------------------------------------------------EJEMPLOS DE USO-----------------------------------------------------------
-- Se ejecuta con EXECUTE

-- SQL dinamico basico
create or replace function sql_dinamico (nom_tabla varchar, nom_columna varchar)
returns setof bigint --setof permite definir una lista de valores
language plpgsql
as 
$$
	declare
		v_cadena varchar;
	begin
		v_cadena := 'SELECT' || nom_columna || 'FROM' || nom_tabla;
		raise notice 'Ejecutando: %', v_cadena;
		return query execute v_cadena;
	end;
$$;

-- Uso §
select * from sql_dinamico('venta.factura', 'id_cliente');

-- Generacion dinamica de columnas cuando no conoces el total de columnas.
--necesitamos generar una salida donde las columnas de mes son variables en función de un
--rango (por ejemplo desde marzo-2022 hasta junio-2023)


--IMPORTACION DE DATOS DESDE ARCHIVO
--Función en PostgreSQL para importar marcas. La ubicación del
--archivo es variable; el separador también es un argumento de la función.

create or replace function importar_marcas_CSV (ruta_archivo text, separador char default ',') --Separador por parametro, evitamos inyeccion sql
returns table (
	total_registros integer,
	marcas_nuevas integer
)	
as 
$$
	declare
		registro record;
		contador_marcasa := 0;
		sql_copy text;
		max_codigo integer;
	begin
		-- Creamos una tabla temporal con campos de texto como columnas
		create temp table tmp_marcas_csv (col1 text, col2 text, col3 text, col4 text);

		-- Construimos y ejecutamos la sentencia COPY para traernos los datos a la tabla temporal desde el archivo
		sql_copy := format('copy temp_marcas_csv from %l with (format csv, delimiter %l, header)', ruta_archivo, separador);
		execute sql_copy;

		-- Creamos otra tabla temporal con solo la columna 'marca' que necesitamos
		create temp table tmp_marcas as select col4 as marca from temp_marcas_csv;

		-- Obtenemos el valor maximo actual de 'codigo' en la tabla de marcas
		select coalesce(max(codigo), 0) into max_codigo from producto.marca; 
		
		-- Recorremos cada registro e insertamos en la tabal de marca si no existe
		
		--FALTA COMPLETAR

	end;
$$;