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
    ext = os.path.splitext(filename)[1]
    if ext == '.c':
        lang = 'c'
        std = '-std=c11'
    elif ext == '.cpp':
        lang = 'c++'
        std = '-std=c++11'

    return {
        'flags': ['-x', lang, std, '-O3', '-Wall', '-Werror']
    }
