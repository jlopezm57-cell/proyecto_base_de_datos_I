// PUT /api/productos/:id — Actualizar producto (llama a sp_Productos_Actualizar)
import { createError, getRouterParam, readBody } from 'h3'
import { getPool, sql } from '../../utils/db'
import {
  decimalOpcional,
  decimalRequerido,
  enteroPositivo,
  enteroPositivoOpcional,
  esErrorForeignkey,
  esErrorH3,
  numeroErrorSql,
  textoOpcional,
  textoRequerido
} from '../../utils/validacion'
import type { ProductoCreado } from '#shared/types/producto'

export default defineEventHandler(async (event) => {
  const idRaw = getRouterParam(event, 'id')
  const idProducto = Number(idRaw)
  if (!Number.isInteger(idProducto) || idProducto <= 0) {
    throw createError({ statusCode: 400, statusMessage: 'ID de producto inválido.' })
  }

  const body = await readBody<unknown>(event)
  if (!body || typeof body !== 'object') {
    throw createError({ statusCode: 400, statusMessage: 'Cuerpo de la petición inválido.' })
  }
  const datos = body as Record<string, unknown>

  try {
    // Validación de entrada
    const sku = textoRequerido(datos.sku, 'SKU', 50)
    const nombre = textoRequerido(datos.nombre, 'Nombre', 200)
    const idCategoria = enteroPositivo(datos.id_categoria, 'Categoría')
    const idMarca = enteroPositivoOpcional(datos.id_marca, 'Marca')
    const idVendedor = enteroPositivoOpcional(datos.id_vendedor, 'Vendedor')
    const descripcion = textoOpcional(datos.descripcion, 'Descripción', 5000)
    const precioBase = decimalRequerido(datos.precio_base, 'Precio base', 0)
    const pesoKg = decimalOpcional(datos.peso_kg, 'Peso', 0)
    const largoCm = decimalOpcional(datos.largo_cm, 'Largo', 0)
    const anchoCm = decimalOpcional(datos.ancho_cm, 'Ancho', 0)
    const altoCm = decimalOpcional(datos.alto_cm, 'Alto', 0)

    const pool = await getPool()
    const resultado = await pool.request()
      .input('id_producto', sql.Int, idProducto)
      .input('id_categoria', sql.Int, idCategoria)
      .input('id_marca', sql.Int, idMarca)
      .input('id_vendedor', sql.Int, idVendedor)
      .input('sku', sql.NVarChar(50), sku)
      .input('nombre', sql.NVarChar(200), nombre)
      .input('descripcion', sql.NVarChar(sql.MAX), descripcion)
      .input('precio_base', sql.Decimal(18, 2), precioBase)
      .input('peso_kg', sql.Decimal(10, 3), pesoKg)
      .input('largo_cm', sql.Decimal(10, 2), largoCm)
      .input('ancho_cm', sql.Decimal(10, 2), anchoCm)
      .input('alto_cm', sql.Decimal(10, 2), altoCm)
      .query(`
        EXEC dbo.sp_Productos_Actualizar
          @id_producto, @id_categoria, @id_marca, @id_vendedor, @sku, @nombre, @descripcion,
          @precio_base, @peso_kg, @largo_cm, @ancho_cm, @alto_cm
      `)

    if (resultado.recordset.length === 0) {
      throw createError({ statusCode: 404, statusMessage: 'Producto no encontrado.' })
    }

    const producto = resultado.recordset[0] as ProductoCreado
    return { ok: true as const, producto }
  } catch (err) {
    if (esErrorH3(err)) throw err
    const sqlErrNum = numeroErrorSql(err)
    if (sqlErrNum === 50023) {
      throw createError({
        statusCode: 409,
        statusMessage: 'Ya existe otro producto con ese SKU.'
      })
    }
    if (sqlErrNum === 50022) {
      throw createError({ statusCode: 404, statusMessage: 'Producto no encontrado.' })
    }
    if (sqlErrNum === 547 || /FOREIGN KEY|CHECK constraint/i.test((err as { message?: string }).message ?? '')) {
      throw createError({
        statusCode: 400,
        statusMessage: 'La categoría, marca o vendedor seleccionado no existe.'
      })
    }
    console.error('[api/productos/put]', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'No se pudo actualizar el producto.'
    })
  }
})
