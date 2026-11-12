#!/usr/bin/env python3
"""Rebuilds MiniGameHubAllInOne.swift from the files in ../MiniGameHub.

Run it after editing the real sources so the copy-paste version stays in sync:

    python3 CopyPaste/regenerate.py
"""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
SOURCES = os.path.join(HERE, "..", "MiniGameHub")
OUTPUT = os.path.join(HERE, "MiniGameHubAllInOne.swift")

ORDER = [
    "MiniGameHubApp.swift",
    "Shared/GameKind.swift",
    "Shared/Theme.swift",
    "Shared/Haptics.swift",
    "Shared/HighScoreStore.swift",
    "Shared/GameSession.swift",
    "Shared/GameScreen.swift",
    "Hub/HubView.swift",
    "Logic/MoveDirection.swift",
    "Logic/MergeBoard.swift",
    "Logic/SnakeEngine.swift",
    "Games/MoonDash/RunnerGameView.swift",
    "Games/MoonDash/RunnerScene.swift",
    "Games/TileFuse/MergeGameView.swift",
    "Games/TileFuse/MergeScene.swift",
    "Games/NeonSnake/SnakeGameView.swift",
    "Games/NeonSnake/SnakeScene.swift",
]

HEADER = """\
// Mini Game Hub, all in one file.
//
// How to use:
//   1. Xcode > File > New > Project > iOS > App.
//      Interface: SwiftUI. Language: Swift. Minimum deployment: iOS 16 or later.
//   2. Delete the two Swift files Xcode created (ContentView.swift and
//      <YourProjectName>App.swift).
//   3. Add this file to the project and press Run.
//
// This file is generated from the sources in the MiniGameHub folder by
// CopyPaste/regenerate.py. Edit those sources, not this copy.

import SwiftUI
import SpriteKit
import Combine
import UIKit
"""

on_disk = set()
for folder, _, names in os.walk(SOURCES):
    for name in names:
        if name.endswith(".swift"):
            on_disk.add(os.path.relpath(os.path.join(folder, name), SOURCES))
missing = on_disk - set(ORDER)
if missing:
    raise SystemExit("Add these files to ORDER in regenerate.py: %s" % sorted(missing))

parts = [HEADER]
for relative in ORDER:
    with open(os.path.join(SOURCES, relative)) as handle:
        text = handle.read()
    text = re.sub(r"^import \w+\n", "", text, flags=re.M).strip("\n")
    title = "// MARK: - " + relative
    parts.append("\n// " + "=" * 74 + "\n" + title + "\n// " + "=" * 74 + "\n\n" + text + "\n")

with open(OUTPUT, "w") as handle:
    handle.write("".join(parts))
print("Wrote %s (%d lines)" % (os.path.relpath(OUTPUT), "".join(parts).count("\n")))
