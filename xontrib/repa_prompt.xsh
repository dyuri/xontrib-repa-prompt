"""Custom prompt based on my old powerlevel9k zsh prompt.
Heavily inspired by: https://github.com/santagada/xontrib-powerline/
"""

from collections import namedtuple
import colorsys
from time import strftime
from xonsh.platform import ptk_shell_type
from xonsh import prompt

__all__ = ()

Section = namedtuple("Section", ["content", "fg", "bg"])

SEPARATORS = {
    "powerline": "",
    "round": "",
    "down": "",
    "up": "",
    "flame": "",
    "squares": "",
}

THEMES = {
    # material colors
    "repa": {
        "default_fg": "#00BCD4",
        "default_bg": "#666",
        "who_fg": "BOLD_#333",
        "who_bg": "#CDDC39",
        "cwd_fg": "#CDDC39",
        "cwd_bg": "#555",
        "branch_fg_unknown": "#FF9800",
        "branch_fg_dirty": "#E91E63",
        "branch_fg_clean": "#8BC34A",
        "branch_bg_unknown": "#333",
        "branch_bg_dirty": "#333",
        "branch_bg_clean": "#333",
        "timing_fg": "#666",
        "timing_bg": "#222",
        "rtn_fg_ok": "#8BC34A",
        "rtn_fg_error": "#C62828",
        "rtn_bg_ok": "#444",
        "rtn_bg_error": "#FFF",
        "time_fg": "#FFC107",
        "time_bg": "#666",
        "virtualenv_fg": "#00BCD4",
        "virtualenv_bg": "#444",
    }
}

SECTIONS = {}


if ptk_shell_type() == "prompt_toolkit2":
    __xonsh__.env["PTK_STYLE_OVERRIDES"]["bottom-toolbar"] = "noreverse"


def alias(f):
    aliases[f.__name__] = f
    return f


def register_section(f):
    SECTIONS[f.__name__] = f
    return f


def eval_section(section_str, theme):
    section = (
        SECTIONS[section_str]() if section_str in SECTIONS else str2section(section_str)
    )
    if section:
        content, fg, bg = section
        bg = theme[bg] if bg in theme else bg
        fg = theme[fg] if fg in theme else fg
        if content:
            return Section(content, fg, bg)


@register_section
def who():
    return Section(" {user}@{hostname} ", "who_fg", "who_bg")


@register_section
def ssh_who():
    if 'SSH_CLIENT' in __xonsh__.env:
        return who()

# TODO icon
@register_section
def cwd():
    return Section(" {cwd} ", "cwd_fg", "cwd_bg")


@register_section
def timing():
    if __xonsh__.history and __xonsh__.history.tss:
        tss = __xonsh__.history.tss[-1]
        return Section(f" {(tss[1] - tss[0]):.2f}s ", "timing_fg", "timing_bg")


@register_section
def time():
    return Section(strftime(" %H:%M  "), "time_fg", "time_bg")


# TODO icons
@register_section
def branch():
    branch = prompt.vc.current_branch()
    if branch:
        dwd = prompt.vc.dirty_working_directory()
        if dwd is None:
            # timeout
            color = "unknown"
        elif dwd:
            # dirty
            color = "dirty"
        else:
            # clean
            color = "clean"

        return Section(f"  {branch} ", f"branch_fg_{color}", f"branch_bg_{color}")


@register_section
def virtualenv():
    if __xonsh__.env["PROMPT_FIELDS"]["env_name"]():
        return Section("  {env_name} ", "virtualenv_fg", "virtualenv_bg")


@register_section
def rtn():
    if __xonsh__.history and __xonsh__.history.rtns:
        rtn = __xonsh__.history.rtns[-1]
        if rtn:
            color = "error"
            mark = ""
        else:
            color = "ok"
            mark = ""

        return Section(f" {mark} ", f"rtn_fg_{color}", f"rtn_bg_{color}")


def triple_right():
    return Section("{#C62828}❯{#FFC107}❯{#8BC34A}❯", "default_fg", "BLACK")
SECTIONS["❯❯❯"] = triple_right


def rp_mlprompt(ch="❯", length=5):
    step = 1 / length
    mlprompt = []
    for i in range(length):
        h = i * step
        s = 1
        v = 1
        rgb = colorsys.hsv_to_rgb(h, s, v)
        mlprompt.append("{#%02x%02x%02x}" % (int(rgb[0] * 255), int(rgb[1] * 255), int(rgb[2] * 255)))

    return ch.join(mlprompt)

# TODO color support
def str2section(txt):
    fg = "default_fg"
    bg = "default_bg"
    if "||" in txt:
        txt, color = txt.split("||", 1)
        if "|" in color:
            fg, bg = color.split("|", 1)
        else:
            fg = color

    return Section(f" {txt} ", fg, bg)


def rp_prompt_builder(promptstring, right=False):
    separators = __xonsh__.env["RP_SEPARATORS"]
    theme = __xonsh__.env["RP_THEME"]
    sep = ">" if not right else "<"
    sep1 = separators[0] if not right else separators[1]
    sep2 = separators[2] if not right else separators[3]

    def prompt():
        # evaluate section functions
        sections = []
        for part in promptstring.split(sep):
            section = eval_section(part, theme)
            if section:
                sections.append(section)

        p = []
        size = len(sections)
        for i, sec in enumerate(sections):
            last = i == size - 1
            first = i == 0

            if right:
                if not first and sections[i - 1].bg == sec.bg:
                    p.append("{%s}%s%s" % (sec.fg, sep2, sec.content))
                else:
                    p.append(
                        "{%s}%s{BACKGROUND_%s}{%s}%s"
                        % (sec.bg, sep1, sec.bg, sec.fg, sec.content)
                    )
            else:
                if first:
                    p.append("{BACKGROUND_%s}" % sec.bg)

                p.append("{%s}%s" % (sec.fg, sec.content))

                if last:
                    p.append("{NO_COLOR}{%s}%s{NO_COLOR} " % (sec.bg, sep1))
                else:
                    bg1 = sec.bg
                    bg2 = sections[i + 1].bg
                    if bg1 == bg2:
                        p.append("%s" % sep2)
                    else:
                        p.append("{BACKGROUND_%s}{%s}%s" % (bg2, bg1, sep1))

        return "".join(p)

    return prompt


@alias
def rp_set_separators(args):
    separators = ""
    if len(args) < 1:
        separators = SEPARATORS["powerline"]
    elif args[0] not in SEPARATORS and args[0] != "custom":
        print("you need to select separators from the following ones:")
        for s in SEPARATORS:
            print(f"  - {s}")
        print("  - custom [custom separators]")
        return

    if args[0] == "custom":
        if len(args) < 2:
            print("please provide custom separators")
            return
        else:
            separators = args[1][:4]
            if len(separators) < 4:
                separators = separators + SEPARATORS["powerline"][len(separators) :]
    else:
        separators = SEPARATORS[args[0]]

    __xonsh__.env["RP_SEPARATORS"] = separators


@alias
def rp_set_theme(args):
    theme = ""
    if len(args) < 1:
        theme = THEMES["repa"]
    elif args[0] not in THEMES:
        print("you need to select theme from the following ones:")
        for t in THEMES:
            print(f"  - {t}")
        return

    theme = THEMES[args[0]]

    __xonsh__.env["RP_THEME"] = theme


@alias
def rp_sections():
    print("Available sections:")
    for section in SECTIONS:
        print(f"  {section}")


@alias
def rp_build_prompt():
    prompt1_str = __xonsh__.env["RP_PROMPT"] or ""
    prompt2_str = __xonsh__.env["RP_PROMPT2"] or ""
    prompt1 = ""
    prompt2 = ""
    if prompt1_str:
        prompt1 = rp_prompt_builder(prompt1_str)
    if prompt2_str:
        prompt2 = rp_prompt_builder(prompt2_str)

    if prompt1:
        __xonsh__.env["PROMPT"] = (
            prompt1 if not prompt2 else lambda: prompt1() + "\n" + prompt2()
        )

    rprompt_str = __xonsh__.env["RP_RPROMPT"]
    if rprompt_str:
        __xonsh__.env["RIGHT_PROMPT"] = rp_prompt_builder(rprompt_str, True)

    toolbar = __xonsh__.env["RP_TOOLBAR"]
    if toolbar:
        __xonsh__.env["TOOLBAR"] = rp_prompt_builder(toolbar)

    ml_prompt = __xonsh__.env["RP_MULTILINE_PROMPT"]
    if ml_prompt:
        __xonsh__.env["MULTILINE_PROMPT"] = ml_prompt

    title = __xonsh__.env["RP_TITLE"]
    if title:
        __xonsh__.env["TITLE"] = title


DEFAULTS = {
    "RP_SEPARATORS": SEPARATORS["powerline"],
    "RP_THEME": THEMES["repa"],
    "RP_PROMPT": "||#000|#CDDC39>ssh_who>cwd>virtualenv>branch",
    "RP_PROMPT2": "❯❯❯",
    "RP_RPROMPT": "timing<rtn<time",
    "RP_MULTILINE_PROMPT": rp_mlprompt("❯", 5),
    "RP_TITLE": "{current_job:{} | }{cwd} | {user}@{hostname}",
    "RP_TOOLBAR": None,
}


def rp_init():
    for setting in DEFAULTS:
        if setting not in __xonsh__.env:
            __xonsh__.env[setting] = DEFAULTS[setting]

    rp_build_prompt()


rp_init()
