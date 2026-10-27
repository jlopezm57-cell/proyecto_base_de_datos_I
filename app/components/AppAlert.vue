<script setup lang="ts">
// Mensaje de alerta (error, éxito, info o aviso) con slot o mensaje
withDefaults(defineProps<{ tono?: 'error' | 'exito' | 'info' | 'aviso'; mensaje?: string }>(), {
  tono: 'info'
})
</script>

<template>
  <div class="alerta" :class="`alerta-${tono}`" role="alert">
    <p>{{ mensaje ?? '' }}<slot /></p>
  </div>
</template>
