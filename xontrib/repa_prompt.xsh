"""Custom prompt based on my old powerlevel9k zsh prompt.
"""

from collections import namedtuple

__all__ = ()

Section = namedtuple('Section', ['content', 'fg', 'bg'])

SEPARATORS = {
    'powerline': '❯',
}

THEMES = {
    'repa': {
        'C1': 'WHITE',
        'B1': '#333',
        'C2': 'WHITE',
        'B2': '#555',
    }
}

SECTIONS = {}


def alias(f):
    aliases[f.__name__] = f
    return f


def register_section(f):
    SECTIONS[f.__name__] = f
    return f


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

    # TODO
    prompt_parts = ['{BACKGROUND_' + theme[part.bg] + '}{' + theme[part.fg] + '}' + part.content for part in parts]

    return '|'.join(prompt_parts)


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
            print(f'  - {s}')
        return

    theme = THEMES[args[0]]

    __xonsh__.env['RP_THEME'] = theme


@alias
def rp_build_prompt(args=None):

    # __xonsh__.enx["PROMPT"] = "{env_name}{BOLD_GREEN}{user}@{hostname}{BOLD_BLUE} {cwd} {branch_name}{NO_COLOR}\n> "
    __xonsh__.env["PROMPT"] = rp_prompt_builder("who>cwd>$")
    __xonsh__.env["RIGHT_PROMPT"] = "< eger"


def rp_init():
    if 'RP_SEPARATORS' not in __xonsh__.env:
        rp_set_separators(['powerline'])
    if 'RP_THEME' not in __xonsh__.env:
        rp_set_theme(['repa'])

    rp_build_prompt()


rp_init()
