#!/usr/bin/env python3
import sys, os, shutil, time, unicodedata, re, select

try:
    sys.stdout.reconfigure(line_buffering=True)
    sys.stdin.reconfigure(encoding="utf-8", errors="ignore")
except Exception:
    pass

sys.path.append(os.path.dirname(os.path.realpath(__file__)))
try:
    from colors import PRIMARY, SECONDARY, SURFACE
except ImportError:
    PRIMARY, SECONDARY, SURFACE = "#88c0d0", "#a3be8c", "#4c566a"


def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


PRIMARY_RGB   = hex_to_rgb(PRIMARY)
SECONDARY_RGB = hex_to_rgb(SECONDARY)
SURFACE_RGB   = hex_to_rgb(SURFACE)
GREEN_RGB     = (120, 200, 120)

RESET  = "\033[0m"
FILLED = "▓"
EMPTY  = "░"


def rgb(r, g, b):
    return f"\033[38;2;{r};{g};{b}m"


def visual_len(text):
    plain = re.sub(r"\033\[[0-9;]*m", "", text)
    return sum(2 if unicodedata.east_asian_width(c) in "WF" else 1 for c in plain)


def human_mib(n):
    try:
        return f"{float(n) / (1024 * 1024):.1f}MiB"
    except Exception:
        return "0.0MiB"


def format_time(seconds):
    if seconds < 1:
        return f"{int(seconds * 1000)}ms"
    m, s = divmod(int(seconds), 60)
    h, m = divmod(m, 60)
    return f"{h:02d}:{m:02d}:{s:02d}" if h else f"{m:02d}:{s:02d}"


def render_bar(percent, width, start_rgb, end_rgb):
    percent = max(0.0, min(float(percent), 100.0))
    filled  = int(width * percent / 100)
    diff    = [end_rgb[i] - start_rgb[i] for i in range(3)]
    out     = []
    for i in range(width):
        if i < filled:
            r = int(start_rgb[0] + diff[0] * i / width)
            g = int(start_rgb[1] + diff[1] * i / width)
            b = int(start_rgb[2] + diff[2] * i / width)
            out.append(rgb(r, g, b) + FILLED + RESET)
        else:
            out.append(rgb(*SURFACE_RGB) + EMPTY + RESET)
    return "".join(out)


def clean_title(title: str) -> str:
    title = re.sub(r"\[[^\]]*\]", "", title)
    title = re.sub(r"\([^)]*\)", "", title)
    title = re.sub(
        r"\b(Official|Lyric|Lyrics|Video|Music|4K|1080p|HD|HQ|Audio|Visualizer)\b",
        "", title, flags=re.IGNORECASE,
    )
    return re.sub(r"\s+", " ", title).strip()


def fit_title(text, width):
    if visual_len(text) <= width:
        return text.ljust(width)
    trimmed = text
    while visual_len(trimmed) > width - 3:
        trimmed = trimmed[:-1]
    return trimmed + "..."


def build_total_line(index, total, overall_pct, speed, elapsed, tw, final=False):
    index_block   = f"[Total: {index}/{total}]"
    speed_block   = f"[{speed}]"
    elapsed_block = f"[{format_time(elapsed)}]"
    status_block  = "[Done]" if final else ""

    if not final and overall_pct < 100:
        total_eta = max(0, elapsed / (overall_pct / 100) - elapsed) if overall_pct > 0 else 0
        eta_block = f"[ETA {format_time(total_eta)}]" if overall_pct > 0 else ""
    else:
        eta_block = ""

    right_part = " | ".join(filter(None, [speed_block, elapsed_block, status_block or eta_block]))
    static_w   = visual_len(index_block) + visual_len(right_part) + 9
    bar_w      = max(20, tw - static_w)
    bar        = render_bar(100 if final else overall_pct, bar_w, PRIMARY_RGB, SECONDARY_RGB)
    return f"{index_block} | {bar} | {right_part}"


def build_track_line(display_title, stage, percent, eta, dl_bytes, tot_bytes, tw):
    TITLE_WIDTH = int(tw * 0.35)
    STAGE_WIDTH = 13
    SIZE_WIDTH  = 20
    TIME_WIDTH  = 12

    if stage == "Merging":
        size_col  = "".ljust(SIZE_WIDTH)
        time_col  = "".ljust(TIME_WIDTH)
    else:
        size_col  = (" " + f"{human_mib(dl_bytes)} / {human_mib(tot_bytes)}").ljust(SIZE_WIDTH)
        if percent < 100:
            time_col = (f"ETA {eta}" if eta not in ("NA", "00:00", "") else "").ljust(TIME_WIDTH)
        else:
            time_col = "".ljust(TIME_WIDTH)

    title_col = fit_title(f"[{display_title}]", TITLE_WIDTH)
    stage_col = (" " + f"[{stage}]").ljust(STAGE_WIDTH)
    static_w  = visual_len(title_col) + visual_len(stage_col) + visual_len(size_col) + visual_len(time_col) + 12
    bar_w     = max(10, tw - static_w)
    bar       = render_bar(percent, bar_w, SECONDARY_RGB, GREEN_RGB)
    return f"{title_col} | {stage_col} | {bar} | {size_col} | {time_col}"


# ---------- State ----------
current_index     = None
sealed_index      = None
current_total     = 1
current_title     = "Initializing"
current_stage     = "Downloading"
track_start_time  = None
last_speed        = "0B/s"
live_block_active = False
global_start_time = time.time()
percent           = 0.0
final_drawn       = False

# Track whether current item has been "committed" to history
# so a same-title re-download (video+audio) overwrites instead of appending
committed_title   = None

spinner_frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
spin_idx  = 0
fetching  = True

sys.stdout.write("\033[?25l")
sys.stdout.flush()

tw        = shutil.get_terminal_size().columns
separator = "-" * tw

try:
    while True:
        if fetching:
            rlist, _, _ = select.select([sys.stdin], [], [], 0.1)
            if rlist:
                raw = sys.stdin.readline()
                if not raw:
                    break
                if raw.startswith("[download]"):
                    sys.stdout.write("\r\033[K")
                    sys.stdout.flush()
                    fetching = False
                else:
                    continue
            else:
                frame = spinner_frames[spin_idx % len(spinner_frames)]
                sys.stdout.write(f"\rFetching metadata {frame}")
                sys.stdout.flush()
                spin_idx += 1
                continue
        else:
            raw = sys.stdin.readline()
            if not raw:
                break

        clean_line = raw.strip()
        tw         = shutil.get_terminal_size().columns
        separator  = "-" * tw

        # ---- Merger / ffmpeg line: overwrite current row with [Merging] ----
        if raw.startswith("[Merger]") or raw.startswith("[ffmpeg]"):
            if live_block_active:
                sys.stdout.write("\033[6A")
                merge_line = build_track_line(
                    f"{current_index:02d} - {current_title}",
                    "Merging", 100, "", 0, 0, tw
                )
                sys.stdout.write("\r\033[K" + merge_line + "\r")
                sys.stdout.write("\033[3B")
                sys.stdout.write("\033[J")
                live_block_active = False
                sys.stdout.flush()
            sealed_index = current_index
            continue

        # ---- Already-in-library ----
        if "has already been downloaded" in raw:
            full_path     = raw.split("has already been downloaded")[0]
            full_path     = full_path.replace("[download]", "").strip()
            current_title = clean_title(os.path.splitext(os.path.basename(full_path))[0])
            current_stage = "In library"

            TITLE_WIDTH  = int(tw * 0.35)
            STAGE_WIDTH  = 13
            title_col    = fit_title(f"[{current_title}]", TITLE_WIDTH)
            stage_col    = (" " + f"[{current_stage}]").ljust(STAGE_WIDTH)
            skipped_line = f"{title_col} | {stage_col} |"

            if live_block_active:
                sys.stdout.write("\033[5A\033[J")
                live_block_active = False

            sys.stdout.write("\r\033[K" + separator + "\n")
            sys.stdout.write("\r\033[K" + skipped_line + "\n")
            sys.stdout.write("\r\033[K" + separator)
            sealed_index     = current_index
            track_start_time = None
            sys.stdout.flush()
            continue

        if "|" not in clean_line:
            continue

        parts = clean_line.split("|")
        if len(parts) < 8:
            continue

        idx_str, tot_str, title, p_str, speed, eta, dl_bytes, tot_bytes = parts[:8]

        try:
            new_idx   = int(idx_str) if idx_str.isdigit() else (current_index or 1)
            new_title = clean_title(title.strip()) if title and title not in ("NA", "None") else current_title

            # Same index, same title = video+audio multi-pass → reuse live block
            same_item = (
                current_index is not None and
                new_idx == current_index and
                new_title == current_title and
                live_block_active
            )

            if current_index is not None and new_idx > current_index:
                live_block_active = False
                committed_title   = None

            current_index = new_idx

            if tot_str.isdigit():
                current_total = int(tot_str)
            if title and title not in ("NA", "None"):
                current_title = new_title
            if speed and speed not in ("NA", ""):
                last_speed = speed.strip()

            percent = float(p_str.replace("%", "").strip())
        except Exception:
            continue

        # If same item re-starts (audio pass after video pass), reset track timer
        if not same_item and percent == 0.0:
            track_start_time = None

        if track_start_time is None and percent > 0:
            track_start_time = time.time()

        elapsed_total   = time.time() - global_start_time
        overall_percent = ((current_index - 1 + percent / 100.0) / max(1, current_total)) * 100
        display_title   = f"{current_index:02d} - {current_title}"

        if percent < 100:
            current_stage = "Downloading"
        else:
            current_stage = "Downloaded"

        track_line = build_track_line(display_title, current_stage, percent, eta, dl_bytes, tot_bytes, tw)
        total_line = build_total_line(current_index, current_total, overall_percent, last_speed, elapsed_total, tw)

        if percent < 100:
            final_drawn  = False
            sealed_index = None
            if not live_block_active:
                sys.stdout.write("\r\033[K" + separator + "\n")
                sys.stdout.write("\r\033[K" + track_line + "\n")
                sys.stdout.write("\r\033[K" + separator + "\n")
                sys.stdout.write("\033[K\n\033[K\n")
                sys.stdout.write("\r\033[K" + separator + "\n")
                sys.stdout.write("\r\033[K" + total_line + "\n")
                sys.stdout.write("\r\033[K" + separator + "\r")
                live_block_active = True
            else:
                sys.stdout.write("\033[6A")
                sys.stdout.write("\r\033[K" + track_line + "\r")
                sys.stdout.write("\033[6B")

        else:
            # Track/pass finished — keep live block open for video+audio multi-pass
            # Only collapse if this is genuinely the final pass for this item
            # We detect multi-pass by checking if a [Merger] line will follow,
            # but since we can't predict that, we just update in place and let
            # the merger handler or next-index transition collapse it.
            if live_block_active:
                sys.stdout.write("\033[6A")
                sys.stdout.write("\r\033[K" + track_line + "\r")
                sys.stdout.write("\033[6B")
                # Don't collapse — merger or EOF will handle it

            sealed_index     = current_index
            track_start_time = None

            if current_index < current_total:
                elapsed_total = time.time() - global_start_time
                sys.stdout.write("\r\033[K" + separator + "\n")
                sys.stdout.write("\r\033[K" + total_line + "\n")
                sys.stdout.write("\r\033[K" + separator + "\r")
            elif current_index == current_total and not final_drawn:
                # For music (no merger follows), draw final frame immediately.
                # For video, merger will fire next and handle it.
                # We defer to EOF/merger — do nothing here, let those handle it.
                pass

        sys.stdout.flush()

    # ---- Final frame ----
    if sealed_index == current_total and not final_drawn:
        final_drawn   = True
        elapsed_total = time.time() - global_start_time

        # Collapse live block if still active (music case — no merger fired)
        if live_block_active:
            sys.stdout.write("\033[6A")
            # Redraw track line as Downloaded
            final_track = build_track_line(
                f"{current_index:02d} - {current_title}",
                "Downloaded", 100, "", 0, 0, tw
            )
            sys.stdout.write("\r\033[K" + final_track + "\r")
            sys.stdout.write("\033[3B")
            sys.stdout.write("\033[J")
            live_block_active = False

        f_total_line = build_total_line(
            current_total, current_total, 100,
            "—", elapsed_total, tw, final=True
        )

        sys.stdout.write("\r\033[K" + separator + "\n")
        sys.stdout.write("\r\033[K" + f_total_line + "\n")
        sys.stdout.write("\r\033[K" + separator + "\n")
        sys.stdout.write("\n✅ Success: Library Updated.\n\n")
        sys.stdout.flush()

except (KeyboardInterrupt, EOFError):
    sys.stdout.write("\n" * 4)
    sys.stdout.write("\r\033[K🛑 Download interrupted.\n")
finally:
    sys.stdout.write("\033[?25h")
    sys.stdout.flush()
    os._exit(130 if percent < 100 else 0)
