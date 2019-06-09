"""Custom prompt based on my old powerlevel9k zsh prompt.
Heavily inspired by: https://github.com/santagada/xontrib-powerline/
"""

from collections import namedtuple
from xonsh.platform import ptk_shell_type

__all__ = ()

Section = namedtuple('Section', ['content', 'fg', 'bg'])

SEPARATORS = {
    'powerline': '',
}

THEMES = {
    'repa': {
        'C1': '#FFF',
        'B1': '#555',
        'C2': '#AFC',
        'B2': '#888',
    }
}

SECTIONS = {}


DEFAULTS = {
    'RP_SEPARATORS': SEPARATORS['powerline'],
    'RP_THEME': THEMES['repa'],
    'RP_PROMPT': 'who>cwd>alma>{user}',
    'RP_PROMPT2': '❯❯❯',
    'RP_RPROMPT': 'alma<eger<cwd',
    'RP_MULTILINE_PROMPT': '❯',
    'RP_TITLE': '{current_job:{} | }{cwd} | {user}@{hostname}',
    'RP_TOOLBAR': None,
}

if ptk_shell_type() == 'prompt_toolkit2':
    __xonsh__.env['PTK_STYLE_OVERRIDES']['bottom-toolbar'] = 'noreverse'


def alias(f):
    aliases[f.__name__] = f
    return f


def register_section(f):
    SECTIONS[f.__name__] = f
    return f


def eval_section(section, theme):
    if section:
        bg = theme[section.bg() if callable(section.bg) else section.bg]
        fg = theme[section.fg() if callable(section.fg) else section.fg]
        content = section.content() if callable(section.content) else section.content
        if content:
            return Section(content, fg, bg)


@register_section
def who():
    return Section(" {user}@{hostname} ", "C1", "B1")


@register_section
def cwd():
    return Section(" {cwd} ", "C2", "B2")


# TODO remove
import random
@register_section
def alma():
    def cica():
        if random.random() > .5:
            return None
        return ' cica '
    return Section(cica, 'C2', 'B1')


def str2section(txt):
    return Section(f" {txt} ", "C1", "B1")


def rp_prompt_builder(promptstring, right=False):
    separators = __xonsh__.env["RP_SEPARATORS"]
    theme = __xonsh__.env["RP_THEME"]
    sep = ">" if not right else "<"
    sep1 = separators[0] if not right else separators[1]
    sep2 = separators[2] if not right else separators[3]
    parts = [SECTIONS[part]() if part in SECTIONS else str2section(part) for part in promptstring.split(sep)]

    def prompt():
        # evaluate section functions
        sections = []
        for part in parts:
            section = eval_section(part, theme)
            if section:
                sections.append(section)

        p = []
        size = len(sections)
        for i, sec in enumerate(sections):
            last = (i == size - 1)
            first = (i == 0)

            if right:
                if not first and sections[i - 1].bg == sec.bg:
                    p.append('{%s}%s%s' % (sec.fg, sep2, sec.content))
                else:
                    p.append('{%s}%s{BACKGROUND_%s}{%s}%s' % (sec.bg, sep1, sec.bg, sec.fg, sec.content))
            else:
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
            separators = args[1][:4]
            if len(separators) < 4:
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
    prompt_str = __xonsh__.env["RP_PROMPT"] or ''
    prompt2_str = __xonsh__.env["RP_PROMPT2"] or ''
    prompt = ''
    prompt2 = ''
    if prompt_str:
        prompt = rp_prompt_builder(prompt_str)
    if prompt2_str:
        prompt2 = rp_prompt_builder(prompt2_str)

    if prompt:
        __xonsh__.env["PROMPT"] = prompt if not prompt2 else lambda: prompt() + '\n' + prompt2()

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


def rp_init():
    for setting in DEFAULTS:
        if setting not in __xonsh__.env:
            __xonsh__.env[setting] = DEFAULTS[setting]

    rp_build_prompt()


rp_init()
