--------------------------------------------------------CURSORES-----------------------------------------------------------

create or replace function venta.procesar_factura()
return void
language plpgsql
as $$
	declare 
		factura_cursor cursor for select id, total from venta.factura
			where fecha >= current_date - interval '1 year'; -- se obtiene la fecha a hace un anio hacia atras desde el dia actual (current date)
		v_factura_id bigint;
		v_total numeric(38,2);
	begin	
		-- Abrir el cursor
		open factura_cursor;
		
		-- Iniciar el LOOP
		loop
			-- Fetch
			fetch factura_cursor into v_factura_id, v_total;
			exit when not found;

			raise notice 'Factura ID: %, Total: %', v_factura_id, v_total;
		
		end loop;

		-- Cerramos el cursor 
		close factura_cursor;
	end;
$$;

-- Esta funcion traera todas las filas (facturas) generadas a partir de la fecha actual a la que se llama la funcion.

--------------------------------------------------------USOS DE BATCHES-----------------------------------------------------------
/* Bloques DO en PostgreSQL
Un bloque DO es un contenedor que permite ejecutar código PL/pgSQL en línea sin crear una función almacenada. 
Esto es útil cuando se necesita ejecutar un conjunto de instrucciones o lógica procedural de una vez sin la 
intención de reutilizar el código. */

do
$$
	begin
		insert into persona.provincia (id, version, codigo, descripcion)
			values  (persona.persona_sequence.nextval, 1, 999, 'Provincia Test');
		insert into persona.localidad (id, version, id_provincia, codigo, descripcion, codigo_postal)
			values (persona.persona_sequence.nextval, 1, 999, 999, 'Localida Test', 3000);

		raise notice 'Batch ejecutado con exito.';
	end;
$$;

--------------------------------------------------------ESTRUCTURAS DE CONTROL-----------------------------------------------------------
-- IF THEN ELSE
--Se utilizan dentro de procedimientos almacenados o funciones, o bloques DO (BATCHES)
--Verificar si una localidad esta asignada a una sucursal, sino lo asigna por defecto.

do
$$
	begin
		if not exists (select 1 from persona.sucursal s inner join persona.localidad l on s.id_localidad = l.id) then
			--insertamos porque no existe ni siquiera 1
			insert into persona.surcursal(id, version, codigo, descripcion, domicilio, id_localidad)
				values(nextval('persona.persona_sequence'), 1, 101, 'Nombre sucursal', 'Domicilio sucursal', l.id);
		else 
			raise notice 'La localidad ya esta posee una sucursal asignada'
		end if;
	end;
$$;

-- FOR/WHILE
-- Util para recorrer filas de una consulta. 
-- El siguiente BATCH revisa los subproductos de una determinada subcategoria y actualiza el precio unitario si es menor a un determinado valor.

do
$$
	declare 
		productoX record; -- Record permite almacenar una tupla completa de datos, sin saber cuantas columnas la componen. Luego las accedemos
	begin
		for productoX in (select id, precio_unitario from producto.producto where id_subcategoria = 1)
		loop
			if productoX.precio_unitario < 100 then
				update producto.producto
					set precio_unitario = precio_unitario*1.20
				where id = productoX.id;
			end if;
		end loop;
	end;
$$;

-- Ejemplo de WHILE
-- Incrementamos el precio de un producto en un 5% hasta que su precio supere o alcance un valor especifica, 500USD por ejemplo.

do
$$
	declare
		precio_actual numeric(38,2);
		incremento numeric(38,2) := 0.05; -- Esto esta hardcodeado pero podria ser una variable o directamente multiplicar precio_actual * 1.05.
	begin
		-- Cargamos el precio de un producto a incrementar
		select precio_unitario into precio_actual
			from producto.producto where id = 1;
		-- Generacion del bucle while
		while precio_actual < 500 loop
			precio_actual := precio_actual * (1 + incremento);

			update producto.producto
				set precio_unitario = precio_actual
			where id = 1;

			-- Mostramos el precio actualizado en cada iteracion
			raise notice 'Nuevo precio actualizado a: %', precio_actual;
			end loop;	
		end while;
	end;
$$;


--------------------------------------------------------USO DE SECUENCIAS-----------------------------------------------------------
-- A good practice and usefull to manage primary keys and every unique and incremental field.

-- Creating a sequence
create sequence persona.persona_sequence 
	start with 1 -- Initial value
	increment by 1; -- Incremental gap
	
--------------------------------------------------------MANEJO DE TRANSACCIONES-----------------------------------------------------------
-- Ejemplo de COMMIT y ROLLBACK 

begin transaction;
	-- Primer accion de la transaccion
	update persona.sucursal
		set descripcion = 'Sucursal Actualizada'
	where codigo = 123;
	
	-- Segunda accion de la transaccion
	update persona.cliente
		set fecha_alta = current_date
	where codigo = 456;
	
commit transaction; -- Confirmamos las acciones de la transaccion. 

--  Abrimos otra para ejemplo ROLLBACK

begin transaction; 
	-- Primer accion de la transaccion
	update persona.sucursal
		set descripcion = 'Sucursal Actualizada'
	where codigo = 123;

	-- Segunda accion de la transaccion
	update persona.cliente
		set fecha_alta = current_date
	where codigo = 456;

rollback transaction; -- Revertimos cambios en caso de ERROR

-- Podemos realizar un MANEJO DE ERRORES en transacciones usando bloques BEGIN y EXCEPTION

do
$$ 
	begin
		-- Iniciamos la transaccion
		begin transaction;
			-- Actulizamos la sucursal

			-- Actualizamos el cliente

			-- Si fue todo bien, confirmamos la transaccion
			commit transaction;

		-- Exceptuamos si hay algun error
		exception 
			when others then 
			-- En caso de error, comunicamos y revertimos la transaccion
			raise notice 'Error en la transaccion. Se han revertido los cambios.';
			rollback transaction;
	end;
$$;

--------------------------------------------------------VERIFICAR LOCKS EN TRANSACCIONES EN CURSO-----------------------------------------------------------
-- Usamos la vista del sistema pg_locks

select pg_stat_activity.datname,
	   pg_stat_activity.pid,
	   pg_stat_activity.usename,
	   pg_stat_activity.query,
	   pg_locks.locktype,
	   pg_locks.mode,
	   pg_locks.granted,
	   pg_locks.relation::regclass as locked_table
	   
	   from pg_locks join pg_stat_activity on pg_locks.pid = pg_stat_activity.pid
	   where pg_stat_activity.state = 'active';



