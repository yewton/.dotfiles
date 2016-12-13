# -*- coding: utf-8; -*-
from __future__ import absolute_import

from datetime import datetime
import socket

from powerline.theme import requires_segment_info
from powerline.lib import add_divider_highlight_group
from powerline.lib.vcs import guess, tree_status

@add_divider_highlight_group('background:divider')
def internal_ip(pl):
    '''Return internal IP address.'''
    for ip in socket.gethostbyname_ex(socket.gethostname())[2]:
        if not ip.startswith('127.'):
            return ip

@requires_segment_info
def branch(pl, segment_info, status_colors=False):
	'''Return the current VCS branch.

	:param bool status_colors:
		determines whether repository status will be used to determine highlighting. Default: False.

	Highlight groups used: ``branch_clean``, ``branch_dirty``, ``branch``.
	'''
	name = segment_info['getcwd']()
        return name
	repo = guess(path=name)
        return [{
            'contents': repo,
            'highlight_group': ['branch_clean', 'branch']
        }]
	if repo is not None:
		branch = repo.branch()
		scol = ['branch']
		if status_colors:
			status = tree_status(repo, pl)
			scol.insert(0, 'branch_dirty' if status and status.strip() else 'branch_clean')
		return [{
			'contents': branch,
			'highlight_group': scol,
		}]

def date(pl, format='%Y-%m-%d', istime=False):
	'''Return the current date.

	:param str format:
		strftime-style date format string
	:param bool istime:
		If true then segment uses ``time`` highlight group.

	Divider highlight group used: ``time:divider``.

	Highlight groups used: ``time`` or ``date``.
	'''
	return [{
		'contents': datetime.now().strftime(format.encode('utf-8')),
		'highlight_group': (['time'] if istime else []) + ['date'],
		'divider_highlight_group': 'time:divider' if istime else None,
	}]
