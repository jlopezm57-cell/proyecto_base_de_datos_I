-- ============================================
-- Script DML: Datos de prueba para INTERCOMERCIO
-- Tablas: categorias (3), marcas (5), productos (10)
-- Motor: Microsoft SQL Server (T-SQL)
-- ============================================

USE INTERCOMERCIO;
GO

-- ---------------------------------------------------------------------------
-- 1. Categorías (3 registros)
-- ---------------------------------------------------------------------------
SET IDENTITY_INSERT dbo.categorias ON;

INSERT INTO dbo.categorias (id_categoria, nombre, descripcion, slug, activo) VALUES
(1, 'Electrónica', 'Dispositivos electrónicos, accesorios y gadgets.', 'electronica', 1),
(2, 'Ropa', 'Prendas de vestir para toda la familia.', 'ropa', 1),
(3, 'Hogar', 'Artículos para el hogar y decoración.', 'hogar', 1);

SET IDENTITY_INSERT dbo.categorias OFF;
GO

-- ---------------------------------------------------------------------------
-- 2. Marcas (5 registros)
-- ---------------------------------------------------------------------------
SET IDENTITY_INSERT dbo.marcas ON;

INSERT INTO dbo.marcas (id_marca, nombre, pais_origen, sitio_web, activo) VALUES
(1, 'Samsung', 'Corea del Sur', 'https://www.samsung.com', 1),
(2, 'Nike', 'Estados Unidos', 'https://www.nike.com', 1),
(3, 'Sony', 'Japón', 'https://www.sony.com', 1),
(4, 'Zara', 'España', 'https://www.zara.com', 1),
(5, 'Whirlpool', 'Estados Unidos', 'https://www.whirlpool.com', 1);

SET IDENTITY_INSERT dbo.marcas OFF;
GO

-- ---------------------------------------------------------------------------
-- 3. Productos (10 registros)
-- ---------------------------------------------------------------------------
SET IDENTITY_INSERT dbo.productos ON;

INSERT INTO dbo.productos (
    id_producto, id_categoria, id_marca, id_vendedor, sku, nombre, descripcion,
    precio_base, peso_kg, largo_cm, ancho_cm, alto_cm, activo
) VALUES
-- Categoría: Electrónica
(1, 1, 1, NULL, 'TV-SAMSUNG-55', 'Televisor Samsung 55" 4K UHD', 'Televisor inteligente con resolución 4K, HDR y Smart TV.', 12999.99, 15.500, 123.00, 71.00, 7.50, 1),
(2, 1, 3, NULL, 'AUD-SONY-WH1000XM5', 'Audífonos Sony WH-1000XM5', 'Audífonos inalámbricos con cancelación de ruido y 30 horas de batería.', 8499.50, 0.250, 18.50, 7.50, 2.80, 1),
(3, 1, 1, NULL, 'CEL-SAMSUNG-S23', 'Smartphone Samsung Galaxy S23', 'Teléfono móvil con pantalla Dynamic AMOLED, 128 GB y cámara de 50 MP.', 18999.00, 0.168, 14.60, 7.10, 0.76, 1),
(4, 1, 3, NULL, 'CAM-SONY-A6400', 'Cámara Sony Alpha 6400', 'Cámara mirrorless APS-C con autofocus en tiempo real y video 4K.', 22999.00, 0.503, 12.00, 6.70, 6.00, 1),

-- Categoría: Ropa
(5, 2, 2, NULL, 'ZAP-NIKE-AIRMAX', 'Zapatillas Nike Air Max', 'Zapatillas deportivas con amortiguación Air Max y suela de goma.', 2499.00, 0.400, 30.00, 12.00, 11.00, 1),
(6, 2, 4, NULL, 'CAM-ZARA-ALGODON', 'Camisa Zara Algodón', 'Camisa de manga larga en algodón 100 %, cuello clásico.', 799.00, 0.220, 28.00, 20.00, 1.50, 1),
(7, 2, 4, NULL, 'JEANS-ZARA-MUJER', 'Jeans Zara Mujer', 'Pantalón jean de corte recto, lavado medio.', 1299.00, 0.550, 32.00, 22.00, 2.00, 1),
(8, 2, 2, NULL, 'POL-NIKE-DRIFIT', 'Polera Nike Dri-FIT', 'Polera deportiva con tecnología Dri-FIT que absorbe la humedad.', 999.00, 0.180, 25.00, 18.00, 1.20, 1),

-- Categoría: Hogar
(9, 3, 5, NULL, 'LAV-WHIRLPOOL-15KG', 'Lavadora Whirlpool 15 kg', 'Lavadora de carga superior con 15 kg de capacidad y múltiples ciclos.', 14999.00, 45.000, 60.00, 65.00, 105.00, 1),
(10, 3, 5, NULL, 'REF-WHIRLPOOL-NOFROST', 'Refrigerador Whirlpool No Frost', 'Refrigerador de dos puertas con tecnología No Frost y 350 litros.', 16999.00, 65.000, 70.00, 75.00, 175.00, 1);

SET IDENTITY_INSERT dbo.productos OFF;
GO