<script setup lang="ts">
// Modal para dar de alta una marca en línea y usarla de inmediato
import type { MarcaOption } from '#shared/types/catalogo'

const abierto = defineModel<boolean>({ default: false })
const emit = defineEmits<{ creada: [marca: MarcaOption] }>()

const nombre = ref('')
const paisOrigen = ref('')
const sitioWeb = ref('')
const error = ref<string | null>(null)
const cargando = ref(false)

watch(abierto, (valor) => {
  if (valor) {
    nombre.value = ''
    paisOrigen.value = ''
    sitioWeb.value = ''
    error.value = null
  }
})

const guardar = async () => {
  error.value = null
  if (!nombre.value.trim()) {
    error.value = 'El nombre de la marca es obligatorio.'
    return
  }
  cargando.value = true
  try {
    const marca = await $fetch<MarcaOption>('/api/marcas', {
      method: 'POST',
      body: {
        nombre: nombre.value,
        pais_origen: paisOrigen.value || null,
        sitio_web: sitioWeb.value || null
      }
    })
    emit('creada', marca)
    abierto.value = false
  } catch (err) {
    error.value = mensajeErrorApi(err)
  } finally {
    cargando.value = false
  }
}
</script>

<template>
  <AppModal v-model="abierto" titulo="Nueva marca">
    <form @submit.prevent="guardar">
      <AppAlert v-if="error" tono="error" :mensaje="error" />
      <div class="modal-campos">
        <AppInput
          v-model="nombre"
          etiqueta="Nombre"
          placeholder="Ej. Samsung"
          requerido
          :maxlength="100"
        />
        <AppInput
          v-model="paisOrigen"
          etiqueta="País de origen"
          placeholder="Opcional. Ej. Corea del Sur"
          :maxlength="100"
        />
        <AppInput
          v-model="sitioWeb"
          etiqueta="Sitio web"
          tipo="url"
          placeholder="Opcional. Ej. https://samsung.com"
          :maxlength="255"
        />
        <div class="form-acciones">
          <AppButton variante="contorno" @click="abierto = false">Cancelar</AppButton>
          <AppButton tipo="submit" :cargando="cargando">Guardar marca</AppButton>
        </div>
      </div>
    </form>
  </AppModal>
</template>

<style scoped>
.modal-campos {
  display: flex;
  flex-direction: column;
  gap: var(--esp-4);
}
</style>
