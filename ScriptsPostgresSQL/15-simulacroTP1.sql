-----------------------1. Esquema persona-------------------------------
/*a. Sucursales con Información de Empleados

Obtener una lista de todas las sucursales, organizadas por localidad y provincia,
incluyendo información de cada empleado que trabaja en la sucursal (nombre y
apellido). Ordenar por el nombre de la provincia, nombre de la localidad, nombre de
sucursal, apellido y nombre del empleado.*/

select p.descripcion as provincia,  l.descripcion as localidad, s.descripcion as sucursal, pf.apellido || ', ' || pf.nombre as ApeNom
	from persona.sucursal s left join persona.empleado e on s.id = e.id_sucursal
							inner join persona.localidad l on s.id_localidad = l.id
							inner join persona.provincia p on l.id_provincia = p.id
							inner join persona.persona_fisica pf on e.id_persona_fisica = pf.id 
	group by p.descripcion, l.descripcion, s.descripcion, pf.apellido, pf.nombre 
	order by p.descripcion, l.descripcion, s.descripcion, pf.apellido, pf.nombre;

/*b. Clientes con Información de Datos Personales
	
Obtener una lista de todos los clientes, incluyendo la información personal
almacenada en la tabla persona y, según corresponda, en persona_fisica o
persona_juridica. Incluir la provincia y localidad si están disponibles. Ordenar por
apellido y nombre (para personas físicas) o por razón social (para personas jurídicas).*/

select * 
	from persona.cliente c left join persona.persona p on c.id_persona = p.id
							left join persona.persona_fisica pf on p.id = pf.id_persona 
							left join persona.persona_juridica pj on p.id = pj.id_persona
							inner join persona.localidad l on p.id_localidad = l.id
	order by pf.apellido, pf.nombre, pj.cuit;

/*c. Proveedores con Información de Datos Personales

Obtener una lista de todos los proveedores, incluyendo información personal de la
tabla persona y persona_juridica. Incluir provincia y localidad si están disponibles, y
ordenar por razón social.*/



/*d. Personas con Múltiples Roles

Identificar personas que cumplen más de un rol: Empleado, Cliente y Proveedor.
Mostrar el nombre y apellido (para personas físicas) o razón social (para personas
jurídicas) y los roles que cumplen.
*/

select distinct(tipo) from persona.persona p; 





-- RESOLUCION POR CHATGPT, FUNCIONA
WITH RolesPorPersona AS (
    SELECT 
        p.id,
        CASE 
            WHEN p.tipo = 'FISICA' THEN pf.nombre || ', ' || pf.apellido
            ELSE pj.denominacion
        END AS nombre_completo,
        ARRAY_AGG(DISTINCT rol) AS roles
    FROM 
        persona.persona p
    LEFT JOIN persona.persona_fisica pf ON p.id = pf.id_persona
    LEFT JOIN persona.persona_juridica pj ON p.id = pj.id_persona
    LEFT JOIN persona.empleado e ON pf.id = e.id_persona_fisica
    LEFT JOIN persona.cliente c ON p.id = c.id_persona
    LEFT JOIN persona.proveedor pr ON pj.id = pr.id_persona_juridica
    CROSS JOIN LATERAL (
        SELECT 'Empleado' AS rol WHERE e.id_persona_fisica IS NOT NULL
        UNION ALL
        SELECT 'Cliente' AS rol WHERE c.id_persona IS NOT NULL
        UNION ALL
        SELECT 'Proveedor' AS rol WHERE pr.id_persona_juridica IS NOT NULL
    ) AS roles
    GROUP BY p.id, p.tipo, pf.nombre, pf.apellido, pj.denominacion
)

SELECT 
    id,
    nombre_completo,
    roles
FROM 
    RolesPorPersona
WHERE 
    ARRAY_LENGTH(roles, 1) > 1
ORDER BY 
    nombre_completo;

									