-- ============================================================================
-- Script SQL: Procedimientos Almacenados para las APIs
-- Base de datos: INTERCOMERCIO
-- Tablas afectadas: dbo.categorias, dbo.marcas, dbo.productos
-- ============================================================================

USE INTERCOMERCIO;
GO

-- ============================================================================
-- 1. CATEGORIAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- sp_Categorias_Obtener
-- Retorna categorias activas para selects.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Categorias_Obtener
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            CAST(id_categoria AS INT) AS id_categoria,
            nombre,
            descripcion,
            slug
        FROM dbo.categorias
        WHERE activo = 1
        ORDER BY nombre ASC;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- sp_Categorias_Crear
-- Inserta una nueva categoria.
-- Valida que no exista otra categoria con el mismo nombre o slug.
-- Parametros: @nombre (obligatorio), @descripcion (opcional), @slug (opcional).
-- Retorna: la categoria insertada.
-- Lanza error 50001 si ya existe nombre o slug duplicado.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Categorias_Crear
    @nombre      VARCHAR(100),
    @descripcion VARCHAR(500) = NULL,
    @slug        VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Resultado TABLE (
        id_categoria INT,
        nombre       VARCHAR(100),
        descripcion  VARCHAR(500),
        slug         VARCHAR(100)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar duplicado de nombre
        IF EXISTS (SELECT 1 FROM dbo.categorias WHERE nombre = @nombre)
        BEGIN
            THROW 50001, 'Ya existe una categoria con ese nombre.', 1;
        END

        -- Validar duplicado de slug (si se proporciona)
        IF @slug IS NOT NULL AND @slug <> ''
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.categorias WHERE slug = @slug)
            BEGIN
                THROW 50002, 'Ya existe una categoria con ese slug.', 1;
            END
        END

        INSERT INTO dbo.categorias (nombre, descripcion, slug)
        OUTPUT CAST(INSERTED.id_categoria AS INT),
               INSERTED.nombre,
               INSERTED.descripcion,
               INSERTED.slug
        INTO @Resultado
        VALUES (@nombre, @descripcion, @slug);

        SELECT * FROM @Resultado;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- sp_Categorias_Actualizar
-- Actualiza nombre, descripcion y slug de una categoria existente.
-- Valida que no exista otra categoria (diferente a esta) con el mismo nombre o slug.
-- Parametros: @id_categoria, @nombre, @descripcion, @slug.
-- Retorna: la categoria actualizada. Lanza error si no existe o hay duplicado.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Categorias_Actualizar
    @id_categoria INT,
    @nombre       VARCHAR(100),
    @descripcion  VARCHAR(500) = NULL,
    @slug         VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Resultado TABLE (
        id_categoria INT,
        nombre       VARCHAR(100),
        descripcion  VARCHAR(500),
        slug         VARCHAR(100)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que exista la categoria
        IF NOT EXISTS (SELECT 1 FROM dbo.categorias WHERE id_categoria = @id_categoria)
        BEGIN
            THROW 50003, 'Categoria no encontrada.', 1;
        END

        -- Validar duplicado de nombre en otra categoria
        IF EXISTS (SELECT 1 FROM dbo.categorias WHERE nombre = @nombre AND id_categoria <> @id_categoria)
        BEGIN
            THROW 50004, 'Ya existe otra categoria con ese nombre.', 1;
        END

        -- Validar duplicado de slug en otra categoria (si se proporciona)
        IF @slug IS NOT NULL AND @slug <> ''
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.categorias WHERE slug = @slug AND id_categoria <> @id_categoria)
            BEGIN
                THROW 50005, 'Ya existe otra categoria con ese slug.', 1;
            END
        END

        UPDATE dbo.categorias
        SET nombre     = @nombre,
            descripcion = @descripcion,
            slug       = @slug
        OUTPUT CAST(INSERTED.id_categoria AS INT),
               INSERTED.nombre,
               INSERTED.descripcion,
               INSERTED.slug
        INTO @Resultado
        WHERE id_categoria = @id_categoria;

        SELECT * FROM @Resultado;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- sp_Categorias_Eliminar
-- Borrado fisico: DELETE de la categoria.
-- Parametros: @id_categoria.
-- Retorna: registro eliminado. Lanza error si no existe o si hay dependencias (FK).
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Categorias_Eliminar
    @id_categoria INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Resultado TABLE (
        id_categoria INT,
        nombre       VARCHAR(100)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dbo.categorias
        OUTPUT CAST(DELETED.id_categoria AS INT),
               DELETED.nombre
        INTO @Resultado
        WHERE id_categoria = @id_categoria;

        IF (SELECT COUNT(*) FROM @Resultado) = 0
        BEGIN
            THROW 50006, 'Categoria no encontrada.', 1;
        END

        SELECT * FROM @Resultado;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- ============================================================================
-- 2. MARCAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- sp_Marcas_Obtener
-- Retorna marcas activas para selects.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Marcas_Obtener
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            CAST(id_marca AS INT) AS id_marca,
            nombre,
            pais_origen,
            sitio_web
        FROM dbo.marcas
        WHERE activo = 1
        ORDER BY nombre ASC;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- sp_Marcas_Crear
-- Inserta una nueva marca.
-- Valida que no exista otra marca con el mismo nombre.
-- Parametros: @nombre (obligatorio), @pais_origen (opcional), @sitio_web (opcional).
-- Retorna: la marca insertada.
-- Lanza error 50011 si ya existe nombre duplicado.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Marcas_Crear
    @nombre     VARCHAR(100),
    @pais_origen VARCHAR(100) = NULL,
    @sitio_web   VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Resultado TABLE (
        id_marca    INT,
        nombre      VARCHAR(100),
        pais_origen VARCHAR(100),
        sitio_web   VARCHAR(255)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar duplicado de nombre
        IF EXISTS (SELECT 1 FROM dbo.marcas WHERE nombre = @nombre)
        BEGIN
            THROW 50011, 'Ya existe una marca con ese nombre.', 1;
        END

        INSERT INTO dbo.marcas (nombre, pais_origen, sitio_web)
        OUTPUT CAST(INSERTED.id_marca AS INT),
               INSERTED.nombre,
               INSERTED.pais_origen,
               INSERTED.sitio_web
        INTO @Resultado
        VALUES (@nombre, @pais_origen, @sitio_web);

        SELECT * FROM @Resultado;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- sp_Marcas_Actualizar
-- Actualiza nombre, pais_origen y sitio_web de una marca existente.
-- Valida que no exista otra marca (diferente a esta) con el mismo nombre.
-- Parametros: @id_marca, @nombre, @pais_origen, @sitio_web.
-- Retorna: la marca actualizada. Lanza error si no existe o hay duplicado.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Marcas_Actualizar
    @id_marca     INT,
    @nombre       VARCHAR(100),
    @pais_origen  VARCHAR(100) = NULL,
    @sitio_web    VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Resultado TABLE (
        id_marca    INT,
        nombre      VARCHAR(100),
        pais_origen VARCHAR(100),
        sitio_web   VARCHAR(255)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que exista la marca
        IF NOT EXISTS (SELECT 1 FROM dbo.marcas WHERE id_marca = @id_marca)
        BEGIN
            THROW 50012, 'Marca no encontrada.', 1;
        END

        -- Validar duplicado de nombre en otra marca
        IF EXISTS (SELECT 1 FROM dbo.marcas WHERE nombre = @nombre AND id_marca <> @id_marca)
        BEGIN
            THROW 50013, 'Ya existe otra marca con ese nombre.', 1;
        END

        UPDATE dbo.marcas
        SET nombre      = @nombre,
            pais_origen = @pais_origen,
            sitio_web   = @sitio_web
        OUTPUT CAST(INSERTED.id_marca AS INT),
               INSERTED.nombre,
               INSERTED.pais_origen,
               INSERTED.sitio_web
        INTO @Resultado
        WHERE id_marca = @id_marca;

        SELECT * FROM @Resultado;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- sp_Marcas_Eliminar
-- Borrado fisico: DELETE de la marca.
-- Parametros: @id_marca.
-- Retorna: registro eliminado. Lanza error si no existe o si hay dependencias (FK).
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Marcas_Eliminar
    @id_marca INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Resultado TABLE (
        id_marca  INT,
        nombre    VARCHAR(100)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dbo.marcas
        OUTPUT CAST(DELETED.id_marca AS INT),
               DELETED.nombre
        INTO @Resultado
        WHERE id_marca = @id_marca;

        IF (SELECT COUNT(*) FROM @Resultado) = 0
        BEGIN
            THROW 50014, 'Marca no encontrada.', 1;
        END

        SELECT * FROM @Resultado;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- ============================================================================
-- 3. PRODUCTOS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- sp_Productos_Obtener
-- Listado paginado con busqueda y filtro por categoria.
-- Parametros: @q (busqueda), @id_categoria (filtro), @page, @pageSize.
-- Output: @totalRegistros (total sin paginar).
-- Retorna: items con nombres de categoria, marca y vendedor resueltos.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Productos_Obtener
    @q             NVARCHAR(200) = NULL,
    @id_categoria  INT           = NULL,
    @page          INT           = 1,
    @pageSize      INT           = 10,
    @totalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @page < 1         SET @page = 1;
    IF @pageSize < 1     SET @pageSize = 10;
    IF @pageSize > 100   SET @pageSize = 100;

    DECLARE @offset INT = (@page - 1) * @pageSize;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @totalRegistros = COUNT(*)
        FROM dbo.productos p
        INNER JOIN dbo.categorias c ON c.id_categoria = p.id_categoria
        LEFT  JOIN dbo.marcas m ON m.id_marca = p.id_marca
        LEFT  JOIN dbo.vendedores v ON v.id_vendedor = p.id_vendedor
        WHERE p.activo = 1
          AND (@q IS NULL OR (p.nombre LIKE '%' + @q + '%' OR p.sku LIKE '%' + @q + '%'))
          AND (@id_categoria IS NULL OR p.id_categoria = @id_categoria);

        SELECT
            CAST(p.id_producto AS INT) AS id_producto,
            p.sku,
            p.nombre,
            p.descripcion,
            p.precio_base,
            p.activo,
            p.fecha_creacion,
            CAST(p.id_categoria AS INT) AS id_categoria,
            c.nombre                                   AS categoria,
            CAST(p.id_marca AS INT) AS id_marca,
            m.nombre                                   AS marca,
            CAST(p.id_vendedor AS INT) AS id_vendedor,
            (v.nombre + ' ' + v.apellido)             AS vendedor
        FROM dbo.productos p
        INNER JOIN dbo.categorias c ON c.id_categoria = p.id_categoria
        LEFT  JOIN dbo.marcas m ON m.id_marca = p.id_marca
        LEFT  JOIN dbo.vendedores v ON v.id_vendedor = p.id_vendedor
        WHERE p.activo = 1
          AND (@q IS NULL OR (p.nombre LIKE '%' + @q + '%' OR p.sku LIKE '%' + @q + '%'))
          AND (@id_categoria IS NULL OR p.id_categoria = @id_categoria)
        ORDER BY p.fecha_creacion DESC, p.id_producto DESC
        OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- sp_Productos_Crear
-- Inserta un nuevo producto.
-- Valida que no exista otro producto con el mismo SKU.
-- Parametros: todos los campos editables de dbo.productos.
-- Retorna: id_producto, sku, nombre.
-- Lanza error 50021 si ya existe SKU duplicado.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Productos_Crear
    @id_categoria  INT,
    @id_marca      INT           = NULL,
    @id_vendedor   INT           = NULL,
    @sku           VARCHAR(50),
    @nombre        VARCHAR(200),
    @descripcion   VARCHAR(MAX)  = NULL,
    @precio_base   DECIMAL(18,2),
    @peso_kg       DECIMAL(10,3) = NULL,
    @largo_cm      DECIMAL(10,2) = NULL,
    @ancho_cm      DECIMAL(10,2) = NULL,
    @alto_cm       DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Resultado TABLE (
        id_producto INT,
        sku         VARCHAR(50),
        nombre      VARCHAR(200)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar duplicado de SKU
        IF EXISTS (SELECT 1 FROM dbo.productos WHERE sku = @sku)
        BEGIN
            THROW 50021, 'Ya existe un producto con ese SKU.', 1;
        END

        INSERT INTO dbo.productos
            (id_categoria, id_marca, id_vendedor, sku, nombre, descripcion,
             precio_base, peso_kg, largo_cm, ancho_cm, alto_cm)
        OUTPUT CAST(INSERTED.id_producto AS INT),
               INSERTED.sku,
               INSERTED.nombre
        INTO @Resultado
        VALUES
            (@id_categoria, @id_marca, @id_vendedor, @sku, @nombre, @descripcion,
             @precio_base, @peso_kg, @largo_cm, @ancho_cm, @alto_cm);

        SELECT * FROM @Resultado;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- sp_Productos_Actualizar
-- Actualiza todos los campos editables de un producto existente.
-- Valida que no exista otro producto (diferente a este) con el mismo SKU.
-- Parametros: @id_producto y el resto igual que sp_Productos_Crear.
-- Retorna: id_producto, sku, nombre. Lanza error si no existe o hay duplicado.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Productos_Actualizar
    @id_producto   INT,
    @id_categoria  INT,
    @id_marca      INT           = NULL,
    @id_vendedor   INT           = NULL,
    @sku           VARCHAR(50),
    @nombre        VARCHAR(200),
    @descripcion   VARCHAR(MAX)  = NULL,
    @precio_base   DECIMAL(18,2),
    @peso_kg       DECIMAL(10,3) = NULL,
    @largo_cm      DECIMAL(10,2) = NULL,
    @ancho_cm      DECIMAL(10,2) = NULL,
    @alto_cm       DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Resultado TABLE (
        id_producto INT,
        sku         VARCHAR(50),
        nombre      VARCHAR(200)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que exista el producto
        IF NOT EXISTS (SELECT 1 FROM dbo.productos WHERE id_producto = @id_producto)
        BEGIN
            THROW 50022, 'Producto no encontrado.', 1;
        END

        -- Validar duplicado de SKU en otro producto
        IF EXISTS (SELECT 1 FROM dbo.productos WHERE sku = @sku AND id_producto <> @id_producto)
        BEGIN
            THROW 50023, 'Ya existe otro producto con ese SKU.', 1;
        END

        UPDATE dbo.productos
        SET id_categoria = @id_categoria,
            id_marca     = @id_marca,
            id_vendedor  = @id_vendedor,
            sku          = @sku,
            nombre       = @nombre,
            descripcion  = @descripcion,
            precio_base  = @precio_base,
            peso_kg      = @peso_kg,
            largo_cm     = @largo_cm,
            ancho_cm     = @ancho_cm,
            alto_cm      = @alto_cm
        OUTPUT CAST(INSERTED.id_producto AS INT),
               INSERTED.sku,
               INSERTED.nombre
        INTO @Resultado
        WHERE id_producto = @id_producto;

        SELECT * FROM @Resultado;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- sp_Productos_Eliminar
-- Borrado fisico: DELETE del producto.
-- Parametros: @id_producto.
-- Retorna: registro eliminado. Lanza error si no existe o si hay dependencias (FK).
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Productos_Eliminar
    @id_producto INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Resultado TABLE (
        id_producto INT,
        nombre      VARCHAR(200)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dbo.productos
        OUTPUT CAST(DELETED.id_producto AS INT),
               DELETED.nombre
        INTO @Resultado
        WHERE id_producto = @id_producto;

        IF (SELECT COUNT(*) FROM @Resultado) = 0
        BEGIN
            THROW 50024, 'Producto no encontrado.', 1;
        END

        SELECT * FROM @Resultado;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- Fin de procedimientos.sql
-- ============================================================================
