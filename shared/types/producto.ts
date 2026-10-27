// Tipos compartidos entre frontend y backend para la entidad productos

/** Fila del listado de productos (con nombres resueltos por JOIN) */
export interface ProductoListItem {
  id_producto: number
  sku: string
  nombre: string
  descripcion: string | null
  precio_base: number
  activo: boolean
  fecha_creacion: string
  id_categoria: number
  categoria: string
  id_marca: number | null
  marca: string | null
  id_vendedor: number | null
  vendedor: string | null
}

/** Payload de alta de producto */
export interface ProductoCreateInput {
  sku: string
  nombre: string
  id_categoria: number
  precio_base: number
  id_marca?: number | null
  id_vendedor?: number | null
  descripcion?: string | null
  peso_kg?: number | null
  largo_cm?: number | null
  ancho_cm?: number | null
  alto_cm?: number | null
}

/** Producto recién creado (respuesta del POST) */
export interface ProductoCreado {
  id_producto: number
  sku: string
  nombre: string
}
