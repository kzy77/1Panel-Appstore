# Ignis - Run Obsidian in the browser

Ignis is a compatibility shim that provides browser-compatible implementations of the Electron APIs used by Obsidian, allowing Obsidian to run in a standard browser while keeping your vault on the server. Obsidian is not included in the image; the container downloads it from its official source on first run.

## Usage

1. After install, open `http://<your-ip>:8080`. The first start takes a minute or two to download Obsidian.
2. The default `PUID/PGID` is 1000; adjust to your host user (run `id`).
3. With no vaults yet, Ignis opens the vault manager to create your first one.

> [!IMPORTANT]
> Before exposing Ignis to other machines, put authentication in front of it and serve it over HTTPS. It has no built-in auth, so anyone who reaches an open instance can read and write the whole vault, and outside a secure context (HTTPS, or localhost) the browser disables features Ignis needs.

## Key features

- Core Obsidian: editor, canvas, bases, command palette, themes, and CSS snippets.
- Most community plugins built on Obsidian's plugin API (plugins needing Node native modules or `child_process` do not load).
- File upload and download, multi-vault support (create, open, switch, rename, delete).
- Live sync between tabs over WebSocket, so edits propagate within a second.
- Obsidian Sync in a logged-in tab, or server-side Headless Sync.

## Documentation

- Website: <https://ignis.thiefling.com/>
- Deploy guide: <https://ignis.thiefling.com/docs/server/deploy/>
- GitHub: <https://github.com/Nystik-gh/ignis>
