// DELETE /api/marcas/:id — Eliminar marca (borrado físico, llama a sp_Marcas_Eliminar)
import { createError, getRouterParam } from 'h3'
import { getPool, sql } from '../../utils/db'
import { esErrorH3, numeroErrorSql } from '../../utils/validacion'

export default defineEventHandler(async (event) => {
  const idRaw = getRouterParam(event, 'id')
  const idMarca = Number(idRaw)
  if (!Number.isInteger(idMarca) || idMarca <= 0) {
    throw createError({ statusCode: 400, statusMessage: 'ID de marca inválido.' })
  }

  try {
    const pool = await getPool()
    const resultado = await pool.request()
      .input('id_marca', sql.Int, idMarca)
      .query(`EXEC dbo.sp_Marcas_Eliminar @id_marca`)

    if (resultado.recordset.length === 0) {
      throw createError({ statusCode: 404, statusMessage: 'Marca no encontrada.' })
    }

    return { ok: true, id: idMarca, mensaje: 'Marca eliminada correctamente.' }
  } catch (err) {
    if (esErrorH3(err)) throw err
    const sqlErrNum = numeroErrorSql(err)
    if (sqlErrNum === 50014) {
      throw createError({ statusCode: 404, statusMessage: 'Marca no encontrada.' })
    }
    if (sqlErrNum === 547 || /FOREIGN KEY|CHECK constraint/i.test((err as { message?: string }).message ?? '')) {
      throw createError({
        statusCode: 400,
        statusMessage: 'No se puede eliminar la marca porque tiene registros relacionados.'
      })
    }
    console.error('[api/marcas/delete]', err)
    throw createError({ statusCode: 500, statusMessage: 'No se pudo eliminar la marca.' })
  }
})
