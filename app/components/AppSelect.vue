<script setup lang="ts">
// Selector con etiqueta, opción placeholder (valor 0), ayuda y error
// Slot `acciones` para botones junto a la etiqueta (ej. "+ Nueva")
import type { OpcionSelect } from '#shared/types/catalogo'

defineProps<{
  etiqueta: string
  opciones: OpcionSelect[]
  placeholder?: string
  requerido?: boolean
  error?: string | null
  ayuda?: string
  deshabilitado?: boolean
}>()

const modelo = defineModel<number>({ default: 0 })
</script>

<template>
  <div class="campo">
    <div class="campo-etiqueta-fila">
      <label class="etiqueta">
        {{ etiqueta }}
        <span v-if="requerido" class="obligatorio">*</span>
      </label>
      <slot name="acciones" />
    </div>
    <select
      v-model="modelo"
      class="control"
      :class="{ 'control-error': error }"
      :disabled="deshabilitado"
      :required="requerido"
      :aria-invalid="!!error"
    >
      <option v-if="placeholder" :value="0">{{ placeholder }}</option>
      <option v-for="op in opciones" :key="op.valor" :value="op.valor">
        {{ op.etiqueta }}
      </option>
    </select>
    <p v-if="error" class="campo-error">{{ error }}</p>
    <p v-else-if="ayuda" class="campo-ayuda">{{ ayuda }}</p>
  </div>
</template>
