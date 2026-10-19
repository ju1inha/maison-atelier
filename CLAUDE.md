# Maison Atelier — Project Brief for Claude Code

This file is the source of truth for the project. Read it fully at the start of every session. Sections marked **[CONFIRM]** are proposed design that Julia hasn't locked in yet. Ask before building them, and update this file once she decides.

## 1. About the developer (how to work with me)

- I'm Julia, a Media Studies student with a CS minor. I'm comfortable with HTML/CSS/JS basics but I'm not a professional engineer, and I'm new to Godot.
- Explain what you change and why in plain language. Tell me which file each change is in.
- Make small, testable steps. After each meaningful change, tell me exactly how to run and check it (which scene to open, which key to press, what I should see).
- Ask before big structural rewrites, before adding plugins/addons, or before deleting anything.
- Keep the code readable over clever. Add short comments on anything non-obvious.
- This is a portfolio-quality personal project and the repo is **public**. Polish and aesthetic consistency matter as much as features.

## 2. Concept

**Working title:** Maison Atelier. An earlier prototype was called "Elite Stylist: Couture Atelier."

**One-line pitch:** A luxury boutique styling game where you run an elegant atelier, dress demanding clients for high-stakes moments, and build relationships and reputation in a glamorous fashion world.

### Inspirations

These games inspire the feel and mechanics. Everything in Maison Atelier (characters, art, names, UI assets, music, text) must be original. Do not copy anything from these games or from real fashion houses.

**1. Style Savvy: Trendsetters (Nintendo 3DS): the boutique and styling core**

- You run your own fashion boutique. Customers walk in, describe what they want (often vaguely), and you pick items from your stock to match.
- Customers have their own taste. Satisfying them means reading their request and their personal style.
- You buy stock from brands at a wholesale showroom. Each brand has a distinct style identity, and new brands unlock as you progress.
- Trends shift, so what sells changes over time.
- You dress models for styling contests and themed challenges, and other services (hair, makeup) open up as your business grows.
- What we take from it: the satisfying request → style → reaction loop, brand-driven stock buying, distinct style categories, and the joy of growing a shop.
- What we change: a more mature, luxury, editorial tone (couture houses, galas, Fashion Week) instead of a cute mall boutique; deeper scoring feedback; relationships with recurring clients.

**2. Persona 5: confidants, calendar and style**

- Confidants: a cast of characters you build bonds with by spending free time with them. Each has a rank from 1 to 10 and a personal story that unfolds as the rank rises.
- Each confidant rank unlocks concrete perks: new abilities, discounts, extra actions or shortcuts. That makes relationships both emotionally and mechanically rewarding.
- Calendar and time slots: each day has limited free time. Choosing who to see or what to do is the core strategic tension.
- Social stats: the player's personal stats rise through activities, and some relationships or options need a minimum stat.
- Visual identity: bold, high-contrast UI, striking typography, angular graphic menus and dramatic transitions. Even menus feel stylish.
- What we take from it:
  - Fashion-world confidants such as a fashion editor, a rival stylist, an up-and-coming designer, a photographer, a model and a mentor **[CONFIRM cast]**, each with a rank 1–10 story arc and atelier perks (exclusive stock, event invitations, scoring bonuses, VIP clients).
  - Day/time-slot planning.
  - Possibly stylist stats like Taste, Poise, Network and Craft that gate certain clients and events **[CONFIRM]**.
  - Persona-level UI drama translated into a luxury palette: black, ivory, champagne gold, one bold accent.

**3. Open world: an explorable fashion city [CONFIRM details]**

- Instead of only menus, the player explores a city or district on foot, discovering locations rather than picking them from a list.
- Possible locations: the atelier (home base), designer showrooms and flagship stores, a café or tea salon where confidants hang out, a gallery, a hotel ballroom for galas, a runway venue, a fabric market, a park or boulevard for street-style spotting.
- Exploring could reveal street-style trends, chance encounters with new clients or confidants, hidden boutiques with rare pieces, and seasonal changes such as decorations for Fashion Week or weather.
- Districts unlock as reputation grows, from a charming side street to the luxury avenue to the couture quarter.

### How the three combine

- Style Savvy = what you do (style clients, run the boutique).
- Persona 5 = how your time and relationships work (calendar, confidants, perks, stylish UI).
- Open world = where it happens (an explorable, living fashion city).

**Fantasy for the player:** "I have impeccable taste, and the most exclusive people in the city trust me with their most important moments."

### Design pillars

1. **Taste is the skill.** Success comes from reading clients and making cohesive, intentional looks, not from grinding.
2. **Luxury in every pixel.** UI, copy, sound and pacing should feel refined, calm and expensive.
3. **Relationships matter.** Clients and contacts remember you, and their stories develop over time.
4. **Meaningful choices with limited time.** Each day you can't do everything. What you prioritize shapes your atelier.

## 3. Project status

- **Phase 0 (done):** Concept prototyped in Base44 as "Elite Stylist: Couture Atelier."
- **HTML/JS prototype (skipped):** Julia decided (2026-10-19) to skip the browser prototype and build directly in Godot, starting from scratch.
- **Current:** Godot 4.7 project created and pushed to a public GitHub repo. No gameplay yet.
- **Next:** decide 2D vs. 3D for the first slice (see section 7), then build the first playable slice (section 8).

### Decisions log

- 2026-10-19: Engine is **Godot 4.7.2 (standard, GDScript, not .NET)**. The Godot editor lives on Julia's Desktop: `C:\Users\julia\OneDrive\Desktop\Godot_v4.7.2-stable_win64.exe`.
- 2026-10-19: Project lives at `C:\Users\julia\OneDrive\Desktop\Projects\MaisonAtelier`.
- 2026-10-19: Repo is public from day one (portfolio piece): https://github.com/ju1inha/maison-atelier
- 2026-10-19: Long-term goal is a 3D game. Art starts as placeholder shapes and gets swapped for real models later (see section 7, "Placeholder art and swapping in real models").

## 4. Core gameplay loop

```
Morning: plan the day (calendar)
   ↓
Open the boutique → clients arrive with requests
   ↓
Read the brief (occasion, mood, budget, personality, hints in dialogue)
   ↓
Style a look from your inventory (top, bottom/dress, shoes, bag, accessories)
   ↓
Present the look → client reaction + score
   ↓
Earn money + reputation, improve relationship with the client
   ↓
Evening: restock, browse designer showrooms, attend events, or spend time with contacts
   ↓
Next day (season/calendar progresses, trends shift)
```

## 5. Game systems

### 5.1 Clients

Each client has:

- `name`, `portrait`, `personality` (e.g. classic, avant-garde, minimalist, romantic, edgy) **[CONFIRM list]**
- `occasion` for this visit (gala, gallery opening, business dinner, wedding guest, runway front row, vacation)
- `budget` (min/max)
- `preferred_styles` / `disliked_styles` / `preferred_colors` / `disliked_colors`
- `relationship_level` (0–10) and story flags for recurring clients
- Dialogue lines for greeting, the request (with subtle hints), and reactions (thrilled / pleased / disappointed)

Requests should be readable through dialogue hints, not raw stat lists. For example, "Something that won't get lost against a white marble gallery" implies a strong color or statement piece.

### 5.2 Wardrobe / inventory

Each item has:

- `id`, `name`, `designer` (fictional house), `category` (top, bottom, dress, outerwear, shoes, bag, jewelry, accessory)
- `style_tags` (e.g. "minimalist", "romantic", "evening", "tailored")
- `colors`, `material`, `season`
- `price` (retail) and `cost` (what the boutique paid)
- `rarity` (ready-to-wear, limited, couture)
- `image` / `model`

Stock is limited. Selling a piece removes it, so restocking matters.

### 5.3 Styling and scoring

A look is scored on **[CONFIRM weights]**:

- **Occasion fit:** Do the style tags match the event?
- **Client taste:** preferred vs. disliked styles and colors
- **Cohesion:** Do the pieces work together (color harmony, consistent formality)?
- **Budget:** within range; going over budget is a penalty unless the relationship is high
- **Trend bonus:** pieces matching the current season's trends
- **Signature bonus:** optional flair rewards for bold but correct choices

Output: a score (0–100) mapped to a reaction tier, plus money, reputation and relationship changes. The client should give specific feedback ("The shoes are a touch too casual for a gala") so players learn.

### 5.4 Boutique management

- Money (spend on stock, upgrades), Reputation (unlocks clients, designers, events)
- Restocking: buy from fictional designer showrooms; better houses unlock with reputation
- Atelier upgrades: decor, display windows, fitting rooms, which affect ambiance and client tiers **[CONFIRM]**
- Window display: choose featured pieces to attract certain client types **[CONFIRM]**

### 5.5 Calendar and time (Persona-inspired)

- Days are split into slots (e.g. Morning / Afternoon / Evening) **[CONFIRM]**
- Boutique hours take a slot; other slots go to showrooms, events, contacts or rest
- Seasons (Spring/Summer, Fall/Winter) bring trend shifts and seasonal events like Fashion Week
- Deadlines: specific clients book appointments for future big events

### 5.6 Relationships / contacts

- Recurring clients and industry contacts (a rival stylist, a fashion editor, a young designer, a photographer) **[CONFIRM cast]**
- Spending time with them advances their relationship rank and short story arcs
- Ranks unlock perks: exclusive stock, event invitations, scoring bonuses, new clients

### 5.7 Events (high-stakes moments)

- Gala nights, runway shows and editorial shoots where you style a high-profile client or multiple looks
- Bigger rewards, harder briefs, possibly a timer or multi-look requirement **[CONFIRM]**

### 5.8 Progression

- Reputation tiers, e.g. Emerging Atelier → Notable → Celebrated → Iconic Maison **[CONFIRM names]**
- Each tier unlocks clients, designers, upgrades and story beats
- Long-term goal / ending: e.g. a flagship show at the season's biggest Fashion Week **[CONFIRM]**

## 6. Art direction and UI

**Mood:** quiet luxury meets editorial drama. It should look like a high-end fashion magazine, with Persona-style energy in the transitions and menus.

- **Palette [CONFIRM]:** ivory / cream backgrounds, deep black, champagne gold accents, one bold signature accent (e.g. oxblood or emerald) for highlights and transitions.
- **Typography:** an elegant high-contrast serif for headings (e.g. Playfair Display or Cormorant Garamond) and a clean sans-serif for UI text (e.g. Inter or Montserrat). Both are free (SIL Open Font License) and can be bundled in the game.
- **Layout:** generous white space, thin gold rules, editorial grids, large confident headings.
- **Motion:** smooth fades and slides; one bold stylized transition for big moments like presenting a look or a rank-up.
- **Screens:**
  1. Title screen
  2. Day planner / calendar
  3. City / district (explorable)
  4. Boutique floor (clients arrive)
  5. Client brief (portrait + dialogue)
  6. Styling screen (mannequin/character in the center, inventory grid filtered by category, outfit slots)
  7. Reveal / reaction screen (score, feedback, rewards)
  8. Inventory / stock room
  9. Designer showroom (buying)
  10. Contacts / relationships
  11. Settings and save/load
- **Accessibility:** readable font sizes, sufficient contrast, keyboard and controller navigation where feasible, and no information conveyed only by color.

## 7. Technical design (Godot 4.7, GDScript)

### 2D or 3D for the first slice [CONFIRM]

The long-term goal is 3D. Julia said 2D is fine for now. Trade-off to decide before building the city:

- **2D first:** faster to get playable; menus, data, scoring, calendar and save/load all carry over to 3D unchanged. The city scenes (map, player movement, camera) would be rebuilt later.
- **3D with placeholder shapes from the start:** a bit more setup (camera, lighting), but the city never has to be rebuilt; real models are swapped in later.

Either way, everything that isn't the city (UI screens, data, scoring, calendar, saves) is identical.

### Placeholder art and swapping in real models

The rule that keeps art swaps from breaking code: **game scripts never talk to the art directly.**

- Every world object (the player, a client, a building, a mannequin) is its own scene, e.g. `scenes/world/client.tscn`.
- The root node holds the script and the gameplay pieces (collision shape, interaction area). The art lives in a single child node named `Visual`.
- Placeholder: `Visual` is a capsule/box mesh (3D) or a colored rectangle/`Sprite2D` (2D).
- Real art later: delete the placeholder under `Visual` and drop in the imported model (`.glb` exported from Blender, or a free CC0 asset) or the new sprite. Scripts, collisions and signals are untouched.
- If a model needs animation, the script calls a small helper (e.g. `play_anim("walk")`) on the `Visual` scene, so the script doesn't care which model is inside.
- Clothing items reference their art by path in their data file (e.g. `model = "res://assets/models/items/silk_blouse.glb"`). Swapping art = changing a path in data, not code.

### Structure

- Game data as Godot Resources (`.tres`) or JSON in `data/`, so content can grow without touching logic.
- A single autoloaded `GameState` singleton (money, reputation, day, time slot, inventory, relationships, flags) with clear functions to update it.
- Save/load to `user://` (Godot's per-user save folder) as JSON.
- Scoring logic in a standalone script of pure functions (no node dependencies) so it's easy to test.
- Suggested folder structure (adapt as it grows):

```
project.godot
scenes/
  main.tscn             # boots the game, switches screens
  ui/                   # title, calendar, brief, styling, reveal, inventory, showroom, contacts, settings
  world/                # city districts, player, clients, buildings
scripts/
  autoload/game_state.gd  # game state + save/load
  scoring.gd              # styling score logic (pure functions)
data/
  items/  clients/  designers/
assets/
  fonts/  images/  models/  audio/
```

### Godot workflow notes for Claude

- Godot editor: `C:\Users\julia\OneDrive\Desktop\Godot_v4.7.2-stable_win64.exe` (a `_console.exe` variant next to it prints errors to the terminal). Use it headless to check for script errors, e.g. `--headless --path <project> --quit`.
- Claude can't see the running game. Ask Julia to play-test and describe or screenshot what she sees.
- `.godot/` is a cache folder and is git-ignored. Don't commit it.
- The project is in a OneDrive-synced folder. If OneDrive causes sync conflicts with `.git` or `.godot`, consider pausing sync for this folder or moving it out of OneDrive.

## 8. Roadmap

1. Project setup + public GitHub repo (done 2026-10-19)
2. Decide 2D vs. 3D for the first slice
3. First playable slice: one small district (the "charming side street") with the atelier and 2–3 buildings, a player you can walk around, and press E to enter the atelier
4. Core loop inside the atelier: one client → brief → style → score → reward
5. Data-driven items and clients (at least 30 items, 8 clients)
6. Clear, specific client feedback
7. Day/calendar loop with restocking
8. Save/load
9. Visual polish pass (typography, transitions, reveal screen)
10. One relationship arc + one event, as a vertical slice
11. Later: more districts, audio, real models and animation

## 9. Working rules for Claude Code

- Before coding a feature, give a short plan and confirm it with me.
- Don't invent final names, the story or the art. Propose options and let me choose.
- Keep all content original and fictional, with no real brands or copyrighted game assets. Only use third-party assets with clear licenses (CC0 preferred) and credit them in the README.
- Use placeholder art (simple shapes or labeled boxes) until real assets exist.
- Commit in small steps with clear messages; the repo is public.
- After each session, suggest updates to this CLAUDE.md so it stays current.
