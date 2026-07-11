# machin-fighter

**Two tiny neural nets learned to fight by fighting each other** — Hall-of-Fame
self-play co-evolution, in pure [machin](https://github.com/javimosch/machin) (MFL)
with [tinybrain](https://github.com/javimosch/tinybrain). No dataset, no scripted
teacher: the agents *are* each other's sparring partner.

A Street-Fighter-style **footsies engine with no physics** — a discrete frame-data
state machine. Eight actions (walk fwd/back, punch, kick, block, jump, fireball),
real **startup / active / recovery** windows, hitstun, blockstun, knockback,
projectiles, and jump-dodges-fireball. A `[16 → 20 → 8]` tanh net (one small JSON
artifact) reads 16 mirror-symmetric senses (spacing, both fighters' states, the
fireball) and picks an action by argmax. The design is a **rock-paper-scissors of
spacing**: kicks out-range punches but recover slow (whiff-punishable), fireballs
zone but lose to jump-ins, and blocking mitigates ~70% but a **turtle still bleeds
to chip** under pressure — so there's no degenerate dominant strategy.

## Self-play (tinybrain `coevolve_run`)

A genome's fitness is its **HP margin against a league** — a sample of past
champions (the Hall of Fame) plus two scripted anchors (an aggressive rushdown
bot and a defensive turtle). The HoF + anchors are the standard fix for the
red-queen trap (naive `A>B>C>A` self-play cycles forever): scoring against frozen
past selves forces monotone improvement and a real **Elo ladder**. This is the
same `coevolve_run` framework loop that [machin-pong](https://github.com/javimosch/machin-pong)
pulled into tinybrain — a second competitive consumer, only the game changed.

## Results (honest)

Trained in ~3 min single-threaded, verified on **unseen match seeds**:

- **Self-play drove real skill** — the Elo ladder is monotone: each champion
  beats the one before (gen-100 champ beats gen-60 **24/24**, gen-130 beats
  gen-100 **24/24**). The strongest **duelist** (by round-robin over the whole
  Hall of Fame) beats the runner-up with a **KO, ~56–0**, and beats a pure
  **turtle 30/30**. Fights are lively — spacing, whiff-punishes, fireball zoning,
  jump-ins.
- **An honest non-transitivity** (and the coolest finding): **no single champion
  dominates every style** — the champion selected for beating the scripted
  *bots* turned out to be the *worst* duelist, and the best duelist gets countered
  by the hyper-aggressive rushdown bot (~12/30). That's rock-paper-scissors —
  exactly the dynamic of a real fighting-game roster, emergent from self-play with
  zero hand-design. The shipped `fighter.json` is the best **duelist**; the
  exhibition pits it against a former champion (a different style → a real fight,
  not a same-net stare-down).

## Run it

```sh
./build.sh          # vendors raylib, builds the viewer
./fight-game        # watch champion vs champion; press H to fight it
                    #   ←/→ move · Z punch · X kick · ↓ block · ↑ jump · C fireball

# retrain from scratch (writes ml/models/fighter.json + Elo snapshots):
machin encode ml/vendor/tinybrain.src ml/vendor/evolve.src src/fight.src ml/fight_evolve.src | machin run /dev/stdin
# verify (unseen seeds + Elo ladder):
machin encode ml/vendor/tinybrain.src ml/vendor/evolve.src src/fight.src ml/fight_eval.src | machin run /dev/stdin
```

Live browser demo (physics-free engine + inference in wasm, JS only draws):
**https://javimosch.github.io/machin-fighter/**
