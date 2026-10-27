<script setup lang="ts">
// Modal para dar de alta una categoría en línea y usarla de inmediato
import type { CategoriaOption } from '#shared/types/catalogo'

const abierto = defineModel<boolean>({ default: false })
const emit = defineEmits<{ creada: [categoria: CategoriaOption] }>()

const nombre = ref('')
const slug = ref('')
const descripcion = ref('')
const error = ref<string | null>(null)
const cargando = ref(false)

watch(abierto, (valor) => {
  if (valor) {
    nombre.value = ''
    slug.value = ''
    descripcion.value = ''
    error.value = null
  }
})

const guardar = async () => {
  error.value = null
  if (!nombre.value.trim()) {
    error.value = 'El nombre de la categoría es obligatorio.'
    return
  }
  cargando.value = true
  try {
    const categoria = await $fetch<CategoriaOption>('/api/categorias', {
      method: 'POST',
      body: {
        nombre: nombre.value,
        slug: slug.value || null,
        descripcion: descripcion.value || null
      }
    })
    emit('creada', categoria)
    abierto.value = false
  } catch (err) {
    error.value = mensajeErrorApi(err)
  } finally {
    cargando.value = false
  }
}
</script>

<template>
  <AppModal v-model="abierto" titulo="Nueva categoría">
    <form @submit.prevent="guardar">
      <AppAlert v-if="error" tono="error" :mensaje="error" />
      <div class="modal-campos">
        <AppInput
          v-model="nombre"
          etiqueta="Nombre"
          placeholder="Ej. Electrónica"
          requerido
          :maxlength="100"
        />
        <AppInput
          v-model="slug"
          etiqueta="Slug"
          placeholder="electronica"
          ayuda="Se genera automáticamente si lo dejas vacío."
          :maxlength="100"
        />
        <AppTextarea
          v-model="descripcion"
          etiqueta="Descripción"
          placeholder="Descripción opcional de la categoría"
          :filas="3"
          :maxlength="500"
        />
        <div class="form-acciones">
          <AppButton variante="contorno" @click="abierto = false">Cancelar</AppButton>
          <AppButton tipo="submit" :cargando="cargando">Guardar categoría</AppButton>
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
