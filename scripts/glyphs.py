#!/usr/bin/env python3
"""Browse Nerd Font glyphs available in JetBrainsMono Nerd Font."""

import sys

COLS = 3

categories = {
    "OS / Logos": [
        (0xF179, "apple"),
        (0xF17C, "linux tux"),
        (0xF17A, "windows"),
        (0xF17B, "android"),
        (0xF303, "arch linux"),
        (0xF313, "debian"),
        (0xF306, "fedora"),
        (0xF316, "mint"),
        (0xF31A, "manjaro"),
        (0xF31C, "ubuntu"),
        (0xF326, "raspberry pi"),
        (0xF300, "coreos"),
    ],
    "UI / Menu": [
        (0xF0C9, "hamburger menu"),
        (0xF141, "ellipsis horizontal"),
        (0xF142, "ellipsis vertical"),
        (0xF013, "cog / settings"),
        (0xF085, "cogs"),
        (0xF0AD, "wrench"),
        (0xF0D0, "magic wand"),
        (0xF11B, "gamepad"),
        (0xF015, "home"),
        (0xF002, "search"),
        (0xF00D, "close / x"),
        (0xF067, "plus"),
        (0xF068, "minus"),
        (0xF05E, "ban / block"),
        (0xF023, "lock"),
        (0xF09C, "unlock"),
        (0xF084, "key"),
        (0xF132, "shield"),
        (0xF0F3, "bell"),
        (0xF1F6, "bell slash"),
        (0xF12E, "puzzle piece"),
        (0xF0E9, "umbrella"),
    ],
    "Shapes & Symbols": [
        (0xF111, "circle filled"),
        (0xF10C, "circle empty"),
        (0xF058, "circle check"),
        (0xF057, "circle x"),
        (0xF059, "circle question"),
        (0xF05A, "circle info"),
        (0xF0C8, "square filled"),
        (0xF096, "square empty"),
        (0xF046, "square check"),
        (0xF005, "star filled"),
        (0xF006, "star empty"),
        (0xF089, "star half"),
        (0xF004, "heart"),
        (0xF08A, "heart empty"),
        (0xF0EB, "lightbulb"),
        (0xF06D, "fire"),
        (0xF06C, "leaf"),
        (0xF185, "sun"),
        (0xF186, "moon"),
        (0xF0E7, "lightning bolt"),
        (0xF024, "flag"),
        (0xF11D, "flag checkered"),
    ],
    "Arrows & Navigation": [
        (0xF060, "arrow left"),
        (0xF061, "arrow right"),
        (0xF062, "arrow up"),
        (0xF063, "arrow down"),
        (0xF104, "angle left"),
        (0xF105, "angle right"),
        (0xF106, "angle up"),
        (0xF107, "angle down"),
        (0xF100, "double angle left"),
        (0xF101, "double angle right"),
        (0xF102, "double angle up"),
        (0xF103, "double angle down"),
        (0xF053, "chevron left"),
        (0xF054, "chevron right"),
        (0xF077, "chevron up"),
        (0xF078, "chevron down"),
        (0xF01E, "refresh / rotate"),
        (0xF021, "sync arrows"),
        (0xF074, "random shuffle"),
        (0xF047, "move arrows"),
        (0xF0B2, "expand arrows"),
        (0xF112, "reply"),
    ],
    "Files & Folders": [
        (0xF016, "file"),
        (0xF15B, "file empty"),
        (0xF15C, "file text"),
        (0xF1C9, "file code"),
        (0xF07B, "folder"),
        (0xF07C, "folder open"),
        (0xF114, "folder empty"),
        (0xF0C7, "save / floppy"),
        (0xF019, "download"),
        (0xF093, "upload"),
        (0xF187, "archive / box"),
        (0xF0EA, "clipboard"),
        (0xF0C5, "copy"),
        (0xF0C4, "scissors"),
        (0xF02F, "print"),
        (0xF1C0, "database"),
    ],
    "Development": [
        (0xF120, "terminal prompt"),
        (0xF121, "code"),
        (0xF126, "git branch"),
        (0xF09B, "github"),
        (0xF092, "github square"),
        (0xF113, "github alt"),
        (0xF170, "bitbucket"),
        (0xF1D3, "git"),
        (0xF188, "bug"),
        (0xF0AE, "tasks / checklist"),
        (0xF022, "list"),
        (0xF0CB, "list ordered"),
        (0xF11C, "keyboard"),
        (0xF13B, "html5"),
        (0xF13C, "css3"),
        (0xF1C3, "file excel"),
        (0xF1C4, "file word"),
    ],
    "System / Hardware": [
        (0xF108, "desktop / monitor"),
        (0xF109, "laptop"),
        (0xF10A, "tablet"),
        (0xF10B, "mobile / phone"),
        (0xF011, "power"),
        (0xF012, "signal"),
        (0xF1EB, "wifi"),
        (0xF0AC, "globe"),
        (0xF0C2, "cloud"),
        (0xF025, "headphones"),
        (0xF028, "volume up"),
        (0xF027, "volume down"),
        (0xF026, "volume off"),
        (0xF130, "microphone"),
        (0xF131, "microphone slash"),
        (0xF030, "camera"),
        (0xF03D, "video camera"),
        (0xF072, "plane"),
        (0xF095, "phone"),
        (0xF17F, "battery full"),
        (0xF0D1, "truck"),
    ],
    "Media / Entertainment": [
        (0xF04B, "play"),
        (0xF04C, "pause"),
        (0xF04D, "stop"),
        (0xF04E, "forward"),
        (0xF04A, "backward"),
        (0xF050, "fast forward"),
        (0xF049, "fast backward"),
        (0xF051, "step forward"),
        (0xF048, "step backward"),
        (0xF052, "eject"),
        (0xF001, "music note"),
        (0xF008, "film / movie"),
        (0xF03E, "image / picture"),
        (0xF144, "play circle"),
        (0xF01D, "play circle empty"),
        (0xF167, "youtube"),
        (0xF16D, "instagram"),
        (0xF099, "twitter"),
        (0xF09A, "facebook"),
    ],
    "People & Communication": [
        (0xF007, "user"),
        (0xF0C0, "group / users"),
        (0xF003, "envelope / email"),
        (0xF0E0, "envelope open"),
        (0xF075, "comment / chat"),
        (0xF086, "comments"),
        (0xF0F0, "stethoscope"),
        (0xF091, "trophy"),
        (0xF06B, "gift"),
        (0xF118, "smile"),
        (0xF119, "frown"),
        (0xF183, "person walking"),
        (0xF164, "thumbs up"),
        (0xF165, "thumbs down"),
        (0xF0FC, "beer"),
        (0xF0F4, "coffee"),
        (0xF094, "lemon"),
    ],
    "Misc": [
        (0xF041, "map marker / pin"),
        (0xF14E, "compass"),
        (0xF073, "calendar"),
        (0xF017, "clock"),
        (0xF0C1, "link / chain"),
        (0xF08E, "external link"),
        (0xF13D, "anchor"),
        (0xF076, "magnet"),
        (0xF06E, "eye"),
        (0xF070, "eye slash"),
        (0xF0B0, "filter"),
        (0xF080, "bar chart"),
        (0xF0B1, "briefcase"),
        (0xF02D, "book"),
        (0xF02E, "bookmark"),
        (0xF19C, "institution / bank"),
        (0xF0F6, "file medical"),
        (0xF136, "medkit"),
        (0xF1B9, "car"),
        (0xF1BA, "taxi"),
        (0xF0E8, "sitemap"),
        (0xF042, "adjust / contrast"),
    ],
}


def print_category(name, glyphs):
    print(f"\n  ── {name} ──")
    rows = [glyphs[i:i+COLS] for i in range(0, len(glyphs), COLS)]
    for row in rows:
        line = "  "
        for code, label in row:
            cell = f"{chr(code)}  U+{code:04X}  {label:<22}"
            line += cell
        print(line)


def print_range(start_hex, end_hex):
    start = int(start_hex, 16)
    end = int(end_hex, 16)
    glyphs = [(code, f"U+{code:05X}") for code in range(start, end + 1)]
    print(f"\n  Range U+{start:04X} – U+{end:04X}  ({len(glyphs)} glyphs)\n")
    rows = [glyphs[i:i+COLS] for i in range(0, len(glyphs), COLS)]
    for row in rows:
        line = "  "
        for code, label in row:
            try:
                cell = f"{chr(code)}  {label:<12}"
            except (ValueError, OverflowError):
                cell = f"?  {label:<12}"
            line += cell
        print(line)
    print()


def main():
    args = sys.argv[1:]

    if len(args) == 3 and args[0] == "--range":
        print_range(args[1], args[2])
        return

    if len(args) == 1 and args[0] == "--ranges":
        print("\n  Known Nerd Font ranges:\n")
        ranges = [
            ("E000", "E00A", "Pomicons"),
            ("E0A0", "E0D4", "Powerline Extra"),
            ("E200", "E2A9", "Weather Icons"),
            ("E300", "E3EB", "Weather Icons (extended)"),
            ("E700", "E7C5", "Devicons"),
            ("EA60", "EBEB", "Codicons (VS Code)"),
            ("EE00", "EE0B", "Nerd Fonts logos"),
            ("F000", "F2E0", "Font Awesome"),
            ("F300", "F32F", "Font Logos (OS)"),
            ("F400", "F532", "Octicons"),
            ("F500", "FD46", "Font Awesome v5"),
        ]
        for start, end, name in ranges:
            count = int(end, 16) - int(start, 16) + 1
            print(f"  glyphs --range {start} {end}   {name}  ({count})")
        print()
        return

    query = args[0].lower() if args else None

    if query:
        print(f"\n  Search: '{query}'\n")
        results = []
        for glyphs in categories.values():
            for code, name in glyphs:
                if query in name.lower():
                    results.append((code, name))
        if results:
            print_category("Results", results)
        else:
            print("  No matches found.")
    else:
        print("\n  Nerd Font Glyph Browser  —  JetBrainsMono Nerd Font")
        print("  Usage:")
        print("    glyphs                       show curated list")
        print("    glyphs <term>                search by name")
        print("    glyphs --range EA60 EBEB     scan a unicode range")
        print("    glyphs --ranges              list all known ranges")
        for name, glyphs in categories.items():
            print_category(name, glyphs)

    print()


if __name__ == "__main__":
    main()
