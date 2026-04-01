#!/usr/bin/env python3
import sys, os, re, time, select

try:
    sys.stdout.reconfigure(line_buffering=True)
    sys.stdin.reconfigure(encoding="utf-8", errors="ignore")
except Exception:
    pass

try:
    from rich.console import Console
    from rich.progress import (
        Progress,
        BarColumn,
        TextColumn,
        TaskProgressColumn,
    )
    from rich.text import Text
    from rich.live import Live
    from rich.table import Table
    from rich.style import Style
except ImportError:
    print("rich not installed. Run: pip install rich")
    sys.exit(1)

# ── Configuration ─────────────────────────────────────────────────────────────
TITLE_WIDTH = 50  # Increased width for the name field
BAR_WIDTH = 40
SEP = "[dim]·[/]"

try:
    from colors import PRIMARY, SECONDARY, SURFACE
except ImportError:
    PRIMARY = "#88c0d0"
    SECONDARY = "#a3be8c"
    SURFACE = "#4c566a"

console = Console(highlight=False)


def clean_title(title: str) -> str:
    title = re.sub(r"\[[^\]]*\]", "", title)
    title = re.sub(r"\([^)]*\)", "", title)
    title = re.sub(
        r"\b(Official|Lyric|Lyrics|Video|Music|4K|1080p|HD|HQ|Audio|Visualizer)\b",
        "",
        title,
        flags=re.IGNORECASE,
    )
    cleaned = re.sub(r"\s+", " ", title).strip()
    if len(cleaned) > TITLE_WIDTH:
        return cleaned[: TITLE_WIDTH - 3] + "..."
    return cleaned.ljust(TITLE_WIDTH)


def human_mib(n) -> str:
    try:
        v = float(n)
        if v >= 1024 * 1024 * 1024:
            return f"{v / (1024**3):.1f} GiB"
        return f"{v / (1024 * 1024):.1f} MiB"
    except Exception:
        return "0.0 MiB"


def format_time(seconds: float) -> str:
    if seconds < 1:
        return f"{int(seconds * 1000)}ms"
    m, s = divmod(int(seconds), 60)
    h, m = divmod(m, 60)
    return f"{h:02d}:{m:02d}:{s:02d}" if h else f"{m:02d}:{s:02d}"


# ── Layout builder ─────────────────────────────────────────────────────────────
def make_layout(
    track_title,
    stage,
    track_pct,
    overall_pct,
    index,
    total,
    speed,
    eta,
    dl_bytes,
    tot_bytes,
    elapsed,
) -> Table:

    stage_color = {
        "Downloading": PRIMARY,
        "Downloaded": SECONDARY,
        "Merging": "#ebcb8b",
        "In library": SURFACE,
    }.get(stage, PRIMARY)

    # Status Label (12 chars wide)
    status_label = f"[{stage_color}]{stage[:12].ljust(12)}[/{stage_color}]"
    display_speed = speed if (speed and speed != "—") else "N/A"

    # Track Size: "Current / Total"
    size_str = (
        f"{human_mib(dl_bytes)} / {human_mib(tot_bytes)}"
        if tot_bytes
        else "0.0 MiB / 0.0 MiB"
    )

    # --- Track Progress Bar ---
    track_bar = Progress(
        TextColumn(status_label),
        BarColumn(
            bar_width=BAR_WIDTH,
            complete_style=Style(color=SECONDARY),
            pulse_style=Style(color=SURFACE),
        ),
        TaskProgressColumn(style=Style(color=PRIMARY)),
        TextColumn(f" {SEP} [dim {SURFACE}]{size_str.rjust(18)}[/]"),
        TextColumn(f" {SEP} [dim {SURFACE}]{display_speed.rjust(9)}[/]"),
        TextColumn(f" {SEP} [dim {SURFACE}]{(eta if eta else '').rjust(8)}[/]"),
        console=console,
    )
    track_bar.add_task("", total=100, completed=track_pct)

    # --- Total Progress Bar ---
    total_eta_val = ""
    if overall_pct >= 100:
        total_eta_val = f"Done in {format_time(elapsed)}"
    elif overall_pct > 0:
        calc_eta = max(0, elapsed / (overall_pct / 100) - elapsed)
        total_eta_val = f"ETA {format_time(calc_eta)}"

    total_size_display = (
        f"{human_mib(dl_bytes)} / {human_mib(tot_bytes)}"
        if tot_bytes
        else "0.0 MiB / 0.0 MiB"
    )

    overall_bar = Progress(
        TextColumn(" " * 12),
        BarColumn(
            bar_width=BAR_WIDTH,
            complete_style=Style(color=PRIMARY),
            pulse_style=Style(color=SURFACE),
        ),
        TaskProgressColumn(style=Style(color=SURFACE)),
        TextColumn(f" {SEP} [dim {SURFACE}]{total_size_display.rjust(18)}[/]"),
        TextColumn(f" {SEP} [dim {SURFACE}]{total_eta_val.rjust(20)}[/]"),
        console=console,
    )
    overall_bar.add_task("", total=100, completed=overall_pct)

    # --- Grid Assembly ---
    grid = Table.grid(padding=(0, 0), expand=True)
    grid.add_column(no_wrap=True)
    grid.add_column(ratio=1)
    grid.add_column(no_wrap=True)

    left_track = Text.from_markup(
        f"[bold {PRIMARY}]{index:02d}[/] {SEP} [bold]{track_title}[/]"
    )
    grid.add_row(left_track, "", track_bar)

    grid.add_row("", "", "")

    left_total = Text.from_markup(f"[dim {SURFACE}]Total [[bold]{index}/{total}[/]][/]")
    grid.add_row(left_total, "", overall_bar)

    return grid


# ── State ──────────────────────────────────────────────────────────────────────
current_index = 1
current_total = 1
current_title = clean_title("Initializing…")
current_stage = "Downloading"
last_speed = ""
global_start = time.time()
percent = 0.0
final_drawn = False
dl_bytes = 0
tot_bytes = 0
eta_str = ""

spinner_frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
spin_idx = 0
fetching = True

with Live(console=console, refresh_per_second=10, transient=False) as live:
    try:
        while True:
            if fetching:
                rlist, _, _ = select.select([sys.stdin], [], [], 0.1)
                if rlist:
                    raw = sys.stdin.readline()
                    if not raw:
                        break
                    if raw.startswith("[download]"):
                        fetching = False
                        live.update(Text(""))
                    else:
                        continue
                else:
                    frame = spinner_frames[spin_idx % len(spinner_frames)]
                    live.update(
                        Text(
                            f"  {frame}  Fetching metadata…",
                            style=Style(color=SURFACE, italic=True),
                        )
                    )
                    spin_idx += 1
                    continue
            else:
                raw = sys.stdin.readline()
                if not raw:
                    break

            clean_line = raw.strip()

            if raw.startswith("[Merger]") or raw.startswith("[ffmpeg]"):
                current_stage = "Merging"
                overall_pct = (current_index / max(1, current_total)) * 100
                live.update(
                    make_layout(
                        current_title,
                        current_stage,
                        100,
                        overall_pct,
                        current_index,
                        current_total,
                        "N/A",
                        "",
                        dl_bytes,
                        tot_bytes,
                        time.time() - global_start,
                    )
                )
                continue

            if "has already been downloaded" in raw:
                full_path = (
                    raw.split("has already been downloaded")[0]
                    .replace("[download]", "")
                    .strip()
                )
                current_title = clean_title(
                    os.path.splitext(os.path.basename(full_path))[0]
                )
                current_stage = "In library"
                live.update(
                    make_layout(
                        current_title,
                        current_stage,
                        100,
                        100,
                        current_index,
                        current_total,
                        "N/A",
                        "",
                        0,
                        0,
                        time.time() - global_start,
                    )
                )
                continue

            if "|" not in clean_line:
                continue
            parts = clean_line.split("|")
            if len(parts) < 8:
                continue

            idx_str, tot_str, title, p_str, speed, eta, dlb, totb = parts[:8]
            try:
                current_index = int(idx_str) if idx_str.isdigit() else current_index
                current_total = int(tot_str) if tot_str.isdigit() else current_total
                if title and title not in ("NA", "None"):
                    current_title = clean_title(title.strip())
                last_speed = speed.strip() if speed.strip() else last_speed
                percent = float(p_str.replace("%", "").strip())
                eta_str = eta.strip()
                dl_bytes = dlb.strip()
                tot_bytes = totb.strip()
            except:
                continue

            current_stage = "Downloading" if percent < 100 else "Downloaded"
            overall_pct = (
                (current_index - 1 + percent / 100.0) / max(1, current_total)
            ) * 100
            live.update(
                make_layout(
                    current_title,
                    current_stage,
                    percent,
                    overall_pct,
                    current_index,
                    current_total,
                    last_speed,
                    eta_str,
                    dl_bytes,
                    tot_bytes,
                    time.time() - global_start,
                )
            )

        if not final_drawn:
            final_drawn = True
            live.update(
                make_layout(
                    current_title,
                    "Downloaded",
                    100,
                    100,
                    current_total,
                    current_total,
                    "N/A",
                    "",
                    dl_bytes,
                    tot_bytes,
                    time.time() - global_start,
                )
            )

    except (KeyboardInterrupt, EOFError):
        live.update(
            Text("  🛑  Download interrupted.", style=Style(color="#bf616a", bold=True))
        )
        sys.exit(130)
