<script setup lang="ts">
// Insignia de estado con tonos predefinidos
withDefaults(defineProps<{ tono?: 'exito' | 'neutro' | 'primario' | 'advertencia' }>(), {
  tono: 'neutro'
})
</script>

<template>
  <span class="badge" :class="`badge-${tono}`">
    <slot />
  </span>
</template>
