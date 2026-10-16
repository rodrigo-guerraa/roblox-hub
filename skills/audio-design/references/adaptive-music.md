# Adaptive (dynamic) music

Adaptive music changes with gameplay instead of looping one track. Two techniques dominate, and they combine. Where this conflicts with `roblox-lessons`, `roblox-lessons` wins.

- **Vertical layering (re-orchestration):** several stems (drums, bass, melody, tension pad) play in sync, and layers fade in and out to change intensity without changing the underlying loop.
- **Horizontal re-sequencing:** the music is split into segments (intro, loop A, loop B, combat, outro), and you switch which one plays next at musical boundaries (a bar or phrase) so the change lands on the beat.

## Roblox reality check

- Roblox-licensed library tracks usually come as **finished mixes, not stems**, so true vertical layering needs stems you own the rights to and upload yourself.
- With library audio, the practical options are:
  - crossfading between tracks per zone or state,
  - a shuffled playlist,
  - an ambience bed (jungle, wind, lava) under the music,
  - stingers for big moments.
- Several `Sound`s started together can drift apart over time. If you layer stems, compare their `TimePosition`s periodically and nudge the stragglers.
- Test every loop seam; a gap or click betrays the loop.

## Vertical layering

All layers are the same length and start together; only their volumes change.

```lua
local layers = { base = baseSound, drums = drumSound, tension = tensionSound }

local function startLayers()
	for _, s in layers do
		s.Volume = 0
		s.Looped = true
		s:Play()
	end
	layers.base.Volume = 0.5
end

local function setIntensity(level)
	local fade = TweenInfo.new(1, Enum.EasingStyle.Sine)
	TweenService:Create(layers.drums, fade, { Volume = level >= 1 and 0.5 or 0 }):Play()
	TweenService:Create(layers.tension, fade, { Volume = level >= 2 and 0.5 or 0 }):Play()
end
```

Author the stems at the same BPM and length and export them aligned. Fades of about 0.5 to 1.5 s feel musical; instant cuts feel mechanical.

## Horizontal re-sequencing

Queue a change and apply it only at the next bar boundary:

```lua
local BPM, BEATS_PER_BAR = 120, 4
local secPerBar = 60 / BPM * BEATS_PER_BAR

local function timeToNextBar(sound)
	return secPerBar - (sound.TimePosition % secPerBar)
end

local function requestSection(current, nextSound)
	task.delay(timeToNextBar(current), function()
		crossfade(current, nextSound, 0.2)
	end)
end
```

Transition strategies, roughly in increasing polish:

- **Immediate crossfade:** a quick volume blend; fine for low-stakes changes (entering a zone).
- **Quantized switch:** wait for the next beat, bar or phrase, then switch.
- **Transition segments:** short bridge clips written to connect A to B.
- **Stingers:** one-shot musical accents over the bed (a rare hatch, a rebirth, a new zone) that don't alter the loop. Duck the bed briefly under them.

## Mapping gameplay to intensity

Drive music from a small, smoothed intensity value, not from raw events:

```lua
intensity += (raw - intensity) * 0.05

local function levelFrom(i, current)
	if current < 1 and i > 0.6 then return 1 end
	if current >= 1 and i < 0.4 then return 0 end
	return current
end
```

The different up and down thresholds (hysteresis) stop the music from oscillating when the intensity hovers near a boundary. In a simulator, the inputs might be the zone, an active server event, a boss or rare spawn nearby, or the player opening a celebration reveal.

## Practical notes

- Take timing from the music's own clock (`TimePosition`), not frame delta.
- Many simultaneous long Sounds cost memory. Keep the stem count modest, and stop tracks that are faded to 0 for a long time.
- Give players a music mute or volume control (on a SoundGroup) that is separate from SFX.

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `../SOURCE.md`.
