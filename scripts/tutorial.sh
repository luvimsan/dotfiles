#!/bin/bash

# Format keybindings with categories
cat << 'EOF' | yad --text-info --back=#1c1c1c --fore=#cdd6f4 \
    --geometry=800x600 --title="SXHKD Keybindings" \
    --fontname="Monospace 14" --wrap --no-buttons \
    --show-cursor --borders=0 --undecorated --center --window-icon=info

Press Escape to close this window
╔══════════════════════════════════════════════════════════════╗
║                         APPLICATIONS                         ║
╠══════════════════════════════════════════════════════════════╣
║ windows + b              → brave        (Browser)            ║
║ windows + shift + U      → file manager (My PC)              ║
║ windows + m              → video chooser                     ║
║ windows + l              → pdf chooser                       ║
║ windows + Return         → terminal                          ║
╚══════════════════════════════════════════════════════════════╝
╔══════════════════════════════════════════════════════════════╗
║                         WINDOWS                              ║
╠══════════════════════════════════════════════════════════════╣
║ windows + shift + q      → close window                      ║
║ windows + shift + l      → lock screen                       ║
╚══════════════════════════════════════════════════════════════╝
╔══════════════════════════════════════════════════════════════╗
║                        WORKSPACES                            ║
╠══════════════════════════════════════════════════════════════╣
║ windows + 1-9           → switch to workspace                ║
║ windows + shift + 1-9   → move window to workspace           ║
║ windows + Tab           → next workspace                     ║
╚══════════════════════════════════════════════════════════════╝
╔══════════════════════════════════════════════════════════════╗
║                          SYSTEM                              ║
╠══════════════════════════════════════════════════════════════╣
║ windows + shift + s     → take screenshot                    ║
║ F2                      → show this help                     ║
╚══════════════════════════════════════════════════════════════╝
EOF
