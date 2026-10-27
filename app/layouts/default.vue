<template>
  <div class="layout">
    <header class="site-header">
      <div class="container header-inner">
        <NuxtLink to="/" class="brand">INTERCOMERCIO</NuxtLink>
        <nav class="nav">
          <NuxtLink to="/">Inicio</NuxtLink>
          <NuxtLink to="/productos">Productos</NuxtLink>
          <NuxtLink to="/productos/crear" class="btn btn-primario btn-sm">+ Nuevo producto</NuxtLink>
        </nav>
      </div>
    </header>

    <main class="container main" style="padding: 20px;">
      <slot />
    </main>

    <footer class="site-footer">
      <div class="container">© {{ anio }} INTERCOMERCIO · Demo administrativa con Nuxt 4 + SQL Server</div>
    </footer>
  </div>
</template>

<script setup lang="ts">
const anio = new Date().getFullYear()
</script>
