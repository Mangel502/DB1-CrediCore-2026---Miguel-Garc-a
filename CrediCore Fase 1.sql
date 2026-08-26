-- Miguel Angel Santos García Velásquez
-- 2290 - 24 - 8950

-- Proyecto CrediCore (Fase 1): Cimientos de Titanio (DDL y Dominios)

-- Crear login para una nueva conexion desde la conexion SA, no se pide en la tarea
-- Pero para la practica se realizó este proceso

CREATE LOGIN CrediCoreAdm WITH PASSWORD = 'CrediCrece45';

-- Posteriomente crear la Base de Datos, tambien desde la conexión SA
CREATE DATABASE CrediCore;

-- Procedemos a cambiarnos a la base de datos ya creada.

USE CrediCore;

-- Creamos el usuario para la base de datos.
CREATE USER CrediCoreAdm FOR LOGIN CrediCoreAdm;

-- Le agregamos permisos al usuario, par poder crear y modificar objetos.
ALTER ROLE db_ddladmin ADD MEMBER CrediCoreAdm;


------- Desde Este Punto se Cambia de Conexión ----


-- Volvemos a cambiarnos a la base de datos creada desde la conexion de SA.

USE CrediCore;

-- Creamos el Primer esquema lógico demonidado operaciones

CREATE SCHEMA Operaciones;

-- Y lo mismo con la otra área de negocio Garantias

CREATE SCHEMA Garantias;

-- Creación de nuestra primera tabla esto para la rama de operaciones

CREATE TABLE Operaciones.Clientes(
	IdCliente INT IDENTITY(1,1) PRIMARY KEY,
	Nombres VARCHAR(80),
	Apellidos VARCHAR(80),
	Telefono VARCHAR(20),
	Correo VARCHAR(150),
	DPI VARCHAR(20) UNIQUE 
);


-- Creación de la tabla Vehiculos que corresponde al esquema de Garantias

CREATE TABLE Garantias.Vehiculos(
	IdVehiculos INT IDENTITY(1,1) PRIMARY KEY,
	Modelo VARCHAR(60),
	Marca VARCHAR(60),
	Anio INT CHECK( Anio > 2010),
	Color VARCHAR(30),
	NumeroTitulo VARCHAR(60),
	Placa VARCHAR(30),  
	NumeroChasis VARCHAR(30), 
	
	CONSTRAINT UNIC_Placa_Chasis
	UNIQUE (Placa, NumeroChasis)
);

--Creacion de tabla para creditos que corresponde al esquema Operaciones

CREATE TABLE Operaciones.Creditos(
	IdCredito INT IDENTITY(1,1) PRIMARY KEY,
	IdCliente INT,
	IdVehiculo INT,
	MontoCapital DECIMAL(16,2) CHECK (MontoCapital > 1000),
	TasaInteresMensual DECIMAL (5,2) CHECK (TasaInteresMensual >= 0),
	Estado VARCHAR(15) DEFAULT 'Activo',
	FechaDesembolso DATETIME DEFAULT GETDATE()	
);


--Ingreso de Datos Correctos
INSERT INTO Garantias.Vehiculos (Modelo, Marca, Anio, Color, NumeroTitulo, Placa, NumeroChasis)

VALUES('P0X900', 'Toyota', 2020, 'Rojo', '348909', 'P0X89','89340234');

--Ingreso de Datos Incorrectos
INSERT INTO Operaciones.Creditos (IdCliente, IdVehiculo, MontoCapital, TasaInteresMensual)
VALUES (1, 1, 1500.00, 5.50);

--Visualizar los campos ingresados
SELECT * FROM Garantias.Vehiculos;

SELECT * FROM Operaciones.Creditos;















