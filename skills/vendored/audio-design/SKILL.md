---
name: audio-design
description: Engine-agnostic game-audio practice, adapted for Roblox. Covers bus/mixer layout, gain in decibels, headroom, ducking, adaptive music by layering and re-sequencing, SFX variation and beat sync. Use when organizing Roblox sound into SoundGroups (music, SFX, UI, ambience), adding volume or mute settings, ducking music under important sounds, making music react to gameplay, killing repetitive "machine-gun" SFX, syncing visuals to a beat, or choosing which audio assets can legally play in a Roblox game (Roblox-licensed library audio only).
---

# Audio design

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

Game audio is a mixing graph plus a music system. Route every sound through a few buses so groups can be balanced, and make music react to play instead of looping one track.

## On Roblox

- **Buses are `SoundGroup`s** under `SoundService` (for example `Music`, `SFX`, `UI`, `Ambience`). Every `Sound` sets `Sound.SoundGroup`. Settings sliders and a mute toggle drive `SoundGroup.Volume`.
- **Volumes are linear amplitude** (`Sound.Volume` and `SoundGroup.Volume` range 0 to 10; a Sound defaults to 0.5). Map a slider through decibels: `volume = 10^(dB/20)`.
- **Effects** are children of a Sound or SoundGroup: `ReverbSoundEffect`, `CompressorSoundEffect`, `EqualizerSoundEffect`, `PitchShiftSoundEffect`. Ducking is a compressor on Music keyed from a voice/SFX group, or simply tweening the Music group's volume down and back. Roblox also has a newer wire-based Audio API (`AudioPlayer`, `AudioFader`, ...). Pick one model per game.
- **Sources:** use only Roblox-licensed library audio (APM Music, Pro Sound Effects) or built-in `rbxasset://sounds`. Other creators' private uploads won't play in your game. Test that every id actually plays.
- **Client vs server:** music, UI and feedback sounds play on the client (`SoundService:PlayLocalSound`, or a local `Sound`). A sound played from a server script is heard by everyone.
- **3D sounds:** parent the Sound to a part or attachment and tune the rolloff (`RollOffMaxDistance`).
- **One-shots:** clone, play, and clean up on `Ended` (or `Debris`), or pool them.
- **Variation:** randomize `PlaybackSpeed` by about ±6% (this changes pitch and length) and rotate through a few takes.
- **Timing:** `Sound.TimePosition` is the music clock. `Sound.PlaybackLoudness` (client only) drives visualizers.

## Workflow

1. Lay out buses (Master, then Music, SFX, UI, Ambience, Voice) and never balance hundreds of clips one by one.
2. Work in decibels; convert to linear volume only at the edges.
3. Leave headroom so stacked sounds don't clip. Lower the busy groups rather than raising everything.
4. Duck competing sources: music dips under important sounds, then recovers.
5. Make music adaptive (layers and/or segments; see the reference), or at least crossfade between zone and state tracks.
6. Vary repeated SFX in pitch, volume and take.
7. Verify on real output, on headphones and a phone speaker. Check the balance, that ducking is audible without pumping, and that transitions land on the beat.

## Pitfalls

- Treating a 0 to 1 slider as linear amplitude feels like nothing happens until the bottom. Map it through decibels.
- Per-clip volumes instead of groups, so a global balance pass is impossible.
- Clipping when many sounds stack (coin bursts). Cap concurrent one-shots and lower that group.
- Pumping ducking: release too fast or ratio too high. Lengthen the release.
- One looping music track for the whole game. Use per-zone tracks, layers or a shuffled playlist.
- Beat sync from frame time drifts. Read `TimePosition`.
- Leaking one-shot Sounds that are never destroyed.
- Unlicensed or private audio that plays in Studio for you but is silent for players.

## References

- `references/adaptive-music.md`: vertical layering vs horizontal re-sequencing, quantized transitions, stingers, intensity mapping with hysteresis, and Roblox-specific constraints.

Related: `game-feel` (the sound layer of every feedback bundle), `roblox-lessons`.

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `SOURCE.md`.
