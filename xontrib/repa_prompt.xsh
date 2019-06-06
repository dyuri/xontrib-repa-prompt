"""Custom prompt based on my old powerlevel9k zsh prompt.
"""

from collections import namedtuple

__all__ = ()

Section = namedtuple('Section', ['content', 'fg', 'bg'])

SEPARATORS = {
    'powerline': '❯',
}

SECTIONS = []


def alias(f):
    aliases[f.__name__] = f
    return f


def register_section(f):
    SECTIONS[f.__name__] = f
    return f


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


def rp_init():
    if 'RP_SEPARATORS' not in __xonsh__.env:
        rp_set_separators(['powerline'])

    $PROMPT="{env_name}{BOLD_GREEN}{user}@{hostname}{BOLD_BLUE} {cwd} {gitstatus}{NO_COLOR} {BOLD_BLUE}{prompt_end}{NO_COLOR}\n> "
    $RIGHT_PROMPT="< eger"


rp_init()
