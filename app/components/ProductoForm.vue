<script setup lang="ts">
// Formulario de alta de producto, autocontenido:
// - carga los catálogos (categorías, marcas, vendedores) desde la API
// - permite crear categorías y marcas en línea con modales
// - valida en cliente y envía a POST /api/productos
import type {
  CategoriaOption,
  MarcaOption,
  OpcionSelect,
  VendedorOption
} from '#shared/types/catalogo'
import type { ProductoCreado, ProductoCreateInput } from '#shared/types/producto'

const emit = defineEmits<{ creado: [producto: ProductoCreado] }>()

// Catálogos
const { data: categorias, refresh: refrescarCategorias, error: errorCategorias } =
  await useFetch<CategoriaOption[]>('/api/categorias')
const { data: marcas, refresh: refrescarMarcas, error: errorMarcas } =
  await useFetch<MarcaOption[]>('/api/marcas')
const { data: vendedores, error: errorVendedores } =
  await useFetch<VendedorOption[]>('/api/vendedores')

const errorCatalogos = computed(() =>
  errorCategorias.value || errorMarcas.value || errorVendedores.value
    ? 'No se pudieron cargar los catálogos. Verifica que la base de datos esté disponible.'
    : null
)

const opcionesCategorias = computed<OpcionSelect[]>(() =>
  (categorias.value ?? []).map((c) => ({ valor: c.id_categoria, etiqueta: c.nombre }))
)
const opcionesMarcas = computed<OpcionSelect[]>(() =>
  (marcas.value ?? []).map((m) => ({ valor: m.id_marca, etiqueta: m.nombre }))
)
const opcionesVendedores = computed<OpcionSelect[]>(() =>
  (vendedores.value ?? []).map((v) => ({
    valor: v.id_vendedor,
    etiqueta: `${v.nombre} ${v.apellido}`
  }))
)

// Estado del formulario. Todos los campos se guardan como texto (AppInput
// garantiza strings, incluso en los <input type="number">) y se convierten a
// número al construir el payload.
const form = reactive({
  sku: '',
  nombre: '',
  id_categoria: 0,
  id_marca: 0,
  id_vendedor: 0,
  precio_base: '',
  descripcion: '',
  peso_kg: '',
  largo_cm: '',
  ancho_cm: '',
  alto_cm: ''
})

const errores = ref<Record<string, string>>({})
const cargando = ref(false)
const errorServidor = ref<string | null>(null)

// Modales de catálogo en línea
const modalCategoria = ref(false)
const modalMarca = ref(false)

const alCrearCategoria = async (categoria: CategoriaOption) => {
  modalCategoria.value = false
  await refrescarCategorias()
  form.id_categoria = categoria.id_categoria
}

const alCrearMarca = async (marca: MarcaOption) => {
  modalMarca.value = false
  await refrescarMarcas()
  form.id_marca = marca.id_marca
}

// Validación en cliente (la API también valida en el servidor)
/**
 * Los campos numéricos pueden llegar como `number` (los <input type="number">
 * nativos convierten su valor), así que todo se normaliza a texto antes de validar.
 */
const texto = (valor: unknown): string => (valor === null || valor === undefined ? '' : String(valor))

const validar = (): boolean => {
  const erroresLocal: Record<string, string> = {}

  const sku = texto(form.sku).trim()
  if (!sku) erroresLocal.sku = 'El SKU es obligatorio.'
  else if (sku.length > 50) erroresLocal.sku = 'El SKU no puede superar los 50 caracteres.'

  const nombre = texto(form.nombre).trim()
  if (!nombre) erroresLocal.nombre = 'El nombre es obligatorio.'
  else if (nombre.length > 200) erroresLocal.nombre = 'El nombre no puede superar los 200 caracteres.'

  if (!form.id_categoria) erroresLocal.id_categoria = 'Selecciona una categoría.'

  const precioBase = texto(form.precio_base).trim()
  if (precioBase === '') {
    erroresLocal.precio_base = 'El precio es obligatorio.'
  } else {
    const precio = Number(precioBase)
    if (!Number.isFinite(precio) || precio < 0) {
      erroresLocal.precio_base = 'El precio debe ser un número mayor o igual a 0.'
    }
  }

  for (const campo of ['peso_kg', 'largo_cm', 'ancho_cm', 'alto_cm'] as const) {
    const valor = texto(form[campo]).trim()
    if (valor !== '') {
      const numero = Number(valor)
      if (!Number.isFinite(numero) || numero < 0) {
        erroresLocal[campo] = 'Debe ser un número mayor o igual a 0.'
      }
    }
  }

  errores.value = erroresLocal
  return Object.keys(erroresLocal).length === 0
}

const numeroOpcional = (valor: unknown): number | null => {
  const limpio = texto(valor).trim()
  return limpio === '' ? null : Number(limpio)
}

const enviar = async () => {
  errorServidor.value = null
  if (!validar()) return

  cargando.value = true
  try {
    const payload: ProductoCreateInput = {
      sku: form.sku.trim(),
      nombre: form.nombre.trim(),
      id_categoria: form.id_categoria,
      id_marca: form.id_marca || null,
      id_vendedor: form.id_vendedor || null,
      precio_base: Number(form.precio_base),
      descripcion: form.descripcion.trim() || null,
      peso_kg: numeroOpcional(form.peso_kg),
      largo_cm: numeroOpcional(form.largo_cm),
      ancho_cm: numeroOpcional(form.ancho_cm),
      alto_cm: numeroOpcional(form.alto_cm)
    }
    const respuesta = await $fetch<{ ok: true; producto: ProductoCreado }>('/api/productos', {
      method: 'POST',
      body: payload
    })
    emit('creado', respuesta.producto)
  } catch (err) {
    errorServidor.value = mensajeErrorApi(err)
  } finally {
    cargando.value = false
  }
}
</script>

<template>
  <form class="form-producto" novalidate @submit.prevent="enviar">
    <AppAlert v-if="errorCatalogos" tono="aviso" :mensaje="errorCatalogos" />
    <AppAlert v-if="errorServidor" tono="error" :mensaje="errorServidor" />

    <div class="form-grid">
      <AppInput
        v-model="form.sku"
        etiqueta="SKU"
        placeholder="Ej. SKU-0001"
        requerido
        :maxlength="50"
        :error="errores.sku"
        ayuda="Identificador único del producto."
      />
      <AppInput
        v-model="form.nombre"
        etiqueta="Nombre"
        placeholder="Ej. Laptop Gamer 15&quot;"
        requerido
        :maxlength="200"
        :error="errores.nombre"
      />
      <AppSelect
        v-model="form.id_categoria"
        etiqueta="Categoría"
        :opciones="opcionesCategorias"
        placeholder="Selecciona una categoría"
        requerido
        :error="errores.id_categoria"
      >
        <template #acciones>
          <button type="button" class="link-accion" @click="modalCategoria = true">+ Nueva</button>
        </template>
      </AppSelect>
      <AppSelect
        v-model="form.id_marca"
        etiqueta="Marca"
        :opciones="opcionesMarcas"
        placeholder="Sin marca"
        :error="errores.id_marca"
      >
        <template #acciones>
          <button type="button" class="link-accion" @click="modalMarca = true">+ Nueva</button>
        </template>
      </AppSelect>
      <AppSelect
        v-model="form.id_vendedor"
        etiqueta="Vendedor"
        :opciones="opcionesVendedores"
        placeholder="Sin vendedor"
        :deshabilitado="opcionesVendedores.length === 0"
        :ayuda="
          opcionesVendedores.length === 0
            ? 'Aún no hay vendedores registrados; puedes dejarlo vacío.'
            : undefined
        "
      />
      <AppInput
        v-model="form.precio_base"
        etiqueta="Precio base (GTQ)"
        tipo="number"
        paso="0.01"
        placeholder="0.00"
        requerido
        :error="errores.precio_base"
      />
    </div>

    <div class="form-seccion">
      <div class="form-seccion-titulo">
        <h3>Peso y dimensiones</h3>
        <p>Opcional. Útil para el cálculo de envíos.</p>
      </div>
      <div class="form-grid">
        <AppInput
          v-model="form.peso_kg"
          etiqueta="Peso (kg)"
          tipo="number"
          paso="0.001"
          placeholder="0.000"
          :error="errores.peso_kg"
        />
        <AppInput
          v-model="form.largo_cm"
          etiqueta="Largo (cm)"
          tipo="number"
          paso="0.01"
          placeholder="0.00"
          :error="errores.largo_cm"
        />
        <AppInput
          v-model="form.ancho_cm"
          etiqueta="Ancho (cm)"
          tipo="number"
          paso="0.01"
          placeholder="0.00"
          :error="errores.ancho_cm"
        />
        <AppInput
          v-model="form.alto_cm"
          etiqueta="Alto (cm)"
          tipo="number"
          paso="0.01"
          placeholder="0.00"
          :error="errores.alto_cm"
        />
      </div>
    </div>

    <div class="form-descripcion">
      <AppTextarea
        v-model="form.descripcion"
        etiqueta="Descripción"
        placeholder="Descripción del producto para el catálogo…"
        :filas="5"
        :maxlength="5000"
      />
    </div>

    <div class="form-acciones">
      <NuxtLink to="/productos" class="btn btn-contorno">Cancelar</NuxtLink>
      <AppButton tipo="submit" :cargando="cargando">Guardar producto</AppButton>
    </div>

    <CategoriaModal v-model="modalCategoria" @creada="alCrearCategoria" />
    <MarcaModal v-model="modalMarca" @creada="alCrearMarca" />
  </form>
</template>

<style scoped>
.form-producto {
  display: flex;
  flex-direction: column;
  gap: var(--esp-5);
}

.form-producto .form-acciones {
  margin-top: 0;
}

.form-descripcion {
  max-width: 100%;
}
</style>
