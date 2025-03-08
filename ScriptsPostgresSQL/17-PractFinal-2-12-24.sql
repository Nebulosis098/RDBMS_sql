---------------------------------EJERCICIO 1--------------------------------
-- Inciso A --

select * from venta.factura f;

-- Creamos una sequence para la posicion en el ranking 
create sequence perf_empleados_seq start with 1 increment by 1;

drop function f_calcular_performance_empleados(integer);

create or replace function f_calcular_performance_empleados(anio integer)
returns table (
	posicion bigint,
	apenom text,
	sucursal text,
	monto_total numeric(38, 2),
	cantidad_fact bigint,
	promedio_factura numeric(38, 2)
) 
language plpgsql
as 
$$
begin

	 PERFORM setval('perf_empleados_seq', 1, false);
	
	return query
	select nextval('perf_empleados_seq') as posicion,
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
	order by 4 desc;
end;
$$;

-- Probamos a ver que hace
select * from f_calcular_performance_empleados(2022);

---- Inciso B ----
select * from f_calcular_performance_empleados(extract(year from current_date) - 1);

---- Inciso C ----
select * from f_calcular_performance_empleados(2023)
	where apenom like '%Garcia%';

---------------------------------EJERCICIO 2----------------------------------
-- Consulta creada en las app's que genera conflicto
select f.*
from venta.factura f inner join venta.factura_detalle fd 
						on f.id = fd.id_factura
where fd.cantidad > 1;

---- Inciso B ----
create index idx_tipo_estado on venta.factura_estado (tipo_estado) where tipo_estado = 'OK';
create index 


---------------------------------EJERCICIO 3----------------------------------
-- Creamos la funcion asociada al trigger
create or replace function verifica_descuento_factura()
returns trigger
language plpgsql
as $$
	declare 
		importe_autorizado numeric(38,2);
	begin 
		-- Si hay no hay promo asociada, no aceptamos descuentos
		if (new.id_promocion is null) then 
			importe_autorizado := 0;
		end if;

		-- Calculamos el importe autorizado contemplando que tiene descuento asignado, caso contrario se asigna cero
		if (new.id_promocion is not null) then
			select coalesce(new.total * pr.porcentaje_descuento, 0) into importe_autorizado
				from venta.promocion pr
				where pr.id = new.id_promocion;
		end if; 

		-- Controlamos si es valido o no
		if (new.descuento <= importe_autorizado) then 
			insert into venta.factura (id, version, numero, id_empleado, id_promocion, id_forma_pago, fecha, descuento, total, id_cliente)
				values (new.id, new.version, new.numero, new.id_empleado, new.id_promocion, new.id_forma_pagom, new.fecha, new.descuento, new.total, new.id_cliente);
			commit transaction;
		else 
			raise notice 'El monto de descuento es superior al importe autorizado para aplicar dicho desc :(';
			rollback transaction;
		end if;
	end;
$$;


-- Trigger asociado
create trigger tgr_verifica_descuento
before insert 
on venta.factura 
for each row 
execute procedure verifica_descuento_factura();

-------------------------------------------------EJERCICIO 4----------------------------------------------------
create or replace procedure administrar_permisos(v_usuario text, v_accion text, v_tipo_app text)
returns void
language plpgsql
as $$
	declare 
		-- Para traernos las tablas de cada esquema con information_schema
		select * from information_schema.tables;
	begin
		case v_tipo_app
			when 'RRHH' then
				if(v_accion like '%Conceder%') then
					grant insert on  to v_usuario;
	end;
$$;





