/*1. Importación de productos desde archivo CSV
Crear un procedimiento almacenado o función que permita importar productos desde un
archivo en formato CSV. El archivo tiene las siguientes columnas:
• Marca
• Código de producto
• Descripción
• Precio unitario

El procedimiento debe realizar las siguientes acciones:

• Buscar cada marca por su descripción, si no existe, insertarla.
• Buscar cada producto por su código. Si el producto no existe, insertarlo. Si ya
existe, omitirlo.
• Al finalizar, el procedimiento debe devolver el número total de registros
procesados, la cantidad de productos nuevos insertados, y la cantidad de marcas
nuevas insertadas.*/

create table tmp_producto(
	marca bigint not null,
	codMarca bigint not null,
	descr varchar(256) null,
	precioUnit numeric(38,2)
);

copy tmp_producto(marca, codMarca, descr, precioUnit)
	from'/Users/maxieberhardt/Downloads/1.productos-C.csv'
	delimiter ','
	csv header;

/*2. Estructura de Compras
Crear las tablas factura_compra y detalle_factura_compra, en un nuevo esquema
“compra”. El modelo a implementar es el siguiente:*/

/*3. Cargar Facturas de Compras desde Archivo TXT
Crear un procedimiento almacenado que permita cargar facturas de compras desde un
archivo .txt en el siguiente formato:

• Cada línea representa un ítem de detalle y tiene los campos separados por
tabuladores: Número de factura, fecha, proveedor, Código del producto,
Cantidad, Precio unitario.
• Si el número de factura no existe, debe crearse la factura.
• Al finalizar, mostrar el total de registros procesados.*/

/*4. Triggers para Actualización del Total de Factura
Codificar triggers que actualicen el total de la factura automáticamente cuando se hagan
INSERT, DELETE o UPDATE en detalle_factura, tanto para facturas de ventas como
de compras.*/

/*5. Reporte de Stock Disponible
Crear un procedimiento o función que calcule el stock disponible de un producto dado
en un momento específico. El stock debe sumar todas las compras y restar todas las
ventas hasta la fecha especificada.*/