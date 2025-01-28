return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    branch = "master",
    -- ft = { "org" },
    config = function()
      require("orgmode").setup_ts_grammar()
      require("orgmode").setup({
        org_agenda_files = { "~/docs/org/files/**/*" },
        org_default_notes_file = "~/docs/org/files/refile.org",
      })
    end,
  },
}
