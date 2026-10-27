// POST /api/categorias — Alta de categoría (llama a sp_Categorias_Crear)
import { createError, readBody, setResponseStatus } from 'h3'
import { getPool, sql } from '../../utils/db'
import { esErrorDuplicado, esErrorH3, numeroErrorSql, textoOpcional, textoRequerido } from '../../utils/validacion'
import { slugify } from '#shared/utils/slug'
import type { CategoriaOption } from '#shared/types/catalogo'

export default defineEventHandler(async (event) => {
  const body = await readBody<unknown>(event)
  if (!body || typeof body !== 'object') {
    throw createError({ statusCode: 400, statusMessage: 'Cuerpo de la petición inválido.' })
  }
  const datos = body as Record<string, unknown>

  try {
    const nombre = textoRequerido(datos.nombre, 'Nombre', 100)
    const descripcion = textoOpcional(datos.descripcion, 'Descripción', 500)
    const slugPersonalizado = textoOpcional(datos.slug, 'Slug', 100)
    const slug = slugPersonalizado ? slugify(slugPersonalizado) : slugify(nombre)

    const pool = await getPool()
    const resultado = await pool.request()
      .input('nombre', sql.NVarChar(100), nombre)
      .input('descripcion', sql.NVarChar(500), descripcion)
      .input('slug', sql.NVarChar(100), slug || null)
      .query(`EXEC dbo.sp_Categorias_Crear @nombre, @descripcion, @slug`)

    setResponseStatus(event, 201)
    return resultado.recordset[0] as CategoriaOption
  } catch (err) {
    if (esErrorH3(err)) throw err
    const sqlErrNum = numeroErrorSql(err)
    if (sqlErrNum && (sqlErrNum === 50001 || sqlErrNum === 50002)) {
      throw createError({
        statusCode: 409,
        statusMessage: 'Ya existe una categoría con ese nombre o slug.'
      })
    }
    console.error('[api/categorias/post]', err)
    throw createError({ statusCode: 500, statusMessage: 'No se pudo guardar la categoría.' })
  }
})
