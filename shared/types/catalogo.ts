// Tipos compartidos entre frontend y backend para catálogos y utilidades de respuesta

export interface CategoriaOption {
  id_categoria: number
  nombre: string
  descripcion: string | null
  slug: string | null
}

export interface MarcaOption {
  id_marca: number
  nombre: string
  pais_origen: string | null
  sitio_web: string | null
}

export interface VendedorOption {
  id_vendedor: number
  nombre: string
  apellido: string
  email: string | null
}

/** Opción genérica para usar en selects del frontend */
export interface OpcionSelect {
  valor: number
  etiqueta: string
}

/** Respuesta estándar de los listados paginados */
export interface RespuestaPaginada<T> {
  items: T[]
  total: number
  page: number
  pageSize: number
  totalPaginas: number
}

/** Conteos del panel de inicio */
export interface Resumen {
  productos: number
  categorias: number
  marcas: number
  vendedores: number
}
