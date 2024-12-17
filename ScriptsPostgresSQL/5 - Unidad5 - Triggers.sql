-- Generar un Registro de Auditoría al Modificar/Insertar/Actualizar un Producto

create or replace function auditoria_producto() returns trigger 
as $$
	begin
		insert into producto.auditoria_producto(id_producto, tipo_op, fecha)
			values (new.id, tg_op, now());

		return new;
	end;
$$ language plpgsql;

-- Trigger asociado
create trigger tgr_auditoria_producto
after insert or update or delete
on producto.producto 
for each row 
execute procedure auditoria_producto();

---------------------------------------------------------------------------------------------------------------------------------------
--  Calcular el Total de Factura cada vez que se Inserta/Modifica/Borra en “factura_detalle”

create or replace function actualizar_total_factura()
returns trigger
language plpgsql
as $$
	begin
		update venta.factura 
			set total = (select sum(fd.precio_unitario * fd.cantidad) 
							from venta.factura_detalle fd 
							where fd.id_factura = new.id_factura)
			where id = new.id_facura;

			return new;
	end;
$$;

-- Trigger asociado
create trigger tgr_actualizar_total_factura
after insert or update or delete 
on venta.factura_detalle 
for each row 
execute procedure actualizar_total_factura();


---------------------------------------------------------------------------------------------------------------------------------------
-- Manejo de ejecucion e informacion en un trigger NEW and OLD

-- Ejemplo de trigger por cada fila (FOR EACH ROW): Este tipo de activación se utiliza cuando se desea manejar cada fila afectada de manera individual.

create or replace function auditoria_producto_fila()
returns trigger 
language plpgsql
as $$
	begin
		-- Insertamos en una tabla de auditoria que se supone existente, los datos de la operacion realizada segun su tipo
		-- Insercion
		if tg_op = 'INSERT' then
			insert into producto.auditoria_producto(id_producto, operacion, fecha)
				values (new.id, 'INSERT', now());
		-- Actualizacion
		else if tg_op = 'UPDATE' then 
			insert into producto.auditoria_producto(id_producto, operacion, fecha)
				values (new.id, 'UPDATE', now());
		-- Borrado
		else if tg_op = 'DELETE' then 
			insert into producto.auditoria_producto(id_producto, operacion, fecha)
				values (new.id, 'DELETE', now());
		end if;

		return new;
	end;
$$;

-- Trigger asociado
create trigger tgr_auditor_producto_fila
after insert or update or delete
on producto.producto
for each row
execute procedure auditoria_producto_fila();





