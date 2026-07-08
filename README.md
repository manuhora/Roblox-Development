# 🎮 Roblox Dev Log

A running collection of Roblox systems and scripts I build while learning game dev in Lua/Luau. Not one single game — more of a toolbox/journal that grows every time I figure out something new (or break something and fix it).

## 🗂️ What's in here right now

### Quest Module *(in progress)*
Server-authoritative quest system — the server is the source of truth, the client just displays what it's told. Currently working through:
- Quest state tracking
- Server ↔ client communication
- Objective/progress handling

More to come as it gets built out.

## 🛠️ Tech

- **Language:** Lua / Luau
- **Engine:** Roblox Studio
- **Architecture:** Server-authoritative (client is never trusted with game logic)

## 📁 Structure

```
/QuestModule
  QuestManager.luau      -- server-side quest logic
  QuestUI.luau            -- client-side display
  ...
```

## 📜 License

MIT — steal it, learn from it, whatever. Just don't blame me if it breaks.
