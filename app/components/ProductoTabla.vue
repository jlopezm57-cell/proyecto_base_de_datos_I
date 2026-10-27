<script setup lang="ts">
// Tabla de listado de productos con estado vacío y de carga
import type { ProductoListItem } from '#shared/types/producto'

withDefaults(defineProps<{ items: ProductoListItem[]; cargando?: boolean }>(), {
  cargando: false
})
</script>

<template>
  <div class="tabla-envoltura">
    <div v-if="cargando" class="carga-centro">
      <span class="spinner" aria-hidden="true" />
      Cargando productos…
    </div>

    <div v-else-if="items.length === 0" class="vacio">
      <h3>No hay productos registrados</h3>
      <p>Crea el primer producto para empezar a poblar el catálogo.</p>
    </div>

    <table v-else class="tabla">
      <thead>
        <tr>
          <th>SKU</th>
          <th>Producto</th>
          <th>Categoría</th>
          <th>Marca</th>
          <th>Vendedor</th>
          <th class="celda-numero">Precio</th>
          <th>Estado</th>
          <th>Creado</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="producto in items" :key="producto.id_producto">
          <td class="celda-sku">{{ producto.sku }}</td>
          <td>
            <strong>{{ producto.nombre }}</strong>
            <div v-if="producto.descripcion" class="celda-secundaria">
              {{ producto.descripcion.slice(0, 60) }}{{ producto.descripcion.length > 60 ? '…' : '' }}
            </div>
          </td>
          <td>{{ producto.categoria }}</td>
          <td>{{ producto.marca ?? '—' }}</td>
          <td>{{ producto.vendedor ?? '—' }}</td>
          <td class="celda-numero">{{ formatoMoneda(Number(producto.precio_base)) }}</td>
          <td>
            <AppBadge :tono="producto.activo ? 'exito' : 'neutro'">
              {{ producto.activo ? 'Activo' : 'Inactivo' }}
            </AppBadge>
          </td>
          <td class="celda-secundaria">{{ formatoFecha(producto.fecha_creacion) }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
