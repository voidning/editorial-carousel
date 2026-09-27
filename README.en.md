[中文](README.md) | **English**

# editorial-carousel

Turn an article, a teardown, or a pile of notes into a set of **editorial-style** image cards.

Lay it out in HTML/CSS → render each page headlessly to 1080×1440 → ship with plain-text copy ready to paste.
The visual language is magazine-spread: parchment ground, serif headings, hairline rules, captions, kickers, folios, generous margins.

Built for **text-heavy** subjects — long-form teardowns, research notes, design analysis.
Not for pure diagrams or checklists (that's a different tool).

---

## Output

All 10 cards below were produced by this skill, with no post-processing:

<table>
<tr>
<td width="50%"><img src="examples/naturalist-visual-study/01-cover.jpg" width="100%"><br><sub>01 Cover — one-sentence claim + hero image</sub></td>
<td width="50%"><img src="examples/naturalist-visual-study/02-three-films.jpg" width="100%"><br><sub>02 Triptych — three objects side by side</sub></td>
</tr>
<tr>
<td width="50%"><img src="examples/naturalist-visual-study/03-wunderkammer.jpg" width="100%"><br><sub>03 Big-word page — one term per page</sub></td>
<td width="50%"><img src="examples/naturalist-visual-study/04-imagery.jpg" width="100%"><br><sub>04 Text + image — argument and its evidence</sub></td>
</tr>
<tr>
<td width="50%"><img src="examples/naturalist-visual-study/05-materiality.jpg" width="100%"><br><sub>05 Text + image — centred in remaining space</sub></td>
<td width="50%"><img src="examples/naturalist-visual-study/06-stance.jpg" width="100%"><br><sub>06 Pull quote — a position, not a fact</sub></td>
</tr>
<tr>
<td width="50%"><img src="examples/naturalist-visual-study/07-palette.jpg" width="100%"><br><sub>07 Palette — parameters the reader can copy</sub></td>
<td width="50%"><img src="examples/naturalist-visual-study/08-type.jpg" width="100%"><br><sub>08 Type specimen</sub></td>
</tr>
<tr>
<td width="50%"><img src="examples/naturalist-visual-study/09-prompt-recipe.jpg" width="100%"><br><sub>09 Recipe — a table you can lift wholesale</sub></td>
<td width="50%"><img src="examples/naturalist-visual-study/10-keywords.jpg" width="100%"><br><sub>10 Closing — keywords, one line, sources</sub></td>
</tr>
</table>

> The case study tears down the naturalist visual language of three Anthropic brand films. See `examples/naturalist-visual-study/`.

---

## What it does

| | |
| --- | --- |
| **Renders** | 1080×1440 (3:4) portrait cards, 8–12 per set; filename order = upload order |
| **Lays out** | A full CSS skeleton with 9 page archetypes — swap the text and go |
| **Writes copy** | Three title options + plain-text body, paste-ready |
| **Re-renders** | Change one page, re-render only that page |

**Does not**: generate imagery (bring your own), produce animation/video, or stitch long vertical images.

---

## Usage

### Install

Clone it into a skill directory:

```bash
# user-level (available to every project)
git clone https://github.com/voidning/editorial-carousel.git \
  ~/.workbuddy/skills/editorial-carousel

# or project-level
git clone https://github.com/voidning/editorial-carousel.git \
  <project>/.workbuddy/skills/editorial-carousel
```

### Workflow

1. **Decide the claim and page order** — write the one sentence that becomes the cover subtitle, then pick archetypes per page.
2. **Lay out** — copy `assets/base.html` into your working directory, delete unused archetypes, fill in content. Resize images to 1080–1600 wide first.
3. **Render**
   ```bash
   bash assets/render.sh layout.html ./out 10            # all 10 pages
   PAGES=3,9 bash assets/render.sh layout.html ./out 10  # only pages 3 and 9
   ```
4. **Self-check** — generate thumbnails and review every page for overflow, cropping, awkward line breaks, and mid-page voids.
   ```bash
   for f in out/*.png; do sips -s format jpeg -s formatOptions 74 --resampleWidth 620 \
     "$f" --out "/tmp/preview-$(basename "$f" .png).jpg"; done
   ```
5. **Copy** — follow `references/publishing.md` for plain-text titles and body.

---

## Layout

```
SKILL.md                      trigger description, workflow, hard rules
assets/base.html              full skeleton — 9 page archetypes, all CSS included
assets/render.sh              batch renderer, supports re-rendering selected pages
references/layout-rules.md    type scale, archetype routing, whitespace, line breaks, checklist
references/publishing.md      image specs, plain-text copy rules, collection, post-publish edits
examples/                     finished case study
```

---

## Hard rules (each one earned)

- **Headless screenshots need `--no-sandbox`.** Without it Chrome's child processes get blocked and **the screenshot silently doesn't happen** — exit code 0, empty output directory. Easy to misdiagnose as a bad path. `render.sh` sets it.
- **Body text must not go below 26 px** at 1080 wide. 20 px ends up around 7 pt on a phone. Enlarging type *will* overflow — review every page and cut words or split pages. **Never shrink type to cram content into one page.**
- **No monospace on elements containing CJK.** `SF Mono` and friends have no CJK glyphs; the text falls back through the stack and ends up with erratic letter-spacing and weight. Tag CJK labels with `.zh` to switch back to sans.
- **Never set a fixed height on an image with its own aspect ratio** — it crops content. Wrap it in `.media` to centre it in the remaining space.
- **No mid-page voids.** Text at the top with the image pushed to the bottom via `margin-top:auto` leaves 250 px+ of dead space — it looks unfinished because it is. Use `.media` on image pages and `.note` to anchor text pages.
- **Copy must be plain text.** The platform doesn't parse markdown: `**bold**`, `> quote`, `- list` all render as literal characters. Build hierarchy from blank lines and section marks (`▍`, `—`).
- **Don't manually rename rendered files.** `render.sh` emits `0X.png`; rename them and the next render writes a fresh `0X.png` alongside the old ones — a reliable way to ship a stale image. Either change the `printf` in the script or do one batch rename right before delivery.
- **Order of delivery**: images first, copy second.

---

## Requirements

- macOS (`sips` for image compression; override the Chrome path with the `CHROME` env var)
- Google Chrome (headless rendering)
- `python3` (page offset injection)
- Font stack prefers `Tiempos Text` / `Iowan Old Style` / `Palatino`, falling back to `Songti SC` → `Source Han Serif SC` for Chinese. Without a serif face the result still works but looks a tier worse.

---

## License

Code and docs: MIT. The cards in `examples/` are **critical commentary** on publicly released brand films — the source footage belongs to its original authors and is included only to demonstrate output. Non-commercial.

The analysis text, palette, and layout structure are free to reuse.
