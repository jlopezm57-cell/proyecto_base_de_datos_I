// GET /api/marcas — Catálogo de marcas activas (para selects)
import { createError } from 'h3'
import { getPool } from '../../utils/db'
import type { MarcaOption } from '#shared/types/catalogo'

export default defineEventHandler(async (): Promise<MarcaOption[]> => {
  try {
    const pool = await getPool()
    const resultado = await pool.request().query(`EXEC dbo.sp_Marcas_Obtener`)
    return resultado.recordset as MarcaOption[]
  } catch (err) {
    console.error('[api/marcas/get]', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'No se pudo consultar el catálogo de marcas.'
    })
  }
})
