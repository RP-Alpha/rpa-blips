# rpa-blips

<div align="center">

![GitHub Release](https://img.shields.io/github/v/release/RP-Alpha/rpa-blips?style=for-the-badge&logo=github&color=blue)
![GitHub commits](https://img.shields.io/github/commits-since/RP-Alpha/rpa-blips/latest?style=for-the-badge&logo=git&color=green)
![License](https://img.shields.io/github/license/RP-Alpha/rpa-blips?style=for-the-badge&color=orange)
![Downloads](https://img.shields.io/github/downloads/RP-Alpha/rpa-blips/total?style=for-the-badge&logo=github&color=purple)

**Configuration-Based Map Blip Manager**

</div>

---

## ✨ Features

- 📍 **Config Driven** - Add blips via simple Lua table
- ⚡ **Optimized** - Efficient blip creation on resource start
- 🎨 **Customizable** - Full control over sprite, color, scale

---

## 📥 Installation

1. Download the [latest release](https://github.com/RP-Alpha/rpa-blips/releases/latest)
2. Extract to your `resources` folder
3. Add to `server.cfg`:
   ```cfg
   ensure rpa-blips
   ```

---

## ⚙️ Configuration

Edit `config.lua`:

```lua
Config.Blips = {
    {
        coords = vector3(x, y, z),
        sprite = 1,
        color = 1,
        scale = 0.8,
        label = "My Location"
    }
}
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/RP-Alpha">RP-Alpha</a></sub>
</div>
