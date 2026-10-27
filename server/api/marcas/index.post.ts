// POST /api/marcas — Alta de marca (llama a sp_Marcas_Crear)
import { createError, readBody, setResponseStatus } from 'h3'
import { getPool, sql } from '../../utils/db'
import { esErrorDuplicado, esErrorH3, numeroErrorSql, textoOpcional, textoRequerido } from '../../utils/validacion'
import type { MarcaOption } from '#shared/types/catalogo'

export default defineEventHandler(async (event) => {
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
      .input('nombre', sql.NVarChar(100), nombre)
      .input('pais_origen', sql.NVarChar(100), paisOrigen)
      .input('sitio_web', sql.NVarChar(255), sitioWeb)
      .query(`EXEC dbo.sp_Marcas_Crear @nombre, @pais_origen, @sitio_web`)

    setResponseStatus(event, 201)
    return resultado.recordset[0] as MarcaOption
  } catch (err) {
    if (esErrorH3(err)) throw err
    const sqlErrNum = numeroErrorSql(err)
    if (sqlErrNum === 50011) {
      throw createError({
        statusCode: 409,
        statusMessage: 'Ya existe una marca con ese nombre.'
      })
    }
    console.error('[api/marcas/post]', err)
    throw createError({ statusCode: 500, statusMessage: 'No se pudo guardar la marca.' })
  }
})
