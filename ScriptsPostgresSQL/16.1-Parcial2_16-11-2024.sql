/*
Ejercicio 1: Actualización de precios

Ajuste de precios de productos de un proveedor específico.
Se requiere aumentar en un 15% el precio_unitario de todos los productos asociados a un proveedor cuyo
codigo es dado como parámetro. Escribir una consulta de UPDATE que permita realizar este ajuste en la tabla
producto.
Ampliación sugerida:
Codificar un batch en PostgreSQL que realice el ajuste de precios indicado. Declarar una variable para asignar
el código del proveedor y agregar manejo de errores para hacer el proceso más seguro y controlado.
*/

select * from producto.proveedor where id = 3292;
select precio_unitario from producto.producto where id_proveedor = 3292;

do $$
declare 
    v_cod_proveedor integer := 3292;
begin
    begin
        update producto.producto
        set precio_unitario = precio_unitario * 1.15
        where id_proveedor = v_cod_proveedor;
        raise notice 'Precios actualizados correctamente para el proveedor %', v_cod_proveedor;
    exception
        when others then
            raise warning 'Error al actualizar los precios para el proveedor %: %', v_cod_proveedor, sqlerrm;
    end;
end;
$$;

select precio_unitario from producto.producto where id_proveedor = 3292;
 

DO $$ 
DECLARE
    codigo_proveedor VARCHAR := 'PROV123'; -- Código del proveedor a actualizar
    id_proveedor INT;
    filas_actualizadas INT;
BEGIN
    -- Obtener el ID del proveedor según su código
    SELECT id INTO id_proveedor FROM proveedor WHERE codigo = codigo_proveedor;
    
    -- Si el proveedor no existe, lanzar error
    IF id_proveedor IS NULL THEN
        RAISE EXCEPTION 'No se encontró un proveedor con código %', codigo_proveedor;
    END IF;

    -- Actualizar precios de los productos de ese proveedor
    UPDATE producto
    SET precio_unitario = precio_unitario * 1.15
    WHERE id_proveedor = id_proveedor
    RETURNING COUNT(*) INTO filas_actualizadas;

    -- Mensaje de confirmación
    RAISE NOTICE 'Se actualizaron % productos del proveedor %', filas_actualizadas, codigo_proveedor;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en la actualización: %', SQLERRM;
END $$;



/*
Ejercicio 2: Consulta de ventas por sucursal

Escribir una consulta SQL que muestre el total de ventas por cada sucursal, ordenado de mayor a menor. La
consulta debe devolver los siguientes datos:
• código de la sucursal
• nombre o descripción de la sucursal.
• nombre de la provincia y nombre de la localidad en la que se encuentra la sucursal. Si la sucursal no
tiene una localidad asignada, debe mostrar "Provincia desconocida" y "Localidad desconocida"
• total de ventas
Las sucursales con mayor facturación mensual deben aparecer primero. Considerar únicamente facturas
confirmadas.
La consulta debe implementarse en SQL estándar en una consulta simple, sin el uso de funciones,
procedimientos, cursores ni otros elementos avanzados.
*/

select s.codigo as CodSuc, s.descripcion as NomSuc, 
	   coalesce(l.descripcion, 'Localidad Desconocida') as Localidad, 
	   coalesce(p.descripcion, 'Provincia Desconocida') as Provincia,
	   sum(f.total) as TotalVentas 
			
	from persona.sucursal s 
		inner join persona.localidad l on s.id_localidad = l.id 
		inner join persona.provincia p on l.id_provincia = p.id 
		inner join persona.empleado e on e.id_sucursal = s.id 
		inner join venta.factura f on f.id_empleado = e.id 
	where f.total > 0
	group by s.id, l.descripcion, p.descripcion 
	order by TotalVentas desc;
		

/*
Ejercicio 3: Vista para DW

Crear una vista llamada vista_facturacion_dw que permita desnormalizar, para su uso en un entorno de data
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
La vista debe incluir únicamente los datos de ventas realizadas después del año 2021. Considerar únicamente
facturas confirmadas. Toda esta información debe estar consolidada en una sola fila por cada producto vendido
en una factura.
*/

create view vista_facturacion_dw as
select f.id_cliente as CodigoCliente,
       f.numero as NumeroFactura, 
       extract(year from f.fecha) as anio, 
       extract(month from f.fecha) as mes, 
       extract(day from f.fecha) as dia, 
       f.total, 
       fd.id_producto, 
       fd.cantidad, 
       fd.precio_unitario, 
       fd.cantidad * fd.precio_unitario as costo
    from venta.factura f 
        inner join venta.factura_detalle fd on f.id = fd.id_factura
    where f.fecha > '2021-01-01' and f.total > 0;
