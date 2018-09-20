"""Extend the default .ycm_extra_conf.py file.

The default .ycm_extra_conf.py file provided by the Vundle.vim plugin
Valloric/YouCompleteMe does not implement the FlagsForFile method, resulting
in an error. This script executes the ycm_extra_conf file then implements the
missing method.

This python code does not follow YouCompleteMe's code style.
"""

import os

home = os.path.expanduser('~')
conf_path = '%s/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py' % home
with open(conf_path, 'r') as conf:
    default = conf.read()

exec(default)


def FlagsForFile(filename, **kwargs):
    """Return the compilation args to use for filename."""
    print(kwargs)
    ext = os.path.splitext(filename)[1]
    if ext == '.c':
        lang = 'c'
    elif ext == '.cpp':
        lang = 'c++'

    home = os.path.expanduser('~')
    includes = '-I' + home + '/.include'
    libs = '-L' + home + '/.lib'

    return {
        'flags': ['-x', lang, '-std=c11', '-O3', '-Wall', '-Werror',
                  includes, libs, '-lm', '-lmylib']
    }
