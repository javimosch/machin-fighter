# machin-fighter

**Two tiny neural nets learned to fight by fighting each other** — Hall-of-Fame
self-play co-evolution, in pure [machin](https://github.com/javimosch/machin) (MFL)
with [tinybrain](https://github.com/javimosch/tinybrain). No dataset, no scripted
teacher: the agents *are* each other's sparring partner.

A Street-Fighter-style **footsies engine with no physics** — a discrete frame-data
state machine. Seven actions (walk fwd/back, punch, kick, block, jump), real
**startup / active / recovery** windows, hitstun, blockstun, knockback. A
`[13 → 20 → 7]` tanh net (one small JSON artifact) reads 13 mirror-symmetric
senses (spacing, both fighters' states) and picks an action by argmax. The design
is a **rock-paper-scissors of spacing**: kicks out-range punches but recover slow
(whiff-punishable), a **jump has evasion i-frames** (airborne dodges attacks) but
you can't act until you land, and blocking mitigates but a **turtle still bleeds
to chip** under pressure — so there's no degenerate dominant strategy. Animated:
a walk cycle (striding legs + swinging arms) and a tucked jump.

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

- The champion beats **both** scripted archetypes decisively — the aggressive
  rushdown bot **30/30** and the defensive turtle **30/30** — and **KOs the
  exhibition rival 8/8**. Fights are lively: approach, whiff-punish, block,
  jump-evade, KO.
- **Two honest lessons this build taught, both baked in:**
  1. *Scoring HP-margin bred a passive meta* — two competent nets learned "never
     commit, wait to punish" and just **stared at each other**. The fix: reward
     damage **dealt** plus a **big bonus for an actual KO**, so decisiveness is
     selected and real fights emerge.
  2. *Co-evolution has no total order* — "best vs the bots" ≠ "best vs peers" (an
     early champion was the strongest *duelist* yet lost 0/30 to the bots). So the
     shipped champion is picked by **competence** (beating the bots), and the
     exhibition pits it against a **former champion** whose different style yields
     a real fight (a same-net-vs-itself match just stares). That non-transitivity —
     a rock-paper-scissors roster from zero hand-design — is the fun part.

## Run it

```sh
./build.sh          # vendors raylib, builds the viewer
./fight-game        # watch champion vs a former champion; press H to fight it
                    #   ←/→ move · Z punch · X kick · ↓ block · ↑ jump

# retrain from scratch (writes ml/models/fighter.json + Elo snapshots):
machin encode ml/vendor/tinybrain.src ml/vendor/evolve.src src/fight.src ml/fight_evolve.src | machin run /dev/stdin
# verify (unseen seeds + Elo ladder):
machin encode ml/vendor/tinybrain.src ml/vendor/evolve.src src/fight.src ml/fight_eval.src | machin run /dev/stdin
```

Live browser demo (physics-free engine + inference in wasm, JS only draws):
**https://javimosch.github.io/machin-fighter/**
