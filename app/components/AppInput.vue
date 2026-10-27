<script setup lang="ts">
// Entrada de texto o número con etiqueta, ayuda y mensaje de error consistentes.
//
// Contrato: el valor del modelo SIEMPRE es un string.
// Por eso se enlaza con `:value` + `@input` en lugar de `v-model`: Vue convierte
// automáticamente a Number los <input type="number"> (vModelText usa
// `castToNumber = number || type === 'number'`), lo que rompería este contrato y
// haría fallar las validaciones que trabajan con texto (`valor.trim()`).
defineProps<{
  etiqueta: string
  placeholder?: string
  requerido?: boolean
  error?: string | null
  ayuda?: string
  /** `text`, `number`, `email`, `date`… El valor se recibe siempre como string. */
  tipo?: string
  maxlength?: number
  /** Atributo `step` (solo aplica a `type="number"`) */
  paso?: string
}>()

const modelo = defineModel<string>({ default: '' })

const alEscribir = (evento: Event) => {
  modelo.value = (evento.target as HTMLInputElement).value
}
</script>

<template>
  <div class="campo">
    <label class="etiqueta">
      {{ etiqueta }}
      <span v-if="requerido" class="obligatorio">*</span>
    </label>
    <input
      :value="modelo"
      class="control"
      :class="{ 'control-error': error }"
      :type="tipo ?? 'text'"
      :placeholder="placeholder"
      :maxlength="maxlength"
      :step="paso"
      :required="requerido"
      :aria-invalid="!!error"
      @input="alEscribir"
    >
    <p v-if="error" class="campo-error">{{ error }}</p>
    <p v-else-if="ayuda" class="campo-ayuda">{{ ayuda }}</p>
  </div>
</template>
