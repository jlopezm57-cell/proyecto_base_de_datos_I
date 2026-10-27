// Utilidades de formato para el frontend (auto-importadas)

/** Formatea un número como moneda GTQ: GTQ 1,234.56 */
export function formatoMoneda(valor: number): string {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'GTQ',
    minimumFractionDigits: 2
  }).format(valor)
}

/** Formatea una fecha (string ISO o Date) como fecha legible en es-GT */
export function formatoFecha(valor: string | Date): string {
  const fecha = valor instanceof Date ? valor : new Date(valor)
  if (Number.isNaN(fecha.getTime())) return '—'
  return new Intl.DateTimeFormat('es-GT', { dateStyle: 'medium' }).format(fecha)
}

/** Convierte el error de $fetch en un mensaje legible para el usuario */
export function mensajeErrorApi(err: unknown): string {
  const data = (err as { data?: { statusMessage?: string; message?: string } })?.data
  const mensaje = data?.statusMessage || data?.message
  if (mensaje && !/^H3Error/i.test(mensaje)) return mensaje
  return 'No se pudo completar la operación. Verifica la conexión con la base de datos e inténtalo de nuevo.'
}
