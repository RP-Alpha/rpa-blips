Config = {}

-- Permission configuration for blip management
-- Admins can create, edit, and delete blips in-game
Config.AdminPermissions = {
    groups = { 'admin', 'god' },
    jobs = {},
    minGrade = 0,
    onDuty = false,
    convar = 'rpa:admins',
    resourceConvar = 'admin'
}

-- Default blips (loaded if database is empty or as fallback)
-- These are examples - admins can add more in-game
Config.DefaultBlips = {
    {
        id = 'police_station',
        label = 'Police Station',
        coords = vector3(441.8, -981.5, 30.7),
        sprite = 60,
        color = 29,
        scale = 0.8,
        display = 4,
        shortRange = true,
        category = 'emergency'
    },
    {
        id = 'hospital',
        label = 'Hospital',
        coords = vector3(291.2, -581.6, 43.1),
        sprite = 61,
        color = 1,
        scale = 0.8,
        display = 4,
        shortRange = true,
        category = 'emergency'
    }
}

-- Blip categories for organization
Config.Categories = {
    { id = 'emergency', label = 'Emergency Services', icon = 'fas fa-ambulance' },
    { id = 'government', label = 'Government', icon = 'fas fa-landmark' },
    { id = 'shops', label = 'Shops & Stores', icon = 'fas fa-shopping-cart' },
    { id = 'services', label = 'Services', icon = 'fas fa-wrench' },
    { id = 'recreation', label = 'Recreation', icon = 'fas fa-gamepad' },
    { id = 'custom', label = 'Custom', icon = 'fas fa-map-marker' },
}

-- Common blip sprites for quick selection in admin menu
-- Full list: https://docs.fivem.net/docs/game-references/blips/
Config.CommonSprites = {
    { id = 1, label = 'Circle' },
    { id = 2, label = 'Circle (Filled)' },
    { id = 52, label = 'Convenience Store' },
    { id = 60, label = 'Police Station' },
    { id = 61, label = 'Hospital' },
    { id = 62, label = 'Fire Station' },
    { id = 68, label = 'Clothes Store' },
    { id = 72, label = 'Garage' },
    { id = 76, label = 'Barber Shop' },
    { id = 78, label = 'Tattoo Parlor' },
    { id = 89, label = 'Car Wash' },
    { id = 106, label = 'Gun Store' },
    { id = 108, label = 'Bar' },
    { id = 110, label = 'Gym' },
    { id = 120, label = 'Fast Food' },
    { id = 162, label = 'Mod Shop (Los Santos Customs)' },
    { id = 171, label = 'Bank' },
    { id = 175, label = 'Motorcycle Shop' },
    { id = 181, label = 'Vehicle Dealer' },
    { id = 198, label = 'Gas Station' },
    { id = 225, label = 'Clothing Store Alt' },
    { id = 280, label = 'Fishing' },
    { id = 306, label = 'Flight School' },
    { id = 408, label = 'Garage (Alt)' },
    { id = 429, label = 'Boating' },
    { id = 500, label = 'Star' },
    { id = 514, label = 'House' },
}

-- Common blip colors for quick selection
-- Full list: https://docs.fivem.net/docs/game-references/blips/
Config.CommonColors = {
    { id = 0, label = 'White' },
    { id = 1, label = 'Red' },
    { id = 2, label = 'Green' },
    { id = 3, label = 'Blue' },
    { id = 4, label = 'White (Alt)' },
    { id = 5, label = 'Yellow' },
    { id = 6, label = 'Light Red' },
    { id = 7, label = 'Violet' },
    { id = 8, label = 'Pink' },
    { id = 9, label = 'Light Orange' },
    { id = 10, label = 'Cyan' },
    { id = 11, label = 'Light Yellow' },
    { id = 12, label = 'Orange' },
    { id = 17, label = 'Light Blue' },
    { id = 25, label = 'Dark Purple' },
    { id = 27, label = 'Dark Blue' },
    { id = 29, label = 'Police Blue' },
    { id = 38, label = 'Gold' },
    { id = 40, label = 'Light Green' },
    { id = 43, label = 'Light Pink' },
    { id = 46, label = 'Olive' },
    { id = 47, label = 'Brown' },
    { id = 48, label = 'Dark Teal' },
}

-- Admin command to open blip manager
Config.AdminCommand = 'blips'
