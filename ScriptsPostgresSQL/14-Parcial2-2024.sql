/*Ejercicio 1: Actualización de precios
Ajuste de precios de productos de un proveedor específico.
Se requiere aumentar en un 15% el precio_unitario de todos los productos asociados a un proveedor cuyo codigo es dado como parámetro. 
Escribir una consulta de UPDATE que permita realizar este ajuste en la tabla producto.

Ampliación sugerida:
Codificar un batch en PostgreSQL que realice el ajuste de precios indicado. Declarar una variable para asignar
el código del proveedor y agregar manejo de errores para hacer el proceso más seguro y controlado.*/

do 
$$
	declare 
		id_proveedor_actualizar;
	begin
		update venta.producto 
			set precio_unitario = precio_unitario * 1.15
			from venta.producto p inner join venta.proveedor pr
			where p.id_proveedor = pr.id
					and pr.id = id_proveedor_actualizar;
		
		raise notice 'Actualizacion exitosa de precios en productos del proveedor: %', id_proveedor_actualizar;

		exception
			when others then 
				-- Mensaje de error
				raise notice 'Ha ocurrido un error al actualizar los precios de los prod del proveedor: %', id_proveedor_actualizar;
	end;
$$;


/*Ejercicio 2: Consulta de ventas por sucursal
Escribir una consulta SQL que muestre el total de ventas por cada sucursal, ordenado de mayor a menor. La
consulta debe devolver los siguientes datos:

• código de la sucursal
• nombre o descripción de la sucursal.
• nombre de la provincia y nombre de la localidad en la que se encuentra la sucursal. Si la sucursal no
tiene una localidad asignada, debe mostrar "Provincia desconocida" y "Localidad desconocida"
• total de ventas

Las sucursales con mayor facturación deben aparecer primero. Considerar únicamente facturas
confirmadas.

La consulta debe implementarse en SQL estándar en una consulta simple, sin el uso de funciones,
procedimientos, cursores ni otros elementos avanzados.*/

select s.codigo as codSucursal,
	   s.descripcion as nomSuc, 
	   case 
	   		when s.id_localidad is not null then l.descripcion
	   		when s.id_localidad is null then 'Localidad desconocida' --Puede ser reemplazado por coalesce el case completo
	   end as localidad,
	   case 
	   		when l.id_provincia is not null then p.descripcion
	   		when l.id_provincia is null then 'Provincia desconocida' --Puede ser reemplazado por coalesce el case completo
	   end as provincia,
	   coalesce(sum(f.total), 0) as totalVentas
	   
	   from persona.sucursal s left join persona.empleado e on s.id = e.id_sucursal 
	   						   inner join persona.localidad l on s.id_localidad = l.id 
	   						   inner join persona.provincia p on l.id_provincia = p.id 
	   						   left join venta.factura f on e.id = f.id_empleado 
	   where f.fecha is not null
	   group by s.id, s.descripcion, p.descripcion, l.descripcion, l.id_provincia
	   order by 5 desc;
	   


/*Ejercicio 3: Vista para DW
Crear una vista llamada vista_facturacion_dw que permita denormalizar, para su uso en un entorno de data
warehousing, las tablas factura y factura_detalle.
Cada fila de esta vista debe representar un detalle de la factura como un evento individual, e incluir las
siguientes columnas:

• código del cliente
• número de la factura
• año, mes y día de la fecha de facturación
• total facturado
• codigo del producto
• cantidad vendida
• precio unitario del producto
• costo del producto

La vista debe incluir únicamente los datos de ventas realizadas después del año 2021. Considerar únicamente facturas confirmadas. 
Toda esta información debe estar consolidada en una sola fila por cada producto vendido en una factura.
*/
	  
	  
