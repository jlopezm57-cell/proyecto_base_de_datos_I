// Declaración ambiental mínima para el driver msnodesqlv8 de mssql.
// El paquete `mssql` no publica tipos TypeScript para esta ruta de importación,
// así que se declara lo que usa el servidor del proyecto.

declare module 'mssql/msnodesqlv8.js' {
  /** Tipo de parámetro de entrada (sql.Int, sql.NVarChar(50), sql.Decimal(18,2), …) */
  export type ParametroSql = unknown

  export interface ResultadoSql {
    recordset: any[]
    recordsets: any[][]
    rowsAffected: number[]
  }

  export interface SolicitudSql {
    input(nombre: string, tipo: ParametroSql, valor?: unknown): SolicitudSql
    query(texto: string): Promise<ResultadoSql>
  }

  export interface PoolSql {
    readonly connected: boolean
    on(evento: string, listener: (...args: any[]) => void): unknown
    once(evento: string, listener: (...args: any[]) => void): unknown
    connect(): Promise<PoolSql>
    close(): Promise<void>
    request(): SolicitudSql
  }

  export interface ConfiguracionSql {
    connectionString?: string
    driver?: string
    server?: string
    database?: string
    pool?: { max?: number; min?: number; idleTimeoutMillis?: number }
    options?: Record<string, unknown>
  }

  export interface TiposSql {
    Int: ParametroSql
    Bit: ParametroSql
    NVarChar: ((longitud?: number) => ParametroSql) & ParametroSql
    Decimal: (precision: number, escala: number) => ParametroSql
    MAX: number
    ConnectionPool: new (configuracion: ConfiguracionSql) => PoolSql
    connect(configuracion: ConfiguracionSql): Promise<PoolSql>
  }

  const sql: {
    ConnectionPool: new (config: ConfiguracionSql) => PoolSql
    Int: ParametroSql
    Bit: ParametroSql
    NVarChar: (longitud?: number) => ParametroSql
    Decimal: (precision: number, escala: number) => ParametroSql
    MAX: number
    connect(config: ConfiguracionSql): Promise<PoolSql>
  }

  export default sql
}
