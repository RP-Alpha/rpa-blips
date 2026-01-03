# rpa-blips

A simple configuration-based map blip manager.

## Features
- **Config Driven**: Add blips easily via `config.lua`.
- **Optimization**: Handles blip creation efficiently on resource start.

## Installation
1. Add `ensure rpa-blips` to your `server.cfg`.

## Configuration
Edit `config.lua`:
```lua
Config.Blips = {
    {
        coords = vector3(x, y, z),
        sprite = 1,
        color = 1,
        scale = 0.8,
        label = "My Blip"
    }
}
```

## Credits
- RP-Alpha Development Team

## License
MIT
