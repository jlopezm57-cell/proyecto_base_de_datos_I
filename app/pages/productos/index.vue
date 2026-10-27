<script setup lang="ts">
// Listado de productos con búsqueda, filtro por categoría y paginación
import type { CategoriaOption, RespuestaPaginada } from '#shared/types/catalogo'
import type { ProductoListItem } from '#shared/types/producto'

useHead({ title: 'Productos — INTERCOMERCIO' })

const TAMANO_PAGINA = 10

const route = useRoute()
const { data: categorias } = await useFetch<CategoriaOption[]>('/api/categorias')

// Aviso de confirmación cuando se llega desde «Nuevo producto»
const skuCreado = ref(typeof route.query.creado === 'string' ? route.query.creado : '')

// Filtros aplicados y página actual
const filtros = ref<{ q: string; categoria: number | null }>({ q: '', categoria: null })
const pagina = ref(1)

// URL reactiva: cambiar filtros o página dispara el refetch
const urlListado = computed(() => {
  const params = new URLSearchParams()
  if (filtros.value.q) params.set('q', filtros.value.q)
  if (filtros.value.categoria) params.set('categoria', String(filtros.value.categoria))
  params.set('page', String(pagina.value))
  params.set('pageSize', String(TAMANO_PAGINA))
  return `/api/productos?${params.toString()}`
})

const { data, pending, error, refresh } = await useFetch<
  RespuestaPaginada<ProductoListItem>
>(urlListado)

const items = computed(() => data.value?.items ?? [])
const totalPaginas = computed(() => data.value?.totalPaginas ?? 1)
const total = computed(() => data.value?.total ?? 0)

const alBuscar = (nuevos: { q: string; categoria: number | null }) => {
  filtros.value = nuevos
  pagina.value = 1
  skuCreado.value = ''
}
</script>

<template>
  <div>
    <header class="page-header">
      <div>
        <h1>Productos</h1>
        <p class="page-sub">Catálogo de productos de INTERCOMERCIO</p>
      </div>
      <NuxtLink to="/productos/crear" class="btn btn-primario">+ Nuevo producto</NuxtLink>
    </header>

    <AppAlert v-if="skuCreado" tono="exito">
      Producto <strong>{{ skuCreado }}</strong> creado correctamente.
      <button type="button" class="link-accion" @click="skuCreado = ''">Ocultar</button>
    </AppAlert>

    <AppCard>
      <ProductoFiltros
        :categorias="categorias ?? []"
        :cargando="pending"
        @buscar="alBuscar"
      />
    </AppCard>

    <div class="seccion-tabla">
      <AppAlert v-if="error" tono="error">
        No se pudo consultar el listado de productos.
        <button type="button" class="link-accion" @click="refresh()">Reintentar</button>
      </AppAlert>

      <AppCard>
        <ProductoTabla :items="items" :cargando="pending" />

        <div v-if="items.length > 0" class="paginacion">
          <span class="paginacion-info">
            {{ total }} producto{{ total === 1 ? '' : 's' }} · Página {{ pagina }} de
            {{ totalPaginas }}
          </span>
          <div class="paginacion-botones">
            <AppButton
              variante="contorno"
              tamano="sm"
              :deshabilitado="pagina <= 1 || pending"
              @click="pagina--"
            >
              ← Anterior
            </AppButton>
            <AppButton
              variante="contorno"
              tamano="sm"
              :deshabilitado="pagina >= totalPaginas || pending"
              @click="pagina++"
            >
              Siguiente →
            </AppButton>
          </div>
        </div>
      </AppCard>
    </div>
  </div>
</template>

<style scoped>
.seccion-tabla {
  margin-top: var(--esp-4);
}

.seccion-tabla .paginacion {
  padding: var(--esp-4) 0 0;
  margin-top: 0;
}
</style>
