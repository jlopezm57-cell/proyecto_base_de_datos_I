// DELETE /api/categorias/:id — Eliminar categoría (borrado físico, llama a sp_Categorias_Eliminar)
import { createError, getRouterParam } from 'h3'
import { getPool, sql } from '../../utils/db'
import { esErrorH3, numeroErrorSql } from '../../utils/validacion'

export default defineEventHandler(async (event) => {
  const idRaw = getRouterParam(event, 'id')
  const idCategoria = Number(idRaw)
  if (!Number.isInteger(idCategoria) || idCategoria <= 0) {
    throw createError({ statusCode: 400, statusMessage: 'ID de categoría inválido.' })
  }

  try {
    const pool = await getPool()
    const resultado = await pool.request()
      .input('id_categoria', sql.Int, idCategoria)
      .query(`EXEC dbo.sp_Categorias_Eliminar @id_categoria`)

    if (resultado.recordset.length === 0) {
      throw createError({ statusCode: 404, statusMessage: 'Categoría no encontrada.' })
    }

    return { ok: true, id: idCategoria, mensaje: 'Categoría eliminada correctamente.' }
  } catch (err) {
    if (esErrorH3(err)) throw err
    const sqlErrNum = numeroErrorSql(err)
    if (sqlErrNum === 50006) {
      throw createError({ statusCode: 404, statusMessage: 'Categoría no encontrada.' })
    }
    if (sqlErrNum === 547 || /FOREIGN KEY|CHECK constraint/i.test((err as { message?: string }).message ?? '')) {
      throw createError({
        statusCode: 400,
        statusMessage: 'No se puede eliminar la categoría porque tiene registros relacionados.'
      })
    }
    console.error('[api/categorias/delete]', err)
    throw createError({ statusCode: 500, statusMessage: 'No se pudo eliminar la categoría.' })
  }
})
