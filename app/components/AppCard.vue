<script setup lang="ts">
// Tarjeta contenedora con cabecera opcional y acciones
defineProps<{ titulo?: string }>()
</script>

<template>
  <section class="card">
    <header v-if="titulo || $slots.acciones" class="card-header">
      <h2 v-if="titulo">{{ titulo }}</h2>
      <slot name="acciones" />
    </header>
    <div class="card-body">
      <slot />
    </div>
  </section>
</template>
