-- RP-Alpha Blips Manager Database Schema
-- This table is auto-created by the resource, but you can run this manually if needed

CREATE TABLE IF NOT EXISTS `rpa_blips` (
    `id` VARCHAR(50) PRIMARY KEY,
    `label` VARCHAR(100) NOT NULL,
    `coords_x` FLOAT NOT NULL,
    `coords_y` FLOAT NOT NULL,
    `coords_z` FLOAT NOT NULL,
    `sprite` INT DEFAULT 1,
    `color` INT DEFAULT 0,
    `scale` FLOAT DEFAULT 0.8,
    `display` INT DEFAULT 4,
    `short_range` TINYINT(1) DEFAULT 1,
    `category` VARCHAR(50) DEFAULT 'custom',
    `created_by` VARCHAR(100),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for category filtering
CREATE INDEX IF NOT EXISTS idx_blips_category ON rpa_blips(category);
