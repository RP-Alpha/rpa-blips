-- RP-Alpha Blips Manager
-- Dynamic blip system with in-game admin management (like Jaksam's Blips Creator)

local ActiveBlips = {}
local BlipData = {}
local IsAdmin = false

-- Create a blip on the map
---@param data table Blip configuration
---@return number blipHandle
local function CreateBlip(data)
    if not data.coords then return 0 end
    
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, data.sprite or 1)
    SetBlipDisplay(blip, data.display or 4)
    SetBlipScale(blip, data.scale or 0.8)
    SetBlipColour(blip, data.color or 0)
    SetBlipAsShortRange(blip, data.shortRange ~= false)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.label or 'Unknown')
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- Remove a blip from the map
---@param blipId string Blip ID
local function RemoveBlip(blipId)
    if ActiveBlips[blipId] then
        RemoveBlip(ActiveBlips[blipId])
        ActiveBlips[blipId] = nil
    end
end

-- Refresh all blips (clear and recreate from BlipData)
local function RefreshBlips()
    -- Remove existing blips
    for id, handle in pairs(ActiveBlips) do
        if DoesBlipExist(handle) then
            RemoveBlip(handle)
        end
    end
    ActiveBlips = {}
    
    -- Create blips from data
    for _, data in pairs(BlipData) do
        local handle = CreateBlip(data)
        if handle and handle ~= 0 then
            ActiveBlips[data.id] = handle
        end
    end
end

-- Receive blip data from server
RegisterNetEvent('rpa-blips:client:syncBlips', function(blips)
    BlipData = blips
    RefreshBlips()
end)

-- Receive single blip update
RegisterNetEvent('rpa-blips:client:updateBlip', function(blipData)
    BlipData[blipData.id] = blipData
    
    -- Remove old blip if exists
    if ActiveBlips[blipData.id] then
        if DoesBlipExist(ActiveBlips[blipData.id]) then
            RemoveBlip(ActiveBlips[blipData.id])
        end
    end
    
    -- Create new blip
    local handle = CreateBlip(blipData)
    if handle and handle ~= 0 then
        ActiveBlips[blipData.id] = handle
    end
end)

-- Receive blip deletion
RegisterNetEvent('rpa-blips:client:removeBlip', function(blipId)
    BlipData[blipId] = nil
    
    if ActiveBlips[blipId] then
        if DoesBlipExist(ActiveBlips[blipId]) then
            RemoveBlip(ActiveBlips[blipId])
        end
        ActiveBlips[blipId] = nil
    end
end)

-- Set admin status (received from server)
RegisterNetEvent('rpa-blips:client:setAdmin', function(status)
    IsAdmin = status
end)

-- ============================================
-- ADMIN MENU SYSTEM
-- ============================================

local function GetSpriteOptions()
    local options = {}
    for _, sprite in ipairs(Config.CommonSprites) do
        table.insert(options, { value = sprite.id, label = sprite.label .. ' (' .. sprite.id .. ')' })
    end
    return options
end

local function GetColorOptions()
    local options = {}
    for _, color in ipairs(Config.CommonColors) do
        table.insert(options, { value = color.id, label = color.label .. ' (' .. color.id .. ')' })
    end
    return options
end

local function GetCategoryOptions()
    local options = {}
    for _, cat in ipairs(Config.Categories) do
        table.insert(options, { value = cat.id, label = cat.label })
    end
    return options
end

-- Open the main admin menu
local function OpenAdminMenu()
    if not IsAdmin then
        exports['rpa-lib']:Notify('You do not have permission to manage blips', 'error')
        return
    end
    
    lib.registerContext({
        id = 'rpa_blips_main',
        title = '📍 Blip Manager',
        options = {
            {
                title = '➕ Create New Blip',
                description = 'Create a blip at your current location',
                icon = 'fas fa-plus-circle',
                onSelect = function()
                    OpenCreateMenu()
                end
            },
            {
                title = '📋 Manage Existing Blips',
                description = 'Edit or delete existing blips',
                icon = 'fas fa-list',
                onSelect = function()
                    OpenBlipListMenu()
                end
            },
            {
                title = '🔄 Refresh All Blips',
                description = 'Force refresh all blips on map',
                icon = 'fas fa-sync',
                onSelect = function()
                    TriggerServerEvent('rpa-blips:server:requestBlips')
                    exports['rpa-lib']:Notify('Blips refreshed', 'success')
                end
            },
            {
                title = '📦 Import Default Blips',
                description = 'Load default blips from config',
                icon = 'fas fa-download',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Import Default Blips',
                        content = 'This will add all default blips from the config. Existing blips with matching IDs will be overwritten. Continue?',
                        centered = true,
                        cancel = true
                    })
                    if confirm == 'confirm' then
                        TriggerServerEvent('rpa-blips:server:importDefaults')
                    end
                end
            }
        }
    })
    
    lib.showContext('rpa_blips_main')
end

-- Create new blip menu
function OpenCreateMenu()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local input = lib.inputDialog('Create New Blip', {
        { type = 'input', label = 'Blip Label', description = 'Name shown on map', required = true },
        { type = 'input', label = 'Unique ID', description = 'e.g., my_shop_01 (auto-generated if empty)' },
        { type = 'select', label = 'Sprite', options = GetSpriteOptions(), default = 1 },
        { type = 'select', label = 'Color', options = GetColorOptions(), default = 0 },
        { type = 'slider', label = 'Scale', default = 80, min = 10, max = 200, step = 10 },
        { type = 'select', label = 'Category', options = GetCategoryOptions(), default = 'custom' },
        { type = 'checkbox', label = 'Short Range Only', checked = true },
        { type = 'select', label = 'Position', options = {
            { value = 'current', label = 'Use Current Position' },
            { value = 'manual', label = 'Enter Manually' }
        }, default = 'current' }
    })
    
    if not input then return end
    
    local blipCoords = coords
    
    if input[8] == 'manual' then
        local coordInput = lib.inputDialog('Enter Coordinates', {
            { type = 'number', label = 'X', default = coords.x },
            { type = 'number', label = 'Y', default = coords.y },
            { type = 'number', label = 'Z', default = coords.z }
        })
        if coordInput then
            blipCoords = vector3(coordInput[1], coordInput[2], coordInput[3])
        end
    end
    
    local blipId = input[2]
    if not blipId or blipId == '' then
        blipId = 'blip_' .. tostring(GetGameTimer())
    end
    
    TriggerServerEvent('rpa-blips:server:createBlip', {
        id = blipId,
        label = input[1],
        coords = blipCoords,
        sprite = input[3],
        color = input[4],
        scale = input[5] / 100,
        category = input[6],
        shortRange = input[7],
        display = 4
    })
end

-- List all blips for management
function OpenBlipListMenu()
    local options = {}
    
    -- Group by category
    local byCategory = {}
    for id, data in pairs(BlipData) do
        local cat = data.category or 'custom'
        if not byCategory[cat] then
            byCategory[cat] = {}
        end
        table.insert(byCategory[cat], data)
    end
    
    -- Create category submenus
    for _, catInfo in ipairs(Config.Categories) do
        local catBlips = byCategory[catInfo.id]
        if catBlips and #catBlips > 0 then
            table.insert(options, {
                title = catInfo.label,
                description = #catBlips .. ' blip(s)',
                icon = catInfo.icon,
                arrow = true,
                onSelect = function()
                    OpenCategoryMenu(catInfo.id, catInfo.label, catBlips)
                end
            })
        end
    end
    
    if #options == 0 then
        table.insert(options, {
            title = 'No blips found',
            description = 'Create a new blip to get started',
            icon = 'fas fa-info-circle',
            disabled = true
        })
    end
    
    lib.registerContext({
        id = 'rpa_blips_list',
        title = '📋 Blip List',
        menu = 'rpa_blips_main',
        options = options
    })
    
    lib.showContext('rpa_blips_list')
end

-- Show blips in a category
function OpenCategoryMenu(catId, catLabel, blips)
    local options = {}
    
    for _, data in ipairs(blips) do
        table.insert(options, {
            title = data.label,
            description = 'ID: ' .. data.id,
            icon = 'fas fa-map-marker-alt',
            metadata = {
                { label = 'Sprite', value = tostring(data.sprite) },
                { label = 'Color', value = tostring(data.color) },
                { label = 'Scale', value = tostring(data.scale) }
            },
            arrow = true,
            onSelect = function()
                OpenBlipEditMenu(data)
            end
        })
    end
    
    lib.registerContext({
        id = 'rpa_blips_category_' .. catId,
        title = '📁 ' .. catLabel,
        menu = 'rpa_blips_list',
        options = options
    })
    
    lib.showContext('rpa_blips_category_' .. catId)
end

-- Edit a specific blip
function OpenBlipEditMenu(blipData)
    lib.registerContext({
        id = 'rpa_blips_edit_' .. blipData.id,
        title = '✏️ Edit: ' .. blipData.label,
        menu = 'rpa_blips_list',
        options = {
            {
                title = '📝 Edit Properties',
                description = 'Change label, sprite, color, etc.',
                icon = 'fas fa-edit',
                onSelect = function()
                    EditBlipProperties(blipData)
                end
            },
            {
                title = '📍 Move to Current Position',
                description = 'Update coordinates to your current location',
                icon = 'fas fa-crosshairs',
                onSelect = function()
                    local coords = GetEntityCoords(PlayerPedId())
                    local updatedData = {}
                    for k, v in pairs(blipData) do
                        updatedData[k] = v
                    end
                    updatedData.coords = coords
                    TriggerServerEvent('rpa-blips:server:updateBlip', updatedData)
                    exports['rpa-lib']:Notify('Blip moved to your position', 'success')
                end
            },
            {
                title = '🧭 Teleport to Blip',
                description = 'Teleport to this blip location',
                icon = 'fas fa-location-arrow',
                onSelect = function()
                    exports['rpa-lib']:Teleport(blipData.coords)
                    exports['rpa-lib']:Notify('Teleported to ' .. blipData.label, 'success')
                end
            },
            {
                title = '🗑️ Delete Blip',
                description = 'Permanently remove this blip',
                icon = 'fas fa-trash',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Delete Blip',
                        content = 'Are you sure you want to delete "' .. blipData.label .. '"? This cannot be undone.',
                        centered = true,
                        cancel = true
                    })
                    if confirm == 'confirm' then
                        TriggerServerEvent('rpa-blips:server:deleteBlip', blipData.id)
                    end
                end
            }
        }
    })
    
    lib.showContext('rpa_blips_edit_' .. blipData.id)
end

-- Edit blip properties dialog
function EditBlipProperties(blipData)
    local input = lib.inputDialog('Edit Blip: ' .. blipData.label, {
        { type = 'input', label = 'Blip Label', default = blipData.label, required = true },
        { type = 'select', label = 'Sprite', options = GetSpriteOptions(), default = blipData.sprite },
        { type = 'select', label = 'Color', options = GetColorOptions(), default = blipData.color },
        { type = 'slider', label = 'Scale', default = math.floor((blipData.scale or 0.8) * 100), min = 10, max = 200, step = 10 },
        { type = 'select', label = 'Category', options = GetCategoryOptions(), default = blipData.category or 'custom' },
        { type = 'checkbox', label = 'Short Range Only', checked = blipData.shortRange ~= false }
    })
    
    if not input then return end
    
    local updatedData = {
        id = blipData.id,
        label = input[1],
        coords = blipData.coords,
        sprite = input[2],
        color = input[3],
        scale = input[4] / 100,
        category = input[5],
        shortRange = input[6],
        display = blipData.display or 4
    }
    
    TriggerServerEvent('rpa-blips:server:updateBlip', updatedData)
end

-- Admin command registration
RegisterCommand(Config.AdminCommand, function()
    TriggerServerEvent('rpa-blips:server:checkAdmin')
end, false)

-- Open menu after admin check
RegisterNetEvent('rpa-blips:client:openAdminMenu', function()
    OpenAdminMenu()
end)

-- Request blips on resource start
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('rpa-blips:server:requestBlips')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, handle in pairs(ActiveBlips) do
            if DoesBlipExist(handle) then
                RemoveBlip(handle)
            end
        end
    end
end)

print('[rpa-blips] Client loaded')

