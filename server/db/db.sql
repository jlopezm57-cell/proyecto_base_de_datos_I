-- ============================================================================
-- Script DDL simplificado: Base de datos INTERCOMERCIO
-- Todas las tablas del esquema original, formato simple para practica.
-- Sin COLLATE, sin CHECK, sin UNIQUE, sin índices extra.
-- Solo PRIMARY KEY y FOREIGN KEY básicas.
-- ============================================================================

-- Crear la base de datos si no existe
IF DB_ID(N'INTERCOMERCIO') IS NULL
    CREATE DATABASE INTERCOMERCIO;
GO

USE INTERCOMERCIO;
GO

-- ============================================================================
-- 1. Seguridad y usuarios
-- ============================================================================

-- Tabla: roles
CREATE TABLE dbo.roles (
    id_rol INT PRIMARY KEY IDENTITY(1,1),
    nombre_rol VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    activo BIT NOT NULL DEFAULT 1
);
GO

-- Tabla: usuarios
CREATE TABLE dbo.usuarios (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    nombre_usuario VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    activo BIT NOT NULL DEFAULT 1
);
GO

-- Tabla: usuarios_roles
CREATE TABLE dbo.usuarios_roles (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    fecha_asignacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    PRIMARY KEY (id_usuario, id_rol),
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id_usuario),
    FOREIGN KEY (id_rol) REFERENCES dbo.roles(id_rol)
);
GO

-- ============================================================================
-- 2. Vendedores
-- ============================================================================

-- Tabla: vendedores
CREATE TABLE dbo.vendedores (
    id_vendedor INT PRIMARY KEY IDENTITY(1,1),
    id_usuario INT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(30) NULL,
    email VARCHAR(100) NULL,
    tiene_comision BIT NOT NULL DEFAULT 0,
    porcentaje_comision DECIMAL(5,2) NULL,
    fecha_alta DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    activo BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id_usuario)
);
GO

-- ============================================================================
-- 3. Clientes y direcciones
-- ============================================================================

-- Tabla: clientes
CREATE TABLE dbo.clientes (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    id_usuario INT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(30) NULL,
    email VARCHAR(100) NULL,
    fecha_registro DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    activo BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id_usuario)
);
GO

-- Tabla: direcciones
CREATE TABLE dbo.direcciones (
    id_direccion INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,
    tipo_direccion VARCHAR(20) NOT NULL DEFAULT 'Envío',
    nombre_referencia VARCHAR(100) NULL,
    calle VARCHAR(150) NOT NULL,
    numero_exterior VARCHAR(20) NULL,
    numero_interior VARCHAR(20) NULL,
    colonia VARCHAR(100) NULL,
    ciudad VARCHAR(100) NOT NULL,
    estado VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(20) NOT NULL,
    pais VARCHAR(100) NOT NULL DEFAULT 'Guatemala',
    es_predeterminada BIT NOT NULL DEFAULT 0,
    activo BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_cliente) REFERENCES dbo.clientes(id_cliente)
);
GO

-- ============================================================================
-- 4. Almacenes / Sucursales
-- ============================================================================

-- Tabla: almacenes
CREATE TABLE dbo.almacenes (
    id_almacen INT PRIMARY KEY IDENTITY(1,1),
    codigo_almacen VARCHAR(20) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    direccion VARCHAR(255) NULL,
    ciudad VARCHAR(100) NULL,
    estado VARCHAR(100) NULL,
    pais VARCHAR(100) NOT NULL DEFAULT 'Guatemala',
    telefono VARCHAR(30) NULL,
    activo BIT NOT NULL DEFAULT 1
);
GO

-- ============================================================================
-- 5. Catálogo de productos
-- ============================================================================

-- Tabla: categorias
CREATE TABLE dbo.categorias (
    id_categoria INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500) NULL,
    slug VARCHAR(100) NULL,
    activo BIT NOT NULL DEFAULT 1
);
GO

-- Tabla: marcas
CREATE TABLE dbo.marcas (
    id_marca INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    pais_origen VARCHAR(100) NULL,
    sitio_web VARCHAR(255) NULL,
    activo BIT NOT NULL DEFAULT 1
);
GO

-- Tabla: productos
CREATE TABLE dbo.productos (
    id_producto INT PRIMARY KEY IDENTITY(1,1),
    id_categoria INT NOT NULL,
    id_marca INT NULL,
    id_vendedor INT NULL,
    sku VARCHAR(50) NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion VARCHAR(MAX) NULL,
    precio_base DECIMAL(18,2) NOT NULL DEFAULT 0,
    peso_kg DECIMAL(10,3) NULL,
    largo_cm DECIMAL(10,2) NULL,
    ancho_cm DECIMAL(10,2) NULL,
    alto_cm DECIMAL(10,2) NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    FOREIGN KEY (id_categoria) REFERENCES dbo.categorias(id_categoria),
    FOREIGN KEY (id_marca) REFERENCES dbo.marcas(id_marca),
    FOREIGN KEY (id_vendedor) REFERENCES dbo.vendedores(id_vendedor)
);
GO

-- Tabla: variantes_producto
CREATE TABLE dbo.variantes_producto (
    id_variante INT PRIMARY KEY IDENTITY(1,1),
    id_producto INT NOT NULL,
    nombre_variante VARCHAR(100) NOT NULL,
    sku_variante VARCHAR(50) NULL,
    precio_ajuste DECIMAL(18,2) NOT NULL DEFAULT 0,
    activo BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_producto) REFERENCES dbo.productos(id_producto)
);
GO

-- ============================================================================
-- 6. Inventario por almacén / sucursal
-- ============================================================================

-- Tabla: inventario
CREATE TABLE dbo.inventario (
    id_inventario INT PRIMARY KEY IDENTITY(1,1),
    id_almacen INT NOT NULL,
    id_producto INT NOT NULL,
    id_variante INT NULL,
    cantidad_disponible INT NOT NULL DEFAULT 0,
    cantidad_reservada INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 0,
    stock_maximo INT NULL,
    ubicacion_pasillo VARCHAR(20) NULL,
    ubicacion_estante VARCHAR(20) NULL,
    fecha_actualizacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    FOREIGN KEY (id_almacen) REFERENCES dbo.almacenes(id_almacen),
    FOREIGN KEY (id_producto) REFERENCES dbo.productos(id_producto),
    FOREIGN KEY (id_variante) REFERENCES dbo.variantes_producto(id_variante)
);
GO

-- Tabla: movimientos_inventario
CREATE TABLE dbo.movimientos_inventario (
    id_movimiento INT PRIMARY KEY IDENTITY(1,1),
    id_inventario INT NOT NULL,
    tipo_movimiento VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL,
    cantidad_anterior INT NOT NULL,
    cantidad_nueva INT NOT NULL,
    fecha_movimiento DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    motivo VARCHAR(255) NULL,
    id_usuario INT NULL,
    referencia_origen VARCHAR(100) NULL,
    FOREIGN KEY (id_inventario) REFERENCES dbo.inventario(id_inventario),
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id_usuario)
);
GO

-- ============================================================================
-- 7. Proveedores y compras
-- ============================================================================

-- Tabla: proveedores
CREATE TABLE dbo.proveedores (
    id_proveedor INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(150) NOT NULL,
    contacto VARCHAR(100) NULL,
    telefono VARCHAR(30) NULL,
    email VARCHAR(100) NULL,
    direccion VARCHAR(255) NULL,
    rfc VARCHAR(20) NULL,
    activo BIT NOT NULL DEFAULT 1
);
GO

-- Tabla: compras_proveedor
CREATE TABLE dbo.compras_proveedor (
    id_compra INT PRIMARY KEY IDENTITY(1,1),
    id_proveedor INT NOT NULL,
    id_almacen INT NOT NULL,
    fecha_compra DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    numero_factura VARCHAR(50) NULL,
    subtotal DECIMAL(18,2) NOT NULL DEFAULT 0,
    impuestos DECIMAL(18,2) NOT NULL DEFAULT 0,
    total DECIMAL(18,2) NOT NULL DEFAULT 0,
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    FOREIGN KEY (id_proveedor) REFERENCES dbo.proveedores(id_proveedor),
    FOREIGN KEY (id_almacen) REFERENCES dbo.almacenes(id_almacen)
);
GO

-- Tabla: detalle_compra
CREATE TABLE dbo.detalle_compra (
    id_detalle INT PRIMARY KEY IDENTITY(1,1),
    id_compra INT NOT NULL,
    id_producto INT NOT NULL,
    id_variante INT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(18,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(18,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (id_compra) REFERENCES dbo.compras_proveedor(id_compra),
    FOREIGN KEY (id_producto) REFERENCES dbo.productos(id_producto),
    FOREIGN KEY (id_variante) REFERENCES dbo.variantes_producto(id_variante)
);
GO

-- ============================================================================
-- 8. Ventas: carritos y pedidos
-- ============================================================================

-- Tabla: metodos_envio
CREATE TABLE dbo.metodos_envio (
    id_metodo_envio INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    costo_base DECIMAL(18,2) NOT NULL DEFAULT 0,
    tiempo_entrega_dias INT NOT NULL DEFAULT 3,
    activo BIT NOT NULL DEFAULT 1
);
GO

-- Tabla: cupones
CREATE TABLE dbo.cupones (
    id_cupon INT PRIMARY KEY IDENTITY(1,1),
    codigo VARCHAR(30) NOT NULL,
    tipo_descuento VARCHAR(15) NOT NULL,
    valor_descuento DECIMAL(18,2) NOT NULL,
    fecha_inicio DATETIME2 NOT NULL,
    fecha_fin DATETIME2 NULL,
    uso_maximo INT NULL,
    uso_por_cliente INT NOT NULL DEFAULT 1,
    activo BIT NOT NULL DEFAULT 1
);
GO

-- Tabla: carritos
CREATE TABLE dbo.carritos (
    id_carrito INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    fecha_actualizacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado VARCHAR(20) NOT NULL DEFAULT 'Activo',
    FOREIGN KEY (id_cliente) REFERENCES dbo.clientes(id_cliente)
);
GO

-- Tabla: items_carrito
CREATE TABLE dbo.items_carrito (
    id_item INT PRIMARY KEY IDENTITY(1,1),
    id_carrito INT NOT NULL,
    id_producto INT NOT NULL,
    id_variante INT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(18,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (id_carrito) REFERENCES dbo.carritos(id_carrito),
    FOREIGN KEY (id_producto) REFERENCES dbo.productos(id_producto),
    FOREIGN KEY (id_variante) REFERENCES dbo.variantes_producto(id_variante)
);
GO

-- Tabla: pedidos
CREATE TABLE dbo.pedidos (
    id_pedido INT PRIMARY KEY IDENTITY(1,1),
    numero_pedido VARCHAR(30) NOT NULL,
    id_cliente INT NOT NULL,
    id_vendedor INT NULL,
    id_direccion_envio INT NULL,
    id_metodo_envio INT NULL,
    id_cupon INT NULL,
    fecha_pedido DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    subtotal DECIMAL(18,2) NOT NULL DEFAULT 0,
    descuento DECIMAL(18,2) NOT NULL DEFAULT 0,
    impuestos DECIMAL(18,2) NOT NULL DEFAULT 0,
    costo_envio DECIMAL(18,2) NOT NULL DEFAULT 0,
    total DECIMAL(18,2) NOT NULL DEFAULT 0,
    notas VARCHAR(500) NULL,
    FOREIGN KEY (id_cliente) REFERENCES dbo.clientes(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES dbo.vendedores(id_vendedor),
    FOREIGN KEY (id_direccion_envio) REFERENCES dbo.direcciones(id_direccion),
    FOREIGN KEY (id_metodo_envio) REFERENCES dbo.metodos_envio(id_metodo_envio),
    FOREIGN KEY (id_cupon) REFERENCES dbo.cupones(id_cupon)
);
GO

-- Tabla: items_pedido
CREATE TABLE dbo.items_pedido (
    id_item_pedido INT PRIMARY KEY IDENTITY(1,1),
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    id_variante INT NULL,
    id_almacen_despacho INT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(18,2) NOT NULL DEFAULT 0,
    descuento DECIMAL(18,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(18,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (id_pedido) REFERENCES dbo.pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES dbo.productos(id_producto),
    FOREIGN KEY (id_variante) REFERENCES dbo.variantes_producto(id_variante),
    FOREIGN KEY (id_almacen_despacho) REFERENCES dbo.almacenes(id_almacen)
);
GO

-- Tabla: pagos
CREATE TABLE dbo.pagos (
    id_pago INT PRIMARY KEY IDENTITY(1,1),
    id_pedido INT NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    monto DECIMAL(18,2) NOT NULL,
    fecha_pago DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    transaccion_id VARCHAR(100) NULL,
    referencia_pago VARCHAR(100) NULL,
    FOREIGN KEY (id_pedido) REFERENCES dbo.pedidos(id_pedido)
);
GO

-- Tabla: envios
CREATE TABLE dbo.envios (
    id_envio INT PRIMARY KEY IDENTITY(1,1),
    id_pedido INT NOT NULL,
    id_metodo_envio INT NOT NULL,
    numero_guia VARCHAR(100) NULL,
    transportista VARCHAR(100) NULL,
    fecha_envio DATETIME2 NULL,
    fecha_entrega_estimada DATETIME2 NULL,
    fecha_entrega_real DATETIME2 NULL,
    estado_envio VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
    FOREIGN KEY (id_pedido) REFERENCES dbo.pedidos(id_pedido),
    FOREIGN KEY (id_metodo_envio) REFERENCES dbo.metodos_envio(id_metodo_envio)
);
GO

-- ============================================================================
-- 9. Contenido y operaciones
-- ============================================================================

-- Tabla: resenas_producto
CREATE TABLE dbo.resenas_producto (
    id_resena INT PRIMARY KEY IDENTITY(1,1),
    id_producto INT NOT NULL,
    id_cliente INT NOT NULL,
    calificacion INT NOT NULL,
    comentario VARCHAR(MAX) NULL,
    fecha_resena DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    activo BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_producto) REFERENCES dbo.productos(id_producto),
    FOREIGN KEY (id_cliente) REFERENCES dbo.clientes(id_cliente)
);
GO

-- Tabla: notificaciones
CREATE TABLE dbo.notificaciones (
    id_notificacion INT PRIMARY KEY IDENTITY(1,1),
    id_usuario INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    titulo VARCHAR(150) NULL,
    mensaje VARCHAR(MAX) NOT NULL,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    leida BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id_usuario)
);
GO

-- Tabla: auditoria_log
CREATE TABLE dbo.auditoria_log (
    id_auditoria INT PRIMARY KEY IDENTITY(1,1),
    tabla_afectada VARCHAR(100) NOT NULL,
    id_registro INT NULL,
    accion VARCHAR(10) NOT NULL,
    valores_antiguos VARCHAR(MAX) NULL,
    valores_nuevos VARCHAR(MAX) NULL,
    fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    id_usuario INT NULL,
    FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id_usuario)
);
GO

-- ============================================================================
-- Fin del script
-- ============================================================================
GO
