--Procedimiento en PostgresSQL para agregar cliente
create or replace procedure agregar_cliente(
	nombre_cliente varchar,
	direccion_cliente varchar,
	email_cliente varchar
)

language plpgsql
as $$
 begin
	insert into persona.persona(tipo, codigo, fecha_alta, email, domicilio)
		values('FISICA', nextval('persona.persona_sequence'), now(), email_cliente, direccion_cliente);

	--Obtener el id generado para la persona y crear el cliente
	insert into persona.cliente(id_persona, codigo, fecha_alta)
		values(currval('persona.persona_sequence'), nextval('persona.persona_sequence'), now());
 end;
$$;

--Para ejecutar el procedure
call agregar_cliente('Juen Perez', 'Direccion Falsa 123', 'jperez@hotmail.com');


------------------------------------------------------------------------------------------------------------------------
--Funcion para calcular el total de ventas de un cliente
create or replace function total_ventas_cliente(bigint)
returns numeric 
language plpgsql
as $$
declare
	total_retornar numeric;
begin
	select sum(f.total) into total_retornar
		from venta.factura f
		where f.id_cliente = id_cliente;

	return coalesce(total_retornar, 0);
end;

$$;

--Para usar la funcion
select total_ventas_cliente(47);