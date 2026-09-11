-- Miguel García 
-- 2290-24-8950

-- Fase 3 Tejido Relacional y Análisis Estratégico 

USE CrediCore;

--------------------------------------------------
--- Parte A --------------------------------------

-- Primera Relacion de tabla Creditos con el Id del Cliente de la tabla clientes
ALTER TABLE Operaciones.Creditos
ADD CONSTRAINT FK_CClientes
FOREIGN KEY (IdCliente)
REFERENCES Operaciones.Clientes(IdCliente);

-- Segunda Relacion de tabla creditos con el Id del Vehiculos con la tabla de vehiculos
ALTER TABLE Operaciones.Creditos
ADD CONSTRAINT FK_CVehiculos
FOREIGN KEY (IdVehiculo)
REFERENCES Garantias.Vehiculos(IdVehiculos);

-- Prueba de Destrucción

-- Antes de Realizar un Delete, es necesario buscar un cliente que tenga creditos a su nombre
-- Realizamos una selección del los primeros 10 y contamos los creitos de ese id 

SELECT TOP 10
	IdCliente,
	COUNT(*) AS CantidadCreditos
FROM Operaciones.Creditos
GROUP BY IdCliente;

-- Para este caso todos cuentan con 4 creditos

-- Iniciamos la Prueba de Destrucción

DELETE FROM Operaciones.Clientes
WHERE IdCliente = 5;

--------------------------------------------------
--- Parte B --------------------------------------

-- Primera Consulta donde relacionamos 3 tablas 

SELECT
    CL.Nombres,
    CL.Telefono,
    V.Marca,
    V.Placa,
    C.MontoCapital,
    C.Estado
FROM Operaciones.Creditos C
INNER JOIN Operaciones.Clientes CL
    ON C.IdCliente = CL.IdCliente
INNER JOIN Garantias.Vehiculos V
    ON C.IdVehiculo = V.IdVehiculos;

-- Segunda Consulta donde encontramos clientes que nunca han tenido un credito

SELECT
    CL.Nombres,
    CL.Telefono
FROM Operaciones.Clientes CL
LEFT JOIN Operaciones.Creditos C
    ON CL.IdCliente = C.IdCliente
WHERE C.IdCliente IS NULL;

INSERT INTO Operaciones.Clientes
    (Nombres, Apellidos, Telefono, Correo, DPI)
VALUES
    ('Lucia', 'Morales', '55651234', 'lucia.morales@gmail.com', '9876543210123');

--------------------------------------------------
--- Parte C --------------------------------------

-- Primera consulta donde agrupapamos aquellos creditos mayores al promedio historico

-- Pero antes consultamos el Promedio Historico 
SELECT AVG(MontoCapital) AS PHistorico
FROM Operaciones.Creditos;

SELECT 
	CL.Nombres,
	C.MontoCapital
FROM Operaciones.Creditos C
INNER JOIN Operaciones.Clientes CL
	ON C.IdCliente = CL.IdCliente
WHERE C.MontoCapital > (
	SELECT AVG(MontoCapital)
	FROM Operaciones.Creditos
);

-- Segunda Consulta donde Mostramos Unicamente los creditos cuyos vehiculos sean menor o igual
-- al año 2011

SELECT
    CL.Nombres,
    C.IdCredito
FROM Operaciones.Creditos C
INNER JOIN Operaciones.Clientes CL
    ON C.IdCliente = CL.IdCliente
WHERE C.IdVehiculo IN (
    SELECT V.IdVehiculos
    FROM Garantias.Vehiculos V
    WHERE V.Anio <= 2011
);

-- Consulta Unica de vehiculos posteriores al año 2011
SELECT V.IdVehiculos
    FROM Garantias.Vehiculos V
    WHERE V.Anio <= 2011;






