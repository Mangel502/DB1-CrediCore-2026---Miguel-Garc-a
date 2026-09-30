-- Miguel García -- 

--- 2290 - 24 - 8950

-- Para este apartado fue necesario actuaizar el saldo actual a 0
-- Ya que en la fases anteriores llenamos el campo de saldo actual
-- Con el con la columna de monto Capital, entoces tenemos creditos ya pagados
-- Pero con saldo aun disponible

USE Credicore;

-- Realizamos una actualización y dejamos en 0 aquellos creditos con el estado
-- Pagado.
UPDATE Operaciones.Creditos
SET SaldoActual = 0
WHERE Estado = 'Pagado';


-- Consulta para verificar si queda algun credito pagado que sea
-- Ma
SELECT  IdCredito, Estado, MontoCapital,SaldoActual

FROM Operaciones.Creditos
WHERE Estado = 'Pagado'
AND SaldoActual > 0;






