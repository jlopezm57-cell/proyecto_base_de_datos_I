// Validadores reutilizables para los handlers de la API.
// Todas las validaciones lanzan errores H3 con statusCode 400.
import { createError, H3Error } from 'h3'

export function errorValidacion(mensaje: string, campo?: string): H3Error {
  return createError({ statusCode: 400, statusMessage: mensaje, data: { campo } })
}

/** Texto obligatorio, recortado y con longitud máxima */
export function textoRequerido(valor: unknown, campo: string, max: number): string {
  const texto = typeof valor === 'string' ? valor.trim() : ''
  if (!texto) throw errorValidacion(`El campo «${campo}» es obligatorio.`, campo)
  if (texto.length > max) {
    throw errorValidacion(`El campo «${campo}» no puede superar los ${max} caracteres.`, campo)
  }
  return texto
}

/** Texto opcional: vacíos y null quedan como null */
export function textoOpcional(valor: unknown, campo: string, max: number): string | null {
  if (valor === null || valor === undefined) return null
  const texto = typeof valor === 'string' ? valor.trim() : ''
  if (!texto) return null
  if (texto.length > max) {
    throw errorValidacion(`El campo «${campo}» no puede superar los ${max} caracteres.`, campo)
  }
  return texto
}

/** Entero positivo (ids) */
export function enteroPositivo(valor: unknown, campo: string): number {
  const numero = Number(valor)
  if (!Number.isInteger(numero) || numero <= 0) {
    throw errorValidacion(`El campo «${campo}» debe ser un identificador válido.`, campo)
  }
  return numero
}

/** Entero positivo opcional: null, undefined y '' quedan como null */
export function enteroPositivoOpcional(valor: unknown, campo: string): number | null {
  if (valor === null || valor === undefined || valor === '') return null
  return enteroPositivo(valor, campo)
}

/** Decimal obligatorio con mínimo opcional */
export function decimalRequerido(valor: unknown, campo: string, min = 0): number {
  const numero = Number(valor)
  if (valor === null || valor === undefined || valor === '' || !Number.isFinite(numero)) {
    throw errorValidacion(`El campo «${campo}» debe ser un número.`, campo)
  }
  if (numero < min) {
    throw errorValidacion(`El campo «${campo}» no puede ser menor que ${min}.`, campo)
  }
  return numero
}

/** Decimal opcional: vacíos y null quedan como null */
export function decimalOpcional(valor: unknown, campo: string, min = 0): number | null {
  if (valor === null || valor === undefined || valor === '') return null
  return decimalRequerido(valor, campo, min)
}

/** ¿Es un error H3 ya controlado (validaciones 4xx)? */
export function esErrorH3(err: unknown): err is H3Error {
  return err instanceof H3Error && err.statusCode < 500
}

/** ¿Es un error de violación de restricción UNIQUE de SQL Server? */
export function esErrorDuplicado(err: unknown): boolean {
  const e = err as { number?: number; message?: string }
  if (typeof e?.number === 'number' && (e.number === 2627 || e.number === 2601)) return true
  return /UNIQUE KEY|duplicate key|unique constraint/i.test(e?.message ?? '')
}

/** ¿Es un error de violación de FOREIGN KEY / CHECK de SQL Server? */
export function esErrorForeignkey(err: unknown): boolean {
  const e = err as { number?: number; message?: string }
  if (typeof e?.number === 'number' && e.number === 547) return true
  return /FOREIGN KEY|CHECK constraint/i.test(e?.message ?? '')
}

/** Devuelve el número de error de SQL Server si existe */
export function numeroErrorSql(err: unknown): number | undefined {
  return (err as { number?: number })?.number
}
