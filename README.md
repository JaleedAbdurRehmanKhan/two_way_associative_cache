# Reports – 2-Way Set-Associative Cache

This folder contains the technical report and its generator script for the **RTL Lab Week 4** project: a 2-Way Set-Associative Cache implemented in Verilog HDL.

---

## Folder Contents

| File | Description |
|---|---|
| `generate_report.py` | Python script that reads all Verilog source files and produces the Word report |
| `cache_report.docx` | Generated Word report (re-run the script to regenerate) |

---

## Report Structure

The generated `cache_report.docx` follows this heading hierarchy (TOC-compatible):

```
Title       →  2-Way Set-Associative Cache
TOC         →  Table of Contents (update field in Word)
Heading 1   →  1. Task
Heading 1   →  2. Description
  Heading 2 →    File Structure
Heading 1   →  3. Design Files
  Heading 3 →    address_separator.v
  Heading 3 →    cache_way.v
  Heading 3 →    hit_miss_logic.v
  Heading 3 →    cache_controller.v
  Heading 3 →    cache_top.v
Heading 1   →  4. Testbench
  Heading 3 →    tb_cache.v
Heading 1   →  5. Waveform          ← placeholder
Heading 1   →  6. Tcl Console       ← placeholder
Heading 1   →  7. Schematic         ← placeholder
```

---

## How to Regenerate the Report

Requires Python and the `python-docx` library.

```bash
# Install dependency (one-time)
pip install python-docx

# Run from this folder
python generate_report.py
```

The script reads source files directly from the Vivado project paths:

- **Sources:** `..\two_way_set_associative_cache.srcs\sources_1\new\`
- **Simulation:** `..\two_way_set_associative_cache.srcs\sim_1\new\`

---

## Updating the TOC in Word

The report embeds a live Word TOC field covering Heading 1–3.

1. Open `cache_report.docx` in Microsoft Word
2. Right-click the Table of Contents placeholder
3. Select **Update Field → Update entire table**

---

## Completing the Placeholders

Three sections are left as placeholders to be filled manually in Word:

| Section | What to insert |
|---|---|
| **5. Waveform** | Vivado simulation waveform screenshots |
| **6. Tcl Console** | Tcl console output showing `$display` results |
| **7. Schematic** | RTL elaborated design schematics from Vivado |
