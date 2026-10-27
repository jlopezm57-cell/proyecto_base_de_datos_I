// DELETE /api/productos/:id — Eliminar producto (borrado físico, llama a sp_Productos_Eliminar)
import { createError, getRouterParam } from 'h3'
import { getPool, sql } from '../../utils/db'
import { esErrorH3, numeroErrorSql } from '../../utils/validacion'

export default defineEventHandler(async (event) => {
  const idRaw = getRouterParam(event, 'id')
  const idProducto = Number(idRaw)
  if (!Number.isInteger(idProducto) || idProducto <= 0) {
    throw createError({ statusCode: 400, statusMessage: 'ID de producto inválido.' })
  }

  try {
    const pool = await getPool()
    const resultado = await pool.request()
      .input('id_producto', sql.Int, idProducto)
      .query(`EXEC dbo.sp_Productos_Eliminar @id_producto`)

    if (resultado.recordset.length === 0) {
      throw createError({ statusCode: 404, statusMessage: 'Producto no encontrado.' })
    }

    return { ok: true, id: idProducto, mensaje: 'Producto eliminado correctamente.' }
  } catch (err) {
    if (esErrorH3(err)) throw err
    const sqlErrNum = numeroErrorSql(err)
    if (sqlErrNum === 50024) {
      throw createError({ statusCode: 404, statusMessage: 'Producto no encontrado.' })
    }
    if (sqlErrNum === 547 || /FOREIGN KEY|CHECK constraint/i.test((err as { message?: string }).message ?? '')) {
      throw createError({
        statusCode: 400,
        statusMessage: 'No se puede eliminar el producto porque tiene registros relacionados.'
      })
    }
    console.error('[api/productos/delete]', err)
    throw createError({ statusCode: 500, statusMessage: 'No se pudo eliminar el producto.' })
  }
})
