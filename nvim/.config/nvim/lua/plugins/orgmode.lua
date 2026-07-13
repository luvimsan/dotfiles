require("plugins.lazyload").on_vim_enter(function()
	vim.pack.add({
		{ src = 'https://github.com/nvim-orgmode/orgmode' },
	})

	require('orgmode').setup({
		org_agenda_files =  { '~/org/tasks.org', '~/org/refile.org' },
		org_default_notes_file = '~/org/refile.org',
		org_archive_location = '~/org/archive.org::*',

		org_startup_folded = 'content',
		org_hide_emphasis_markers = true,
		org_hide_leading_stars = true,


		org_capture_templates = {
			t = {
				description = 'task',
				template = '*** TODO %?\n    SCHEDULED: %t',
				target = '~/org/tasks.org',
				datetree = true
			},
			s = {
				description = 'links',
				template = '** [[%^{Link}][%?]]\n Notes: ',
				target = '~/org/links.org',
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
				target = '~/org/words.org',
			},
		}
	})
end)
