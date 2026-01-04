-- RP-Alpha Blips Manager - Server Side
-- Database persistence and permission management

local Blips = {}

-- Initialize database table
CreateThread(function()
    MySQL.query([[
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
        )
    ]])
    
    -- Load existing blips
    Wait(500)
    LoadBlips()
end)

-- Load all blips from database
function LoadBlips()
    local result = MySQL.query.await('SELECT * FROM rpa_blips')
    
    Blips = {}
    
    if result and #result > 0 then
        for _, row in ipairs(result) do
            Blips[row.id] = {
                id = row.id,
                label = row.label,
                coords = vector3(row.coords_x, row.coords_y, row.coords_z),
                sprite = row.sprite,
                color = row.color,
                scale = row.scale,
                display = row.display,
                shortRange = row.short_range == 1,
                category = row.category
            }
        end
        print('[rpa-blips] Loaded ' .. #result .. ' blips from database')
    else
        print('[rpa-blips] No blips in database')
    end
end

-- Sync blips to a player
function SyncBlipsToPlayer(source)
    TriggerClientEvent('rpa-blips:client:syncBlips', source, Blips)
end

-- Sync blips to all players
function SyncBlipsToAll()
    TriggerClientEvent('rpa-blips:client:syncBlips', -1, Blips)
end

-- Check if player has admin permission
function HasAdminPermission(source)
    return exports['rpa-lib']:HasPermission(source, Config.AdminPermissions, 'blips')
end

-- Request blips (called by client on join)
RegisterNetEvent('rpa-blips:server:requestBlips', function()
    local src = source
    SyncBlipsToPlayer(src)
end)

-- Check admin status (called by command)
RegisterNetEvent('rpa-blips:server:checkAdmin', function()
    local src = source
    local isAdmin = HasAdminPermission(src)
    
    TriggerClientEvent('rpa-blips:client:setAdmin', src, isAdmin)
    
    if isAdmin then
        TriggerClientEvent('rpa-blips:client:openAdminMenu', src)
    else
        exports['rpa-lib']:Notify(src, 'You do not have permission to manage blips', 'error')
    end
end)

-- Create a new blip
RegisterNetEvent('rpa-blips:server:createBlip', function(data)
    local src = source
    
    if not HasAdminPermission(src) then
        exports['rpa-lib']:Notify(src, 'No permission', 'error')
        return
    end
    
    if not data.id or not data.label or not data.coords then
        exports['rpa-lib']:Notify(src, 'Invalid blip data', 'error')
        return
    end
    
    -- Check if ID already exists
    if Blips[data.id] then
        exports['rpa-lib']:Notify(src, 'A blip with this ID already exists', 'error')
        return
    end
    
    -- Get player identifier for tracking
    local identifier = GetPlayerIdentifier(src, 0) or 'unknown'
    
    -- Insert into database
    MySQL.insert('INSERT INTO rpa_blips (id, label, coords_x, coords_y, coords_z, sprite, color, scale, display, short_range, category, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        data.id,
        data.label,
        data.coords.x,
        data.coords.y,
        data.coords.z,
        data.sprite or 1,
        data.color or 0,
        data.scale or 0.8,
        data.display or 4,
        data.shortRange and 1 or 0,
        data.category or 'custom',
        identifier
    })
    
    -- Add to runtime cache
    Blips[data.id] = {
        id = data.id,
        label = data.label,
        coords = data.coords,
        sprite = data.sprite or 1,
        color = data.color or 0,
        scale = data.scale or 0.8,
        display = data.display or 4,
        shortRange = data.shortRange ~= false,
        category = data.category or 'custom'
    }
    
    -- Sync to all players
    TriggerClientEvent('rpa-blips:client:updateBlip', -1, Blips[data.id])
    
    exports['rpa-lib']:Notify(src, 'Blip "' .. data.label .. '" created successfully', 'success')
    print('[rpa-blips] Blip created: ' .. data.id .. ' by player ' .. src)
end)

-- Update an existing blip
RegisterNetEvent('rpa-blips:server:updateBlip', function(data)
    local src = source
    
    if not HasAdminPermission(src) then
        exports['rpa-lib']:Notify(src, 'No permission', 'error')
        return
    end
    
    if not data.id then
        exports['rpa-lib']:Notify(src, 'Invalid blip data', 'error')
        return
    end
    
    if not Blips[data.id] then
        exports['rpa-lib']:Notify(src, 'Blip not found', 'error')
        return
    end
    
    -- Update database
    MySQL.update('UPDATE rpa_blips SET label = ?, coords_x = ?, coords_y = ?, coords_z = ?, sprite = ?, color = ?, scale = ?, display = ?, short_range = ?, category = ? WHERE id = ?', {
        data.label,
        data.coords.x,
        data.coords.y,
        data.coords.z,
        data.sprite or 1,
        data.color or 0,
        data.scale or 0.8,
        data.display or 4,
        data.shortRange and 1 or 0,
        data.category or 'custom',
        data.id
    })
    
    -- Update runtime cache
    Blips[data.id] = {
        id = data.id,
        label = data.label,
        coords = data.coords,
        sprite = data.sprite or 1,
        color = data.color or 0,
        scale = data.scale or 0.8,
        display = data.display or 4,
        shortRange = data.shortRange ~= false,
        category = data.category or 'custom'
    }
    
    -- Sync to all players
    TriggerClientEvent('rpa-blips:client:updateBlip', -1, Blips[data.id])
    
    exports['rpa-lib']:Notify(src, 'Blip "' .. data.label .. '" updated', 'success')
    print('[rpa-blips] Blip updated: ' .. data.id .. ' by player ' .. src)
end)

-- Delete a blip
RegisterNetEvent('rpa-blips:server:deleteBlip', function(blipId)
    local src = source
    
    if not HasAdminPermission(src) then
        exports['rpa-lib']:Notify(src, 'No permission', 'error')
        return
    end
    
    if not blipId or not Blips[blipId] then
        exports['rpa-lib']:Notify(src, 'Blip not found', 'error')
        return
    end
    
    local label = Blips[blipId].label
    
    -- Delete from database
    MySQL.query('DELETE FROM rpa_blips WHERE id = ?', { blipId })
    
    -- Remove from runtime cache
    Blips[blipId] = nil
    
    -- Sync deletion to all players
    TriggerClientEvent('rpa-blips:client:removeBlip', -1, blipId)
    
    exports['rpa-lib']:Notify(src, 'Blip "' .. label .. '" deleted', 'success')
    print('[rpa-blips] Blip deleted: ' .. blipId .. ' by player ' .. src)
end)

-- Import default blips from config
RegisterNetEvent('rpa-blips:server:importDefaults', function()
    local src = source
    
    if not HasAdminPermission(src) then
        exports['rpa-lib']:Notify(src, 'No permission', 'error')
        return
    end
    
    local identifier = GetPlayerIdentifier(src, 0) or 'unknown'
    local count = 0
    
    for _, data in ipairs(Config.DefaultBlips) do
        -- Use INSERT ... ON DUPLICATE KEY UPDATE for MySQL
        MySQL.query([[
            INSERT INTO rpa_blips (id, label, coords_x, coords_y, coords_z, sprite, color, scale, display, short_range, category, created_by)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                label = VALUES(label),
                coords_x = VALUES(coords_x),
                coords_y = VALUES(coords_y),
                coords_z = VALUES(coords_z),
                sprite = VALUES(sprite),
                color = VALUES(color),
                scale = VALUES(scale),
                display = VALUES(display),
                short_range = VALUES(short_range),
                category = VALUES(category)
        ]], {
            data.id,
            data.label,
            data.coords.x,
            data.coords.y,
            data.coords.z,
            data.sprite or 1,
            data.color or 0,
            data.scale or 0.8,
            data.display or 4,
            data.shortRange and 1 or 0,
            data.category or 'custom',
            identifier
        })
        
        -- Update runtime cache
        Blips[data.id] = {
            id = data.id,
            label = data.label,
            coords = data.coords,
            sprite = data.sprite or 1,
            color = data.color or 0,
            scale = data.scale or 0.8,
            display = data.display or 4,
            shortRange = data.shortRange ~= false,
            category = data.category or 'custom'
        }
        
        count = count + 1
    end
    
    -- Sync to all players
    SyncBlipsToAll()
    
    exports['rpa-lib']:Notify(src, 'Imported ' .. count .. ' default blips', 'success')
    print('[rpa-blips] Imported ' .. count .. ' default blips by player ' .. src)
end)

-- Sync blips to player on join
AddEventHandler('playerJoining', function()
    local src = source
    Wait(2000) -- Wait for player to fully load
    SyncBlipsToPlayer(src)
end)

print('[rpa-blips] Server loaded')
