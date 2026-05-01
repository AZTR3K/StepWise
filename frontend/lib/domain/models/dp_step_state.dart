/// Describes a single step in a DP algorithm visualization.
///
/// Supports three layouts:
///   • 1-D table       — [table1D] is non-null, [table2D] is null
///   • 2-D grid/matrix — [table2D] is non-null, [table1D] is null
///   • 1-D + arrows    — [table1D] and [arrows] are non-null (LIS)
class DPStepState {
  // ── Snapshot ──────────────────────────────────────────────────────────────

  /// 1-D table values (null-able cells for uninitialised slots).
  final List<num?>? table1D;

  /// 2-D grid values (null-able cells for uninitialised slots).
  final List<List<num?>>? table2D;

  // ── Highlighting ──────────────────────────────────────────────────────────

  /// Currently-being-written cell for 1-D (column index).
  final int? activeCol;

  /// Currently-being-written cell for 2-D (row, col).
  final int? activeRow;

  /// Secondary highlight — the cell(s) being *read* to compute activeCol /
  /// activeRow.  Can contain either 1-D column indices or 2-D (row*1000+col)
  /// packed ints — the renderer unpacks them.
  final List<int> readCells;

  /// Cells that are "done" / finalised (painted a completed colour).
  final List<int> doneCells;

  // ── LIS arrows ────────────────────────────────────────────────────────────
  /// For LIS: list of (fromIndex, toIndex) pairs representing predecessor
  /// arrows, encoded as (from * 1000 + to).
  final List<int> arrows;

  // ── Metadata ──────────────────────────────────────────────────────────────

  /// The human-readable explanation shown in the description panel.
  final String description;

  /// The formula / recurrence being applied at this step.
  final String formula;

  /// Line index into the pseudocode list to highlight.
  final int activeCodeLine;

  // ── Row / column labels for 2-D grids ────────────────────────────────────
  final List<String> rowLabels;
  final List<String> colLabels;

  // ── Input arrays (displayed as a reference row above the table) ───────────
  /// Original input array shown as a header above 1-D tables.
  final List<String> inputLabels;

  const DPStepState({
    this.table1D,
    this.table2D,
    this.activeCol,
    this.activeRow,
    this.readCells = const [],
    this.doneCells = const [],
    this.arrows = const [],
    required this.description,
    this.formula = '',
    this.activeCodeLine = 0,
    this.rowLabels = const [],
    this.colLabels = const [],
    this.inputLabels = const [],
  }) : assert(
          (table1D != null) != (table2D != null) ||
              (table1D == null && table2D == null),
          'Provide exactly one of table1D or table2D per step',
        );

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get is1D => table1D != null;
  bool get is2D => table2D != null;
  bool get hasArrows => arrows.isNotEmpty;

  /// Decode a packed 2-D index into (row, col).
  static (int row, int col) unpack2D(int packed) =>
      (packed ~/ 1000, packed % 1000);

  /// Pack a 2-D index.
  static int pack2D(int row, int col) => row * 1000 + col;
}