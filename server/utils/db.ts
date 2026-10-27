// Pool compartido de SQL Server.
// Usa el driver msnodesqlv8 de `mssql` (ODBC Driver 17 + autenticación de Windows),
// que es el que funciona en este entorno local.
import sql from 'mssql/msnodesqlv8.js'
import type { ConfiguracionSql, PoolSql } from 'mssql/msnodesqlv8.js'

const servidor = process.env.SQL_SERVER ?? 'localhost'
const baseDatos = process.env.SQL_DATABASE ?? 'INTERCOMERCIO'
const controlador = process.env.SQL_ODBC_DRIVER ?? 'ODBC Driver 17 for SQL Server'

/** Configuración de conexión (se puede sobreescribir con variables de entorno SQL_*) */
export const configuracion: ConfiguracionSql = {
  server: servidor,
  database: baseDatos,
  connectionString:
    `Driver={${controlador}};Server=${servidor};Database=${baseDatos};Trusted_Connection=Yes;`,
  pool: { max: 10, min: 0, idleTimeoutMillis: 30_000 },
  options: { encrypt: false, trustServerCertificate: true, trustedConnection: true }
}

let pool: PoolSql | null = null

/*
 * Nota importante sobre el driver:
 * msnodesqlv8 devuelve las columnas IDENTITY (INT) como texto. Por eso las
 * consultas de la API aplican CAST(columna AS INT) sobre los identificadores
 * para que lleguen al frontend como números.
 */

/** Devuelve el pool de conexiones, reconectando si se perdió la conexión */
export async function getPool(): Promise<PoolSql> {
  if (pool?.connected) return pool

  if (pool) {
    try {
      await pool.close()
    } catch {
      // el pool ya estaba cerrado; se ignora
    }
    pool = null
  }

  const nuevoPool = new sql.ConnectionPool(configuracion)
  nuevoPool.on('error', () => {
    pool = null
  })
  await nuevoPool.connect()
  pool = nuevoPool
  return pool
}

export { sql }
