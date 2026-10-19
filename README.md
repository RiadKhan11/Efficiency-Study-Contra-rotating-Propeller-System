# Contra-Rotating Propeller System — Fortran

Fortran implementation of the **self- and mutually induced velocity** calculations developed in the 2017 B.Sc. thesis **_Energy Study: Contra-rotating Propeller System_**, Department of Naval Architecture and Marine Engineering, Bangladesh University of Engineering and Technology (BUET).

**Thesis authors:** Md Riad Khan and Shoeba Islam (2017).  
**Academic supervisor acknowledged in the thesis:** Dr. Refayet Ullah.  
**Purpose:** archive the original research program in a readable, buildable, and testable repository.

> **Reproducibility note:** The published Fortran listing has an apparent `E1`/`E2` assignment error in the bound-vortex section. The default mode deliberately preserves that line because it best reproduces the thesis's published numerical tables. An opt-in `--corrected-bound-angle` mode implements the likely intended assignment, but **it has not been independently validated**. See [transcription and numerical notes](docs/TRANSCRIPTION_NOTES.md).

## What it calculates

The program uses a lifting-line/circulation model with the **Biot–Savart law**. The flow induced by each propeller is represented through three vortex contributions:

- **Helical tip vortex**: numerically integrated over a 27-segment discretization.
- **Hub vortex**: analytical contribution.
- **Bound vortex**: computed over eight radial blade strips.

Results are the non-dimensional axial (`UA/VS`), tangential (`UT/VS`), and radial (`UR/VS`) induced velocities at eight radial positions. Four tables are generated:

1. Self-induced velocities at the **fore** propeller.
2. Velocities mutually induced by the **fore** propeller at the **aft** propeller.
3. Self-induced velocities at the **aft** propeller.
4. Velocities mutually induced by the **aft** propeller at the **fore** propeller.

The broader **thesis** also discusses blade-element efficiency and comparisons with a single propeller. **Those separate efficiency calculations are not implemented in this Fortran program**, which covers the induced velocities in Section 4.1.

## Quick start

Requires **GNU Fortran (`gfortran`)**, `make`, and (for testing) Python 3. No external Fortran libraries.

```bash
# Ubuntu / Debian:
sudo apt-get install gfortran make python3

# In this repository:
make             # compile to build/contra_rotating_propeller
make run         # run the eight-line example, original printed-code behavior
make test        # check program execution and published reference tables
make run-corrected  # optional, experimental bound-vortex angle correction
make clean       # remove generated outputs / build files
```

Running `make run` writes to `examples/typical-case/`:

- **`FA8.OUT`** — detailed intermediate calculations for tip, hub, and bound vortices.
- **`FA88.OUT`** — the four tabulated induced-velocity results.

The executable reads **`FA8.DAT` from its current working directory**; both output files are written to the same directory. This retains the original filename convention. To run another scenario, create a new folder containing your own `FA8.DAT` and launch the compiled executable from inside that folder.

## Sample input

See [`examples/typical-case/FA8.DAT`](examples/typical-case/FA8.DAT), transcribed from the thesis's **Section 4.2, page 33**. The input is **fixed-width** Fortran data, not comma-separated text. There are exactly **eight records** (four records for each propeller):

| Record | Content | Format |
| --- | --- | --- |
| 1 | Fore propeller: blade count `NBL`, tip hydrodynamic pitch angle `BETAW`, maximum circulation `CIRM`, axial position `ZT`, tip radius `XT`, tip angle `TT` | `5X,I1,5F7.4` |
| 2 | Fore inducing propeller: nine strip-boundary radii `XR` | `5X,9F6.4` |
| 3 | Aft receiving propeller: nine strip-boundary radii `XRS` | `5X,9F6.4` |
| 4 | Fore propeller: eight section circulation values `CIRC` | `5X,8F6.4` |
| 5 | Aft propeller: parameters corresponding to record 1 | `5X,I1,5F7.4` |
| 6 | Aft inducing propeller: nine strip-boundary radii `XR` | `5X,9F6.4` |
| 7 | Fore receiving propeller: nine strip-boundary radii `XRS` | `5X,9F6.4` |
| 8 | Aft propeller: eight section circulation values `CIRC` | `5X,8F6.4` |

The first **five character positions** are skipped on every input line. The numbers are fixed-width and may appear without whitespace separators. Retain the leading spaces in your input.

**Example geometry:** four blades on the fore propeller and five blades on the aft propeller. The original model hard-codes a fore/aft radius ratio of `0.933`, which is consistent with the approximate diameters in the thesis's design table (7 m / 6.531 m).

## Reproducing the thesis

The published table values from **Section 4.4, page 42** are included in [`docs/thesis_reference_output.csv`](docs/thesis_reference_output.csv). Run `make test` to perform:

- a compile/run integration check;
- verification of all 32 generated table rows and finite numeric values;
- approximate numerical comparison against the thesis's tabulated values; and
- a smoke test of the experimental correction mode.

**Known limitation:** in the self-induced **fore** table, the axial component varies significantly relative to the published results for some stations. The bound-vortex calculation is nearly singular when the field point lies on the blade plane, and floating-point/compiler behavior appears to affect those terms. For this reason, the automated tests **do not assert a numerical match for those eight axial entries**; they do check all other table components. This is a faithful transcription exercise, **not a validation of the physical accuracy of the computational method**.

## Repository layout

```text
.
├── .github/workflows/fortran.yml    # GitHub Actions build and integration tests
├── .gitignore
├── Makefile
├── README.md
├── CITATION.cff                    # GitHub citation metadata
├── src/contra_rotating_propeller.f90 # original calculation, formatted for modern compilers
├── examples/typical-case/FA8.DAT    # thesis sample fixed-width input
├── tests/test_example.py            # stdlib-only integration tests
└── docs/
    ├── thesis.pdf                   # full 2017 B.Sc. thesis
    ├── thesis_reference_output.csv  # published Section 4.4 output
    └── TRANSCRIPTION_NOTES.md       # provenance and computational caveats
```

## Research assumptions and limitations

The thesis's model assumes each propeller blade can be represented by a bound vortex, a hub vortex, and a helical tip vortex. It considers slipstream interaction between the two propellers, but **does not model time-dependent blade-passing effects**. The sample program assumes two propellers with eight radial strips each, applies fixed numerical integration subdivisions, and is not a general-purpose CFD solver.

The original thesis should be cited when reusing this research; see [`CITATION.cff`](CITATION.cff) and the [complete thesis](docs/thesis.pdf).

## Authorship, permissions, and licensing

The PDF is provided for academic documentation and source provenance. Original credit remains with the thesis's **two authors**. **No open-source license is asserted or included** because permission from all relevant rights holders has not been established. Before publicly publishing, distributing, or licensing the code and PDF, confirm permission from the coauthor and any institution with applicable rights, decide on an appropriate software license, and review the thesis PDF for personal information.

## Publishing to GitHub

Once you have reviewed the attribution, PDF inclusion, and licensing with your coauthor:

```bash
git init
git add .
git commit -m "Archive contra-rotating propeller Fortran thesis project"
# With GitHub CLI installed and authenticated:
gh repo create contra-rotating-propeller-fortran --private --source=. --remote=origin --push
```

The repository can be made public later if rights and sharing preferences permit. For an existing GitHub repository, add your remote and push in the usual way.
