<script setup lang="ts">
// Modal con teleport, cierre con ESC y clic en el fondo
const abierto = defineModel<boolean>({ default: false })
defineProps<{ titulo: string }>()

const cerrar = () => {
  abierto.value = false
}

const alTeclear = (event: KeyboardEvent) => {
  if (event.key === 'Escape') cerrar()
}

watch(abierto, (valor) => {
  if (import.meta.client) {
    if (valor) window.addEventListener('keydown', alTeclear)
    else window.removeEventListener('keydown', alTeclear)
  }
})

onUnmounted(() => {
  if (import.meta.client) window.removeEventListener('keydown', alTeclear)
})
</script>

<template>
  <Teleport to="body">
    <div v-if="abierto" class="modal-fondo" @click.self="cerrar">
      <div class="modal" role="dialog" aria-modal="true" :aria-label="titulo">
        <header class="modal-cabecera">
          <h3>{{ titulo }}</h3>
          <button type="button" class="modal-cerrar" aria-label="Cerrar" @click="cerrar">✕</button>
        </header>
        <div class="modal-cuerpo">
          <slot />
        </div>
      </div>
    </div>
  </Teleport>
</template>
