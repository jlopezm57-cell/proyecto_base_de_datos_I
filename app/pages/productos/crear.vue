<script setup lang="ts">
// Ruta de creación de productos
import type { ProductoCreado } from '#shared/types/producto'

useHead({ title: 'Nuevo producto — INTERCOMERCIO' })

// Tras crear, volvemos al listado mostrando un aviso de confirmación
const alCrear = async (producto: ProductoCreado) => {
  await navigateTo({ path: '/productos', query: { creado: producto.sku } })
}
</script>

<template>
  <div>
    <header class="page-header">
      <div>
        <h1>Nuevo producto</h1>
        <p class="page-sub">
          Completa los datos del producto. Si una categoría o marca no existe, puedes crearla
          desde el propio formulario.
        </p>
      </div>
      <NuxtLink to="/productos" class="btn btn-contorno">← Volver al listado</NuxtLink>
    </header>

    <AppCard>
      <ProductoForm @creado="alCrear" />
    </AppCard>
  </div>
</template>
