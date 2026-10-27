// GET /api/categorias — Catálogo de categorías activas (para selects)
import { createError } from 'h3'
import { getPool } from '../../utils/db'
import type { CategoriaOption } from '#shared/types/catalogo'

export default defineEventHandler(async (): Promise<CategoriaOption[]> => {
  try {
    const pool = await getPool()
    const resultado = await pool.request().query(`EXEC dbo.sp_Categorias_Obtener`)
    return resultado.recordset as CategoriaOption[]
  } catch (err) {
    console.error('[api/categorias/get]', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'No se pudo consultar el catálogo de categorías.'
    })
  }
})
