#!/usr/bin/env python3
import sys, os, shutil, time, unicodedata, re, select

# ---------- Fast I/O ----------
try:
    sys.stdout.reconfigure(line_buffering=True)
    sys.stdin.reconfigure(encoding="utf-8", errors="ignore")
except Exception:
    pass

# ---------- Colors ----------
sys.path.append(os.path.dirname(os.path.realpath(__file__)))
try:
    from colors import PRIMARY, SECONDARY, SURFACE
except ImportError:
    PRIMARY, SECONDARY, SURFACE = "#88c0d0", "#a3be8c", "#4c566a"


def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


PRIMARY_RGB = hex_to_rgb(PRIMARY)
SECONDARY_RGB = hex_to_rgb(SECONDARY)
SURFACE_RGB = hex_to_rgb(SURFACE)
GREEN_RGB = (120, 200, 120)

RESET = "\033[0m"
FILLED = "▓"
EMPTY = "░"


def rgb(r, g, b):
    return f"\033[38;2;{r};{g};{b}m"


def visual_len(text):
    plain = re.sub(r"\033\[[0-9;]*m", "", text)
    return sum(2 if unicodedata.east_asian_width(c) in "WF" else 1 for c in plain)


def human_mib(n):
    try:
        n = float(n) / (1024 * 1024)
        return f"{n:.1f}MiB"
    except:
        return "  0.00MiB"


def format_time(seconds):
    if seconds < 1:
        return f"{int(seconds * 1000)}ms"

    m, s = divmod(seconds, 60)
    h, m = divmod(m, 60)

    if h > 0:
        return f"{int(h):02d}:{int(m):02d}:{int(s):02d}"
    else:
        return f"{int(m):02d}:{int(s):02d}"


def render_bar(percent, width, start_rgb, end_rgb):
    percent = max(0, min(percent, 100))
    filled = int(width * percent / 100)
    diff = [end_rgb[i] - start_rgb[i] for i in range(3)]
    out = []

    for i in range(width):
        if i < filled:
            r = int(start_rgb[0] + diff[0] * (i / width))
            g = int(start_rgb[1] + diff[1] * (i / width))
            b = int(color_b := start_rgb[2] + diff[2] * (i / width))
            out.append(rgb(r, g, b) + FILLED + RESET)
        else:
            out.append(rgb(*SURFACE_RGB) + EMPTY + RESET)
    return "".join(out)


def clean_title(title: str) -> str:
    # Remove [brackets]
    title = re.sub(r"\[[^\]]*\]", "", title)
    # Remove (parentheses)
    title = re.sub(r"\([^)]*\)", "", title)
    # Remove common junk words
    title = re.sub(
        r"\b(Official|Lyric|Lyrics|Video|Music|4K|1080p|HD|HQ|Audio|Visualizer)\b",
        "",
        title,
        flags=re.IGNORECASE,
    )
    # Collapse multiple spaces
    title = re.sub(r"\s+", " ", title)
    return title.strip()


def fit_title(text, width):
    if visual_len(text) <= width:
        return text.ljust(width)
    # truncate and add ...
    trimmed = text
    while visual_len(trimmed) > width - 3:
        trimmed = trimmed[:-1]
    return trimmed + "..."


# ---------- State ----------
current_index = None
sealed_index = None
current_total = 1
current_title = "Initializing"
current_stage = "Downloading"
track_start_time = None
last_speed = "0B/s"
live_block_active = False
global_start_time = time.time()

# Hide cursor
sys.stdout.write("\033[?25l")
sys.stdout.flush()

track_width = shutil.get_terminal_size().columns - 2
separator = "-" * (track_width + 2)

spinner_frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
spin_idx = 0
spin_tail = 8
fetching = True

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

        tw = shutil.get_terminal_size().columns
        TITLE_WIDTH = int(tw * 0.35)
        STAGE_WIDTH = 13  # "[Downloading]" fits
        SIZE_WIDTH = 18  # " 12.34MiB /  45.67MiB"
        TIME_WIDTH = 12  # "Time 00:00"

        # Check if song already in library
        if "has already been downloaded" in raw:
            # Extract filename from line
            full_path = raw.split("has already been downloaded")[0]
            # Remove yt-dlp prefix
            full_path = full_path.replace("[download]", "").strip()
            # Get only filename
            filename = os.path.basename(full_path)
            # Remove extension
            filename = os.path.splitext(filename)[0]
            # Clean
            current_title = clean_title(filename)

            current_stage = "In library"

            # Build formatted line using same layout logic
            title_col = fit_title(f"[{current_title}]", TITLE_WIDTH)
            stage_col = (" " + f"[{current_stage}]").ljust(STAGE_WIDTH)

            skipped_line = f"{title_col} | {stage_col} |"

            # Freeze as a normal sandwich item
            if live_block_active:
                # We are inside floating block → collapse it first
                sys.stdout.write("\033[5A")  # Go to track line
                sys.stdout.write("\033[J")  # Clear floating area
                live_block_active = False

            sys.stdout.write("\r\033[K" + separator + "\n")
            sys.stdout.write("\r\033[K" + skipped_line + "\n")
            sys.stdout.write("\r\033[K" + separator)

            live_block_active = False
            sealed_index = current_index
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
            new_idx = int(idx_str) if idx_str.isdigit() else (current_index or 1)

            # --- Correct Track Change Transition ---
            if current_index is not None and new_idx > current_index:
                # We are at the bottom of a 3-line block.
                live_block_active = False

            current_index = new_idx
            display_index = f"{current_index:02d}"
            display_title = f"{display_index} - {current_title}"

            if tot_str.isdigit():
                current_total = int(tot_str)
            if title and title not in ("NA", "None"):
                current_title = clean_title(title.strip())
            if speed and speed not in ("NA", ""):
                last_speed = speed.strip()
            percent = float(p_str.replace("%", "").strip())
        except:
            continue

        # Timer start
        if track_start_time is None and percent > 0:
            track_start_time = time.time()

        # ETA / Time formatting
        if percent < 100:
            time_field = f"ETA {eta}" if eta not in ("NA", "00:00", "") else ""
        else:
            duration = time.time() - track_start_time if track_start_time else 0
            time_field = f"Time {format_time(duration)}"
            current_stage = "Downloaded"

        overall_percent = (
            (current_index - 1 + percent / 100.0) / max(1, current_total)
        ) * 100

        size = f"{human_mib(dl_bytes)} / {human_mib(tot_bytes)}"

        # Build UI components
        title_col = fit_title(f"[{display_title}]", TITLE_WIDTH)
        stage_col = (" " + f"[{current_stage}]").ljust(STAGE_WIDTH)
        size_col = (" " + size).ljust(SIZE_WIDTH)
        time_col = time_field.ljust(TIME_WIDTH)

        static_width = (
            visual_len(title_col)
            + visual_len(stage_col)
            + visual_len(size_col)
            + visual_len(time_col)
            + 12
        )

        bar_w = max(10, tw - static_width)
        track_bar = render_bar(percent, bar_w, SECONDARY_RGB, GREEN_RGB)
        track_line = (
            f"{title_col} | {stage_col} | {track_bar} | {size_col} | {time_col}"
        )

        # ---------- TOTAL CALCULATIONS ----------

        # Total elapsed
        elapsed_total = time.time() - global_start_time
        elapsed_str = format_time(elapsed_total)

        # Total ETA (only if progress > 0)
        if overall_percent > 0:
            total_estimated = elapsed_total / (overall_percent / 100)
            total_eta = max(0, total_estimated - elapsed_total)
            total_eta_str = format_time(total_eta)
        else:
            total_eta_str = ""

        # Build total bar width dynamically
        index_block = f"[Total: {current_index}/{current_total}]"
        speed_block = f"[{last_speed}]"
        elapsed_block = f"[{elapsed_str}]"
        eta_block = f"[ETA {total_eta_str}]" if total_eta_str else ""

        static_total_width = (
            visual_len(index_block)
            + visual_len(speed_block)
            + visual_len(elapsed_block)
            + visual_len(eta_block)
            + 12
        )

        total_bar_width = max(20, tw - static_total_width)

        total_bar = render_bar(
            overall_percent, total_bar_width, PRIMARY_RGB, SECONDARY_RGB
        )

        total_line = (
            f"{index_block} | "
            f"{total_bar} | "
            f"{speed_block} | "
            f"{elapsed_block} | "
            f"{eta_block}"
        )

        # --- DRAWING BLOCK ---

        if percent < 100:
            sealed_index = None
            if not live_block_active:
                # 1. Initial Draw: 8 lines total
                sys.stdout.write("\r\033[K" + separator + "\n")  # Track top
                sys.stdout.write("\r\033[K" + track_line + "\n")  # Track
                sys.stdout.write("\r\033[K" + separator + "\n")  # Track bottom
                sys.stdout.write("\033[K\n")  # Gap
                sys.stdout.write("\033[K\n")  # Gap
                sys.stdout.write("\r\033[K" + separator + "\n")  # Total top
                sys.stdout.write("\r\033[K" + total_line + "\n")  # Total
                sys.stdout.write("\r\033[K" + separator + "\r")  # Total bottom
                live_block_active = True
            else:
                # 2. Update: Move up 6 rows to reach Row 2
                sys.stdout.write("\033[6A")
                sys.stdout.write("\r\033[K" + track_line + "\r")
                sys.stdout.write("\033[6B")
            sys.stdout.flush()
        else:
            # 3. Freeze: Commit Track to history
            is_last = current_index == current_total

            if current_index != sealed_index:
                final_line = track_line.replace("[Downloading]", "[Downloaded]")

                if live_block_active:
                    # Move to row 1
                    sys.stdout.write("\033[6A")
                    sys.stdout.write("\r\033[K" + final_line + "\r")
                    sys.stdout.write("\033[3B")
                    sys.stdout.write("\033[J")
                # Mark as sealed
                sealed_index = current_index
                live_block_active = False
                track_start_time = None
            else:
                # If already sealed, just update total bar on it's current line
                sys.stdout.write("\033[2B")
                sys.stdout.write("\r\033[K" + separator + "\n")
                sys.stdout.write("\r\033[K" + total_line + "\n")
                sys.stdout.write("\r\033[K" + separator)
                sys.stdout.write("\033[6A" + "\r")
        sys.stdout.flush()

    # ----- FINAL TOTAL FRAME -----
    if sealed_index == current_total:
        overall_percent = 100
        elapsed_total = time.time() - global_start_time
        elapsed_str = format_time(elapsed_total)

        index_block = f"[Total: {current_total}/{current_total}]"
        speed_block = "[—]"  # or keep last_speed if you prefer
        elapsed_block = f"[{elapsed_str}]"
        status_block = "[Done]"

        static_total_width = (
            visual_len(index_block)
            + visual_len(speed_block)
            + visual_len(elapsed_block)
            + visual_len(status_block)
            + 12
        )

        total_bar_width = max(20, tw - static_total_width)

        total_bar = render_bar(100, total_bar_width, PRIMARY_RGB, SECONDARY_RGB)

        total_line = (
            f"{index_block} | "
            f"{total_bar} | "
            f"{speed_block} | "
            f"{elapsed_block} | "
            f"{status_block}"
        )

        sys.stdout.write("\033[2B")
        sys.stdout.write("\r\033[K" + separator + "\n")
        sys.stdout.write("\r\033[K" + total_line + "\n")
        sys.stdout.write("\r\033[K" + separator + "\n")
        sys.stdout.write("\n✅ Success: Library Updated.\n\n")
        sys.stdout.flush()

except (KeyboardInterrupt, EOFError):
    # Ensure a clean break away from the active bars
    sys.stdout.write("\n" * 8)
    sys.stdout.write("\r\033[K🛑 Download interrupted.\n")
finally:
    sys.stdout.write("\033[?25h")
    sys.stdout.flush()
    os._exit(130 if "percent" in locals() and percent < 100 else 0)
