// GET /api/vendedores — Catálogo de vendedores activos (select opcional)
import { createError } from 'h3'
import { getPool } from '../utils/db'
import type { VendedorOption } from '#shared/types/catalogo'

export default defineEventHandler(async (): Promise<VendedorOption[]> => {
  try {
    const pool = await getPool()
    const resultado = await pool.request().query(`
      SELECT CAST(id_vendedor AS INT) AS id_vendedor, nombre, apellido, email
      FROM dbo.vendedores
      WHERE activo = 1
      ORDER BY nombre ASC, apellido ASC
    `)
    return resultado.recordset as VendedorOption[]
  } catch (err) {
    console.error('[api/vendedores/get]', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'No se pudo consultar el catálogo de vendedores.'
    })
  }
})
