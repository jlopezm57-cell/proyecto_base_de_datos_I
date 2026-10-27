// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  css: ['~/assets/css/main.css'],
  typescript: { strict: true }
  // Nota: NO se configura `nitro.externals` para `mssql` / `msnodesqlv8`.
  // Nitro ya traza la dependencia y copia el binario nativo a `.output/server/node_modules`.
  // Si se necesita excluir algo, `nitro.externals` debe ser un objeto ({ external: [...] }):
  // un array rompe el trazado de dependencias y deja todas las páginas SSR en 500.
})
