<script setup lang="ts">
// Filtros del listado de productos (búsqueda + categoría).
// Mantiene el estado "borrador" y emite los filtros aplicados al buscar.
import type { CategoriaOption, OpcionSelect } from '#shared/types/catalogo'

const props = defineProps<{ categorias: CategoriaOption[]; cargando?: boolean }>()
const emit = defineEmits<{ buscar: [filtros: { q: string; categoria: number | null }] }>()

const q = ref('')
const categoria = ref(0)

const opciones = computed<OpcionSelect[]>(() =>
  props.categorias.map((c) => ({ valor: c.id_categoria, etiqueta: c.nombre }))
)

const buscar = () => {
  emit('buscar', {
    q: q.value.trim(),
    categoria: categoria.value > 0 ? categoria.value : null
  })
}

const limpiar = () => {
  q.value = ''
  categoria.value = 0
  buscar()
}
</script>

<template>
  <form class="filtros" @submit.prevent="buscar">
    <AppInput
      v-model="q"
      etiqueta="Buscar"
      placeholder="Por nombre o SKU…"
      :maxlength="100"
    />
    <AppSelect
      v-model="categoria"
      etiqueta="Categoría"
      :opciones="opciones"
      placeholder="Todas las categorías"
    />
    <div class="filtros-acciones">
      <AppButton tipo="submit" :cargando="cargando">Buscar</AppButton>
      <AppButton variante="texto" @click="limpiar">Limpiar</AppButton>
    </div>
  </form>
</template>
