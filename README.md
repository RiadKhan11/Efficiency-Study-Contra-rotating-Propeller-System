# Contra-Rotating Propeller System — Fortran

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

See [`examples/typical-case/FA8.DAT`](examples/typical-case/FA8.DAT). The input is **fixed-width** Fortran data, not comma-separated text. There are exactly **eight records** (four records for each propeller):

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

## Citation

Khan, M. R., Kundu, R., Rahaman, W., Haque, M. M., & Ullah, M. R. (2018). Efficiency study: Contra-rotating propeller system. In AIP Conference Proceedings (Vol. 1980, No. 1, Article 060001). International Conference on Mechanical Engineering (ICME 2017), Dhaka, Bangladesh. https://doi.org/10.1063/1.5044369 
