// GET /api/productos — Listado paginado con búsqueda y filtro por categoría (llama a sp_Productos_Obtener)
import { createError, getQuery } from 'h3'
import { getPool, sql } from '../../utils/db'
import type { ProductoListItem } from '#shared/types/producto'
import type { RespuestaPaginada } from '#shared/types/catalogo'

export default defineEventHandler(async (event): Promise<RespuestaPaginada<ProductoListItem>> => {
  const query = getQuery(event)

  // Búsqueda libre (nombre o SKU)
  const q = typeof query.q === 'string' && query.q.trim() !== '' ? query.q.trim() : null
  // Filtro por categoría (ignora valores no numéricos)
  const categoriaRaw = Number(query.categoria)
  const idCategoria = Number.isInteger(categoriaRaw) && categoriaRaw > 0 ? categoriaRaw : null
  // Paginación
  const pageRaw = Number(query.page)
  const pageSizeRaw = Number(query.pageSize)
  const pageSize = Number.isInteger(pageSizeRaw) && pageSizeRaw > 0 ? Math.min(pageSizeRaw, 100) : 10
  const page = Number.isInteger(pageRaw) && pageRaw > 0 ? pageRaw : 1

  try {
    const pool = await getPool()
    const request = pool.request()

    request.output('totalRegistros', sql.Int)
    request.input('q', sql.NVarChar, q ?? null)
    request.input('id_categoria', sql.Int, idCategoria ?? null)
    request.input('page', sql.Int, page)
    request.input('pageSize', sql.Int, pageSize)

    const resultado = await request.query(`
      EXEC dbo.sp_Productos_Obtener
        @q,
        @id_categoria,
        @page,
        @pageSize,
        @totalRegistros OUTPUT
    `)

    const total: number = Number(resultado.output?.totalRegistros ?? 0)
    const totalPaginas = Math.max(1, Math.ceil(total / pageSize))
    const pagina = Math.min(page, totalPaginas)

    return {
      items: resultado.recordset as ProductoListItem[],
      total,
      page: pagina,
      pageSize,
      totalPaginas
    }
  } catch (err) {
    console.error('[api/productos/get]', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'No se pudo consultar el listado de productos.'
    })
  }
})
