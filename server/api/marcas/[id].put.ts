// PUT /api/marcas/:id — Actualizar marca (llama a sp_Marcas_Actualizar)
import { createError, getRouterParam, readBody } from 'h3'
import { getPool, sql } from '../../utils/db'
import { esErrorH3, numeroErrorSql, textoOpcional, textoRequerido } from '../../utils/validacion'
import type { MarcaOption } from '#shared/types/catalogo'

export default defineEventHandler(async (event) => {
  const idRaw = getRouterParam(event, 'id')
  const idMarca = Number(idRaw)
  if (!Number.isInteger(idMarca) || idMarca <= 0) {
    throw createError({ statusCode: 400, statusMessage: 'ID de marca inválido.' })
  }

  const body = await readBody<unknown>(event)
  if (!body || typeof body !== 'object') {
    throw createError({ statusCode: 400, statusMessage: 'Cuerpo de la petición inválido.' })
  }
  const datos = body as Record<string, unknown>

  try {
    const nombre = textoRequerido(datos.nombre, 'Nombre', 100)
    const paisOrigen = textoOpcional(datos.pais_origen, 'País de origen', 100)
    const sitioWeb = textoOpcional(datos.sitio_web, 'Sitio web', 255)

    const pool = await getPool()
    const resultado = await pool.request()
      .input('id_marca', sql.Int, idMarca)
      .input('nombre', sql.NVarChar(100), nombre)
      .input('pais_origen', sql.NVarChar(100), paisOrigen)
      .input('sitio_web', sql.NVarChar(255), sitioWeb)
      .query(`EXEC dbo.sp_Marcas_Actualizar @id_marca, @nombre, @pais_origen, @sitio_web`)

    if (resultado.recordset.length === 0) {
      throw createError({ statusCode: 404, statusMessage: 'Marca no encontrada.' })
    }

    return resultado.recordset[0] as MarcaOption
  } catch (err) {
    if (esErrorH3(err)) throw err
    const sqlErrNum = numeroErrorSql(err)
    if (sqlErrNum === 50013) {
      throw createError({
        statusCode: 409,
        statusMessage: 'Ya existe otra marca con ese nombre.'
      })
    }
    if (sqlErrNum === 50012) {
      throw createError({ statusCode: 404, statusMessage: 'Marca no encontrada.' })
    }
    console.error('[api/marcas/put]', err)
    throw createError({ statusCode: 500, statusMessage: 'No se pudo actualizar la marca.' })
  }
})
