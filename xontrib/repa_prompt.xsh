"""Custom prompt based on my old powerlevel9k zsh prompt.
Heavily inspired by: https://github.com/santagada/xontrib-powerline/
"""

from collections import namedtuple

__all__ = ()

Section = namedtuple('Section', ['content', 'fg', 'bg'])

SEPARATORS = {
    'powerline': '❯',
}

THEMES = {
    'repa': {
        'C1': '#FFF',
        'B1': '#333',
        'C2': '#FFF',
        'B2': '#555',
    }
}

SECTIONS = {}


DEFAULTS = {
    'RP_SEPARATORS': SEPARATORS['powerline'],
    'RP_THEME': THEMES['repa'],
    'RP_PROMPT': 'who>cwd>alma>beka',
    'RP_PROMPT2': '❯❯❯',
    'RP_RPROMPT': '<eger',
}


def alias(f):
    aliases[f.__name__] = f
    return f


def register_section(f):
    SECTIONS[f.__name__] = f
    return f


def eval_section(section, theme):
    bg = theme[section.bg() if callable(section.bg) else section.bg]
    fg = theme[section.fg() if callable(section.fg) else section.fg]
    content = section.content() if callable(section.content) else section.content
    return Section(content, fg, bg)


@register_section
def who():
    return Section(" {user}@{hostname} ", "C1", "B1")


@register_section
def cwd():
    return Section(" {cwd} ", "C2", "B2")


def str2section(txt):
    return Section(f" {txt} ", "C1", "B1")


def rp_prompt_builder(promptstring, right=False):
    separators = __xonsh__.env["RP_SEPARATORS"]
    theme = __xonsh__.env["RP_THEME"]
    sep = ">" if not right else "<"
    parts = [SECTIONS[part]() if part in SECTIONS else str2section(part) for part in promptstring.split(sep)]

    def prompt():
        sections = [eval_section(part, theme) for part in parts]

        p = []
        size = len(sections)
        sep1 = separators[0]
        sep2 = separators[2]
        for i, sec in enumerate(sections):
            last = (i == size - 1)
            first = (i == 0)

            if first:
                p.append('{BACKGROUND_%s}' % sec.bg)

            p.append('{%s}%s' % (sec.fg, sec.content))

            if last:
                p.append('{NO_COLOR}{%s}%s{NO_COLOR} ' % (sec.bg, sep1))
            else:
                bg1 = sec.bg
                bg2 = sections[i + 1].bg
                if bg1 == bg2:
                    p.append('%s' % sep2)
                else:
                    p.append('{BACKGROUND_%s}{%s}%s' % (bg2, bg1, sep1))

        return ''.join(p)

    return prompt


@alias
def rp_set_separators(args):
    separators = ""
    if len(args) < 1:
        separators = SEPARATORS['powerline']
    elif (args[0] not in SEPARATORS and args[0] != 'custom'):
        print('you need to select separators from the following ones:')
        for s in SEPARATORS:
            print(f'  - {s}')
        print('  - custom [custom separators]')
        return

    if args[0] == 'custom':
        if len(args) < 2:
            print('please provide custom separators')
            return
        else:
            separators = args[1][:5]
            if len(separators) < 5:
                separators = separators + SEPARATORS['powerline'][len(separators):]
    else:
        separators = SEPARATORS[args[0]]

    __xonsh__.env['RP_SEPARATORS'] = separators


@alias
def rp_set_theme(args):
    theme = ""
    if len(args) < 1:
        theme = THEMES['repa']
    elif (args[0] not in THEMES):
        print('you need to select theme from the following ones:')
        for t in THEMES:
            print(f'  - {t}')
        return

    theme = THEMES[args[0]]

    __xonsh__.env['RP_THEME'] = theme


@alias
def rp_build_prompt():

    # __xonsh__.enx["PROMPT"] = "{env_name}{BOLD_GREEN}{user}@{hostname}{BOLD_BLUE} {cwd} {branch_name}{NO_COLOR}\n> "
    __xonsh__.env["PROMPT"] = rp_prompt_builder(__xonsh__.env["RP_PROMPT"])
    __xonsh__.env["RIGHT_PROMPT"] = "< eger"


def rp_init():
    for setting in DEFAULTS:
        if setting not in __xonsh__.env:
            __xonsh__.env[setting] = DEFAULTS[setting]

    rp_build_prompt()


rp_init()
