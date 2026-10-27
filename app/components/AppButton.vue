<script setup lang="ts">
// Botón reutilizable con variantes, tamaños y estado de carga
withDefaults(
  defineProps<{
    variante?: 'primario' | 'contorno' | 'texto'
    tamano?: 'sm' | 'md'
    tipo?: 'button' | 'submit'
    cargando?: boolean
    deshabilitado?: boolean
  }>(),
  {
    variante: 'primario',
    tamano: 'md',
    tipo: 'button',
    cargando: false,
    deshabilitado: false
  }
)
</script>

<template>
  <button
    :type="tipo"
    class="btn"
    :class="[`btn-${variante}`, { 'btn-sm': tamano === 'sm' }]"
    :disabled="deshabilitado || cargando"
  >
    <span v-if="cargando" class="spinner" aria-hidden="true" />
    <slot />
  </button>
</template>
