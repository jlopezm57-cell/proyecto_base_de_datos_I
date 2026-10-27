// PUT /api/categorias/:id — Actualizar categoría (llama a sp_Categorias_Actualizar)
import { createError, getRouterParam, readBody } from 'h3'
import { getPool, sql } from '../../utils/db'
import { esErrorH3, numeroErrorSql, textoOpcional, textoRequerido } from '../../utils/validacion'
import { slugify } from '#shared/utils/slug'
import type { CategoriaOption } from '#shared/types/catalogo'

export default defineEventHandler(async (event) => {
  const idRaw = getRouterParam(event, 'id')
  const idCategoria = Number(idRaw)
  if (!Number.isInteger(idCategoria) || idCategoria <= 0) {
    throw createError({ statusCode: 400, statusMessage: 'ID de categoría inválido.' })
  }

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
      .input('id_categoria', sql.Int, idCategoria)
      .input('nombre', sql.NVarChar(100), nombre)
      .input('descripcion', sql.NVarChar(500), descripcion)
      .input('slug', sql.NVarChar(100), slug || null)
      .query(`EXEC dbo.sp_Categorias_Actualizar @id_categoria, @nombre, @descripcion, @slug`)

    if (resultado.recordset.length === 0) {
      throw createError({ statusCode: 404, statusMessage: 'Categoría no encontrada.' })
    }

    return resultado.recordset[0] as CategoriaOption
  } catch (err) {
    if (esErrorH3(err)) throw err
    const sqlErrNum = numeroErrorSql(err)
    if (sqlErrNum && (sqlErrNum === 50004 || sqlErrNum === 50005)) {
      throw createError({
        statusCode: 409,
        statusMessage: 'Ya existe otra categoría con ese nombre o slug.'
      })
    }
    if (sqlErrNum === 50003) {
      throw createError({ statusCode: 404, statusMessage: 'Categoría no encontrada.' })
    }
    console.error('[api/categorias/put]', err)
    throw createError({ statusCode: 500, statusMessage: 'No se pudo actualizar la categoría.' })
  }
})
