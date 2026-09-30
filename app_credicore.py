import streamlit as st
import pandas as pd
import pyodbc

# 1. Configuración de Conexión (Cambien estos datos por los de su Ubuntu/Docker)
SERVER = '127.0.0.1' 
DATABASE = 'CrediCore'
USERNAME = 'CrediCoreAdm'
PASSWORD = 'CrediCrece45'


# El Código original, se utlizaba el ODBC driver 17
# Para esta parte de la practica se instaló OBDC driver 19
# TrustServerCertificate=yes permite aceptar el certificado
# del SQL Server utilizado en nuestro entorno local

conn_str = (
    f'DRIVER={{ODBC Driver 18 for SQL Server}};'
    f'SERVER={SERVER};'
    f'DATABASE={DATABASE};'
    f'UID={USERNAME};'
    f'PWD={PASSWORD};'
    f'TrustServerCertificate=yes'
)

st.set_page_config(page_title="ERP CrediCore", layout="centered")
st.title("🏦 CrediCore - Módulo de Caja")
st.markdown("Interfaz conectada directamente al motor transaccional de SQL Server")

# 2. Leer la Vista Segura

# Se agregó el esquema Operaciones porque nuestra vista
    # fue creada como Operaciones.vw_AtencionCliente.
    # Sin el esquema SQL Server no encontraba el objeto
st.subheader("Estado de Cuenta (Vista Segura)")
try:
    conn = pyodbc.connect(conn_str)
    # Llamamos a la vista, no a las tablas
    query = "SELECT * FROM Operaciones.vw_AtencionCliente"
    df = pd.read_sql(query, conn)
    st.dataframe(df, use_container_width=True)
except Exception as e:
    st.error(f"Error de conexión a la BD: {e}")

st.divider()

# 3. Formulario para ejecutar el Procedimiento Almacenado
st.subheader("Procesar Pago de Cuota")
with st.form("form_pago", clear_on_submit=True):
    id_credito = st.number_input("Número de Crédito (ID)", min_value=1, step=1)
    monto_pago = st.number_input("Monto a Abonar (Q)", min_value=1.0, step=100.0)
    btn_pagar = st.form_submit_button("Ejecutar Transacción")
    
    if btn_pagar:
        try:
            cursor = conn.cursor()
            # Invocamos el SP con sus parámetros


            # Se agregó el esquema Operaciones porque el 
            # procedimiento está almacenado dentro de ese esquema
            # También se cambiaron los valores concatenados por
            # parámetros (?) para enviar IdCredito y MontoAbono
            cursor.execute("EXEC Operaciones.SP_ProcesarPago @IdCredito = ?, @MontoAbono = ?",id_credito,monto_pago)

            cursor.commit()
            st.success("¡Pago procesado con éxito en SQL Server!")
            st.rerun() # Recarga la pantalla para actualizar la tabla
        except Exception as e:
            # Aquí capturamos el RAISERROR que ustedes programaron en el TRY...CATCH de SQL
            st.error(f"Transacción Rechazada por el Motor: {e}")