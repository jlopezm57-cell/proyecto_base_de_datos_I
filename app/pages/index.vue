<script setup lang="ts">
// Inicio: resumen general del catálogo
import type { Resumen } from '#shared/types/catalogo'

const { data: resumen, pending, error, refresh } = await useFetch<Resumen>('/api/resumen')

useHead({ title: 'INTERCOMERCIO — Panel' })
</script>

<template>
  <div>
    <section class="hero">
      <h1>Panel administrativo de INTERCOMERCIO</h1>
      <p>
        Gestiona el catálogo de productos de tu tienda: crea productos, organízalos por
        categorías y marcas, y controla la información que alimenta tu base de datos
        SQL&nbsp;Server.
      </p>
      <div class="hero-acciones">
        <NuxtLink to="/productos/crear" class="btn btn-primario">+ Crear producto</NuxtLink>
        <NuxtLink to="/productos" class="btn btn-contorno">Ver productos</NuxtLink>
      </div>
    </section>

    <AppAlert v-if="error" tono="error">
      No se pudo cargar el resumen de la base de datos.
      <button type="button" class="link-accion" @click="refresh()">Reintentar</button>
    </AppAlert>

    <div v-if="pending" class="carga-centro">
      <span class="spinner" aria-hidden="true" />
      Cargando resumen…
    </div>

    <div v-else-if="resumen" class="stats-grid">
      <AppCard>
        <p class="stat-valor">{{ resumen.productos }}</p>
        <p class="stat-etiqueta">Productos en el catálogo</p>
      </AppCard>
      <AppCard>
        <p class="stat-valor">{{ resumen.categorias }}</p>
        <p class="stat-etiqueta">Categorías</p>
      </AppCard>
      <AppCard>
        <p class="stat-valor">{{ resumen.marcas }}</p>
        <p class="stat-etiqueta">Marcas</p>
      </AppCard>
      <AppCard>
        <p class="stat-valor">{{ resumen.vendedores }}</p>
        <p class="stat-etiqueta">Vendedores</p>
      </AppCard>
    </div>
  </div>
</template>
