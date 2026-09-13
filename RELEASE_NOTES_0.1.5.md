# Dr. Corrosion 0.1.5 — Music-ready Level-1 demo

0.1.5 keeps the accepted Level-1 game and canonical external R17 intact while finishing the browser soundtrack as a release feature rather than an audition layer.

## Player-facing changes

- The shipped Arkadeon WebAudio renderer remains the canonical offline score at 174 BPM.
- Game-state changes are phrase-safe: ordinary scene changes wait for the next complete two-bar boundary, while a special finding may still rupture immediately.
- The Level-1 arc has explicit public score identities for rain/tea, Director/C16, Moka, HTW, laboratory flow, first finding, special finding, presentation, M06, M07 and the post-Level-1 institute.
- After Level 1 is complete, returning physically to the public `COFFEE-MOKA` station can reveal the authored vocal theme. One full familiar Moka phrase plays first, followed by a two-bar crossfade into the song over a quiet procedural underlay. Leaving Moka cancels the reveal cleanly.
- Arkadeon's START/system menu exposes persistent master music volume and mute controls.
- Visibility changes suspend/resume audio safely; music remains expressive only and never gates gameplay.

## Sealed runtime audio

The author WAV remains immutable source material and is **not** packaged. The cartridge contains exactly two browser delivery encodes, both required and reverified from the finished DRC:

- AAC-LC / M4A: 6,902,360 bytes — `68e4497d20814b9c7be5e39c3d0052e6776e22d987dd42ba23878212284c0449`
- Opus / Ogg: 5,292,011 bytes — `78f309b27ecc0d60c07970744df16c6046f952ea55571eff7661b7c198326746`
- combined sealed runtime audio: 12,194,371 bytes

The source master itself is pinned by size and SHA-256 before reproduction. The release tooling recreates the AAC fast-start container and normalizes the otherwise-random Opus Ogg serial, then refuses publication unless the exact browser-asset hashes above are reproduced.

## Unchanged release boundaries

- Canonical R17 remains external, immutable and unchanged.
- Existing safe/private world persistence remains unchanged.
- No hidden simulator truth crosses the public music-state boundary.
- No Icecast, localhost, Suno or other network service is required at runtime.
- Level 2 remains intentionally outside this release.
