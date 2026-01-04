# rpa-blips

<div align="center">

![GitHub Release](https://img.shields.io/github/v/release/RP-Alpha/rpa-blips?style=for-the-badge&logo=github&color=blue)
![GitHub commits](https://img.shields.io/github/commits-since/RP-Alpha/rpa-blips/latest?style=for-the-badge&logo=git&color=green)
![License](https://img.shields.io/github/license/RP-Alpha/rpa-blips?style=for-the-badge&color=orange)
![Downloads](https://img.shields.io/github/downloads/RP-Alpha/rpa-blips/total?style=for-the-badge&logo=github&color=purple)

**Dynamic Map Blip Manager with In-Game Admin Menu**

*Similar to Jaksam's Blips Creator*

</div>

---

## ✨ Features

- 📍 **Config + Database** - Default blips from config, dynamic blips from database
- 🛠️ **In-Game Admin Menu** - Create, edit, delete blips without server restart
- 📂 **Categories** - Organize blips by type (shops, services, emergency, etc.)
- 🎨 **27+ Sprites & 23+ Colors** - Quick selection with common presets
- 🔐 **Permission System** - QB-Core groups + server.cfg ConVar support
- 💾 **Database Persistence** - All changes saved to MySQL

---

## 📦 Dependencies

- `rpa-lib` (Required)
- `ox_lib` (Required)
- `oxmysql` (Required)

---

## 📥 Installation

1. Download the [latest release](https://github.com/RP-Alpha/rpa-blips/releases/latest)
2. Extract to your `resources` folder
3. Import the database:
   ```sql
   source sql/install.sql
   ```
4. Add to `server.cfg`:
   ```cfg
   ensure rpa-lib
   ensure rpa-blips
   ```

---

## 🗄️ Database Setup

Run the SQL file to create the `rpa_blips` table:

```sql
CREATE TABLE IF NOT EXISTS `rpa_blips` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `label` VARCHAR(100) NOT NULL,
    `coords` VARCHAR(100) NOT NULL,
    `sprite` INT DEFAULT 1,
    `color` INT DEFAULT 1,
    `scale` FLOAT DEFAULT 0.8,
    `category` VARCHAR(50) DEFAULT 'general',
    `short_range` TINYINT(1) DEFAULT 1,
    `created_by` VARCHAR(100),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## ⚙️ Configuration

### Default Blips

```lua
Config.DefaultBlips = {
    {
        label = "Police Station",
        coords = vector3(428.0, -984.0, 30.0),
        sprite = 60,
        color = 29,
        scale = 0.9,
        category = 'emergency'
    }
}
```

### Admin Permissions

```lua
Config.AdminPermissions = {
    groups = { 'admin', 'god' },
    jobs = {},
    convar = 'rpa:admins',           -- setr rpa:admins "steam:xxx,steam:yyy"
    resourceConvar = 'admin'          -- setr rpa_blips:admin "steam:xxx"
}
```

---

## ⌨️ Commands

| Command | Description |
|---------|-------------|
| `/blipsadmin` | Open admin blip management menu |

---

## 🎨 Available Sprites & Colors

The config includes `Config.CommonSprites` and `Config.CommonColors` with 27 sprites and 23 colors for quick selection in the admin menu.

---

## 🔐 Permissions

Admins can be set via:
1. **QB-Core Groups** - `admin`, `god`, etc.
2. **Global ConVar** - `setr rpa:admins "steam:xxx,steam:yyy"`
3. **Resource ConVar** - `setr rpa_blips:admin "steam:xxx"`

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/RP-Alpha">RP-Alpha</a></sub>
</div>
