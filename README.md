# 2-Way Set-Associative Cache — Verilog HDL

A synthesisable 2-Way Set-Associative Cache implemented in Verilog HDL as part of RTL Lab Week 4.  
The design covers the full pipeline from address decoding to LRU-based eviction and data output.

---

## Architecture Overview

The cache accepts a **7-bit address** split into three fields:

```
 [6:4]  Tag          (3 bits)
 [3:2]  Index        (2 bits → selects 1 of 4 sets)
 [1:0]  Block Offset (2 bits)
```

Each of the 4 sets holds **2 ways**, giving 8 total cache lines.  
Each cache line stores: `Valid bit | 3-bit Tag | 32-bit Data`.

```
Address [6:0]
    │
    ▼
┌─────────────────────┐
│   address_separator │  → tag [2:0], index [1:0], block_offset [1:0]
└─────────────────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌────────┐
│ Way 0  │ │ Way 1  │   ← cache_way (4×32-bit RAM per way)
│V|Tag|D │ │V|Tag|D │
└────┬───┘ └───┬────┘
     │         │
     ▼         ▼
┌───────────────────┐
│   hit_miss_logic  │   → way0_hit, way1_hit, hit, miss
└────────┬──────────┘
         │
┌────────▼──────────┐
│ cache_controller  │   → way0_we, way1_we, way_sel (LRU logic)
└────────┬──────────┘
         │
    ┌────▼────┐
    │   MUX   │         → data_out [31:0]
    └─────────┘
```

---

## Modules

| File | Module | Role |
|---|---|---|
| `address_separator.v` | `address_separator` | Slices the 7-bit address into Tag, Index, and Block Offset using continuous assignments |
| `cache_way.v` | `cache_way` | Single cache way — 4-entry arrays for valid, tag, and data; synchronous write, asynchronous read |
| `hit_miss_logic.v` | `hit_miss_logic` | Combinational comparators: asserts `hit` if either way's tag matches and its valid bit is set |
| `cache_controller.v` | `cache_controller` | Write-enable decision logic and 1-bit LRU register array; handles hit-update, empty-fill, and eviction |
| `cache_top.v` | `cache_top` | Structural top module wiring all sub-modules and the output data MUX |

---

## Replacement Policy — 1-bit LRU

Each set has one LRU bit:

| LRU bit | Meaning |
|---|---|
| `0` | Way 0 is oldest → evict Way 0 on next conflict |
| `1` | Way 1 is oldest → evict Way 1 on next conflict |

The bit is updated **synchronously on every hit or write**:
- Touch Way 0 → LRU = `1` (Way 1 becomes oldest)
- Touch Way 1 → LRU = `0` (Way 0 becomes oldest)

---

## Write Scenarios (cache_controller)

| Scenario | Condition | Action |
|---|---|---|
| A | Write hit on Way 0 | Update Way 0 |
| B | Write hit on Way 1 | Update Way 1 |
| C | Miss, Way 0 invalid | Fill Way 0 |
| D | Miss, Way 1 invalid | Fill Way 1 |
| E | Miss, both valid | Evict LRU way and write |

---

## Simulation — Testbench

`tb_cache.v` drives the design through a linear sequence of 7 tests:

| Test | Operation | Expected Result |
|---|---|---|
| 1 | Read before any write | **MISS** (all valid bits = 0) |
| 2 | Write Tag `001` → Index `00` | Fills Way 0 |
| 3 | Read Tag `001` → Index `00` | **HIT** on Way 0, data = `AAAA1111` |
| 4 | Write Tag `010` → Index `00` | Fills Way 1 (LRU points to Way 1) |
| 5 | Read Tag `010` → Index `00` | **HIT** on Way 1, data = `BBBB2222` |
| 6 | Write Tag `011` → Index `00` | Both ways full → **LRU evicts Way 0** |
| 7a | Read old Tag `001` | **MISS** (evicted) |
| 7b | Read new Tag `011` | **HIT**, data = `CCCC3333` |

Clock period: **10 ns**. Results verified via `$display` in the Tcl console.

---

## File Structure

```
two_way_set_associative_cache/
├── two_way_set_associative_cache.srcs/
│   ├── sources_1/new/
│   │   ├── address_separator.v
│   │   ├── cache_way.v
│   │   ├── hit_miss_logic.v
│   │   ├── cache_controller.v
│   │   └── cache_top.v
│   └── sim_1/new/
│       └── tb_cache.v
└── reports/
    ├── generate_report.py    ← generates cache_report.docx
    └── cache_report.docx
```

---

## Reference

Architecture based on the MIT 6.004 2-Way Set-Associative Cache diagram:  
https://people.csail.mit.edu/devadas/6.004/Lectures/lect18/sld013.htm
