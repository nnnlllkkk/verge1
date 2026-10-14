-- Создание и выбор базы данных (опционально, если она еще не создана)
-- CREATE DATABASE VergeDB;
-- GO
-- USE VergeDB;
-- GO

-- Безопасное удаление таблиц в обратном порядке (чтобы избежать конфликтов внешних ключей при пересоздании)
IF OBJECT_ID('dbo.lookbook_items', 'U') IS NOT NULL DROP TABLE dbo.lookbook_items;
IF OBJECT_ID('dbo.lookbooks', 'U') IS NOT NULL DROP TABLE dbo.lookbooks;
IF OBJECT_ID('dbo.returns', 'U') IS NOT NULL DROP TABLE dbo.returns;
IF OBJECT_ID('dbo.order_items', 'U') IS NOT NULL DROP TABLE dbo.order_items;
IF OBJECT_ID('dbo.orders', 'U') IS NOT NULL DROP TABLE dbo.orders;
IF OBJECT_ID('dbo.cart_items', 'U') IS NOT NULL DROP TABLE dbo.cart_items;
IF OBJECT_ID('dbo.reviews', 'U') IS NOT NULL DROP TABLE dbo.reviews;
IF OBJECT_ID('dbo.product_images', 'U') IS NOT NULL DROP TABLE dbo.product_images;
IF OBJECT_ID('dbo.product_variants', 'U') IS NOT NULL DROP TABLE dbo.product_variants;
IF OBJECT_ID('dbo.products', 'U') IS NOT NULL DROP TABLE dbo.products;
IF OBJECT_ID('dbo.brands', 'U') IS NOT NULL DROP TABLE dbo.brands;
IF OBJECT_ID('dbo.categories', 'U') IS NOT NULL DROP TABLE dbo.categories;
IF OBJECT_ID('dbo.user_measurements', 'U') IS NOT NULL DROP TABLE dbo.user_measurements;
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL DROP TABLE dbo.users;
GO

CREATE TABLE dbo.users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('customer', 'supplier', 'admin')),
    created_at DATETIME2 DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.user_measurements (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    height DECIMAL(5,2) NULL,             -- Рост в см
    chest_girth DECIMAL(5,2) NULL,       -- Обхват груди в см
    waist_girth DECIMAL(5,2) NULL,       -- Обхват талии в см
    hip_girth DECIMAL(5,2) NULL,         -- Обхват бедер в см
    updated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_user_measurements_users FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INT NULL,
    CONSTRAINT FK_categories_parent FOREIGN KEY (parent_id) REFERENCES dbo.categories(id)
);
GO

CREATE TABLE dbo.brands (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL
);
GO

CREATE TABLE dbo.products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    category_id INT NOT NULL,
    brand_id INT NOT NULL,
    supplier_id INT NOT NULL,
    season VARCHAR(50) NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_products_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id),
    CONSTRAINT FK_products_brand FOREIGN KEY (brand_id) REFERENCES dbo.brands(id),
    CONSTRAINT FK_products_supplier FOREIGN KEY (supplier_id) REFERENCES dbo.users(id)
);
GO

CREATE TABLE dbo.product_variants (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    size VARCHAR(20) NOT NULL,          -- S, M, L, XL или 42, 44, 46
    color VARCHAR(50) NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,   -- Уникальный артикул
    stock_quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_product_variants_product FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.product_images (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_main BIT DEFAULT 0,              -- Главное фото карточки
    CONSTRAINT FK_product_images_product FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.reviews (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_reviews_product FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE,
    CONSTRAINT FK_reviews_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.cart_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    product_variant_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    CONSTRAINT FK_cart_items_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE,
    CONSTRAINT FK_cart_items_variant FOREIGN KEY (product_variant_id) REFERENCES dbo.product_variants(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'created' 
        CHECK (status IN ('created', 'paid', 'delivering', 'completed', 'returned')),
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_address TEXT NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_orders_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO

CREATE TABLE dbo.order_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_variant_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_moment DECIMAL(10,2) NOT NULL, -- Фиксация цены на момент покупки
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_order_items_variant FOREIGN KEY (product_variant_id) REFERENCES dbo.product_variants(id)
);
GO

CREATE TABLE dbo.returns (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'requested' 
        CHECK (status IN ('requested', 'approved', 'completed')),
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_returns_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id),
    CONSTRAINT FK_returns_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO

CREATE TABLE dbo.lookbooks (
    id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    created_by INT NOT NULL,            -- Администратор или стилист, создавший капсулу
    is_premade BIT DEFAULT 1,           -- Готовая капсула или пользовательская
    CONSTRAINT FK_lookbooks_user FOREIGN KEY (created_by) REFERENCES dbo.users(id)
);
GO

CREATE TABLE dbo.lookbook_items (
    lookbook_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (lookbook_id, product_id),
    CONSTRAINT FK_lookbook_items_lookbook FOREIGN KEY (lookbook_id) REFERENCES dbo.lookbooks(id) ON DELETE CASCADE,
    CONSTRAINT FK_lookbook_items_product FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE
);
GO