# Dr. Corrosion

Public distribution repository for the **Dr. Corrosion** Arkadeon cartridge.

The game source remains private. This repository publishes only release artifacts, release notes, and the public install surface.

## Current release target

**0.1.5 — Music-ready Level-1 demo**

The 0.1.5 cartridge contains the offline procedural Level-1 score plus the sealed post-Level-1 Moka reveal of **“Alles im grünen Bereich”**. The author WAV, private source tree, private world/save data, and canonical external R17 are not published here.

## Install

Once 0.1.5 is published, use the public installer:

https://domnspace.github.io/Dr-Corrosion/

The distribution pipeline is reproducible and fail-closed: it checks out one pinned private source commit using a read-only token, verifies the immutable theme master, reproduces the exact AAC + Opus runtime payload, builds the DRC, reopens the completed archive to verify the audio again, then publishes only the finished distribution artifacts.

## Public artifacts

- `dr-corrosion.drc`
- `cartridge-index.json`
- `build-info.json`
- `Dr-Corrosion-Arkadeon-0.1.5.zip`
- release notes / install page

No private development source is mirrored into this repository.
