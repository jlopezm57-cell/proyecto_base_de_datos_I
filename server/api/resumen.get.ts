// GET /api/resumen — Conteos generales para el panel de inicio
import { createError } from 'h3'
import { getPool } from '../utils/db'
import type { Resumen } from '#shared/types/catalogo'

export default defineEventHandler(async (): Promise<Resumen> => {
  try {
    const pool = await getPool()
    const resultado = await pool.request().query(`
      SELECT
        (SELECT COUNT(*) FROM dbo.productos)   AS productos,
        (SELECT COUNT(*) FROM dbo.categorias)  AS categorias,
        (SELECT COUNT(*) FROM dbo.marcas)      AS marcas,
        (SELECT COUNT(*) FROM dbo.vendedores)  AS vendedores
    `)
    return resultado.recordset[0] as Resumen
  } catch (err) {
    console.error('[api/resumen/get]', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'No se pudo consultar el resumen de la base de datos.'
    })
  }
})
