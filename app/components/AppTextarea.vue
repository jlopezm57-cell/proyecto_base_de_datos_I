<script setup lang="ts">
// Área de texto con etiqueta, ayuda y mensaje de error consistentes
defineProps<{
  etiqueta: string
  placeholder?: string
  requerido?: boolean
  error?: string | null
  ayuda?: string
  filas?: number
  maxlength?: number
}>()

const modelo = defineModel<string>({ default: '' })
</script>

<template>
  <div class="campo">
    <label class="etiqueta">
      {{ etiqueta }}
      <span v-if="requerido" class="obligatorio">*</span>
    </label>
    <textarea
      v-model="modelo"
      class="control"
      :class="{ 'control-error': error }"
      :placeholder="placeholder"
      :rows="filas ?? 4"
      :maxlength="maxlength"
      :required="requerido"
      :aria-invalid="!!error"
    />
    <p v-if="error" class="campo-error">{{ error }}</p>
    <p v-else-if="ayuda" class="campo-ayuda">{{ ayuda }}</p>
  </div>
</template>
