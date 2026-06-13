require("plugins.lazyload").on_vim_enter(function()
	vim.pack.add({
		{ src = 'https://github.com/nvim-orgmode/orgmode' },
	})

	require('orgmode').setup({
		org_agenda_files =  { '~/org/inbox.org', '~/org/refile.org' },
		org_default_notes_file = '~/org/refile.org',
		org_archive_location = '~/org/archive.org::*',

		org_startup_folded = 'content',
		org_hide_emphasis_markers = true,
		org_hide_leading_stars = true,


		org_capture_templates = {
			t = {
				description = 'task',
				template = '*** TODO %?\n    SCHEDULED: %t',
				target = '~/org/inbox.org',
				datetree = true
			},
			s = {
				description = 'save-later',
				template = '** [[%^{Link}][%?]]\n Notes: ',
				target = '~/org/refile.org',
				headline = 'Youtube Videos',
			},
			n = {
				description = 'notes',
				template = '** %?\n',
				target = '~/org/refile.org',
				headline = 'Random Notes',
			},
			e = {
				description = 'english words',
				template = '- %?\n',
				target = '~/org/errors.org',
			},
		}
	})
end)
