-- Miguel García 
-- 2290-24-8950

-- Fase 4 Credicore - Programabilidad y Auditoría Activa 

USE CrediCore;

-------------------------------------------
----- Parte A - Vistas --------------------


-- Modificamos la tabla de creditos donde creamos la columna de saldo actual
ALTER TABLE Operaciones.Creditos
ADD SaldoActual DECIMAL(16,2);

-- Igualamos la columna de saldo actual con la de monto de capital inicial
UPDATE Operaciones.Creditos
SET SaldoActual = MontoCapital;

-- Creamos la vista para la atención al cliente
CREATE VIEW Operaciones.vw_AtencionCliente AS SELECT
	CL.Nombres AS NombreCliente,
	C.IdCredito AS NumeroCredito,
	V.Marca AS MarcaVehiculo,
	C.Estado AS EstadoCredito,
	C.SaldoActual
FROM Operaciones.Creditos C
INNER JOIN Operaciones.Clientes CL
	ON C.IdCliente = CL.IdCliente
INNER JOIN Garantias.Vehiculos V
	ON C.IdVehiculo = V.IdVehiculos;


-- Realizamos una consilta para probar la vista creada
SELECT * FROM Operaciones.vw_AtencionCliente;


-------------------------------------------
--- Parte B - Lógica de Negocio Seguro ----

-- Creamos una nueva tabla que nos registrará los movimientos de pago
-- Y agregamos la referencia de id credito con llave primaria hacia la tabla de id credito.
CREATE TABLE Operaciones.HistorialPagos(
	IdPago INT IDENTITY(1,1) PRIMARY KEY,
	IdCredito INT FOREIGN KEY REFERENCES Operaciones.Creditos(IdCredito),
	MontoAbono DECIMAL(14,2),
	FechaPago DATETIME DEFAULT GETDATE()
);

-- Creación de proceso para realizar el pago de forma segura
CREATE PROCEDURE Operaciones.SP_ProcesarPago
	@IdCredito INT,
	@MontoAbono DECIMAL(16,2)

-- Indicamos  el inicio de la logica interna de nuestra acción
AS BEGIN
	
	-- Declaramos una variable que para guardar el saldo actual
	DECLARE @SaldoActual Decimal(16,2);
	
	BEGIN TRY
	
	BEGIN TRAN;
	
	SELECT @SaldoActual  = SaldoActual
	FROM Operaciones.Creditos
	WHERE IdCredito = @IdCredito;
	
	-- Condicion para comparar el monto abono con el saldo actual
	IF @MontoAbono > @SaldoActual
	BEGIN
		THROW 50001, 'EL monto ingresado supera el saldo actual', 1;
	END
	
	-- En caso de que el monto abono no supere al saldo actual
	INSERT INTO Operaciones.HistorialPagos
		(IdCredito, MontoAbono)
	VALUES
		(@IdCredito,@MontoAbono);
	
	-- Entonces realizamos el ingreso y actualización del saldo actual
	UPDATE Operaciones.Creditos
	SET SaldoActual = SaldoActual - @MontoAbono
	WHERE IdCredito = @IdCredito;
	
	-- Guardamos cambios realizados
	COMMIT;
	
	END TRY
	
	-- Si ocurre un error, ingresaremos a este aparatado y realizaremos un 
	-- Rollback para revertir los cambios hechos en la anterior transaccion
	BEGIN CATCH
	
		ROLLBACK;
		THROW;
		
	END CATCH
	
END;

-- Realizamos una consulta de los primeros 5 creditos con sus saldos actuales
SELECT TOP 5
    IdCredito,
    SaldoActual
FROM Operaciones.Creditos;

 
-- Realizamos una prueba con algun credito de los 5 de la lista 

EXEC Operaciones.SP_ProcesarPago
	@IdCredito = 5,
	@MontoAbono = 2000;



-----------------------------------------
--- Parte C - El Auditor Silencioso-------

-- Primero Creamos el esquema de Auditoria

CREATE SCHEMA Auditoria;

-- Creamos la tabla para el registro de cambios en la tasa de interes
CREATE TABLE Auditoria.Logs_Creditos(
	IdLog INT IDENTITY(1,1) PRIMARY KEY,
	Accion VARCHAR(50),
	ValorAnterior DECIMAL(5,2),
	ValorNuevo DECIMAL(5,2),
	FechaHora DATETIME
);

-- Creacion de Trigger

CREATE TRIGGER Operaciones.TR_AuditarTasaCredito
ON Operaciones.Creditos

-- Ejecutamos este trigger despues de realizar un Update 
AFTER UPDATE 
AS 
BEGIN 

	-- Se revisa si se intento realizar un cambio en la columna de TasaInteresMensual
	IF UPDATE(TasaInteresMensual)
	
	
	BEGIN 
		 -- Si hubo modificación en la tasa, se prepara un registro en la tabla de auditoría
		INSERT INTO Auditoria.Logs_Creditos
		(Accion,ValorAnterior,ValorNuevo,FechaHora)
		
		  -- Se seleccionan los valores que serán guardados en el historial
		SELECT 'Cambio de Tasa',
		
		-- D representa los datos anteriores al UPDATE
		D.TasaInteresMensual,
		 -- I representa los datos nuevos despues del UPDATE
		I.TasaInteresMensual, 
		
		 -- Se guarda la fecha y hora exacta en que ocurrió el cambio
		GETDATE()
		
		FROM deleted D
		
		 -- Se une con inserted para comparar el registro anterior con el nuevo
		INNER JOIN inserted I
		
		-- Se relacionan ambos registros por medio del IdCredito
		ON D.IdCredito = I.IdCredito
		
		 -- Unicamente guarda el cambio si la nueva tasa es inferior al anterior
		WHERE I.TasaInteresMensual < D.TasaInteresMensual;
	END
	
END;


-- Realizamos una consulta de los primeros 5 creditos con sus tasas actuales
SELECT TOP 5
    IdCredito,
    TasaInteresMensual
FROM Operaciones.Creditos;


-- Prueba para comprobar el funcionamiento del trigger
UPDATE Operaciones.Creditos
SET TasaInteresMensual = 1.50
WHERE IdCredito = 3;


-- Consulata de la tabla de logs_creditos con los registros
SELECT * FROM Auditoria.Logs_Creditos;

