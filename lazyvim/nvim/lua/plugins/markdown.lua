return {
  {
    "iamcco/markdown-preview.nvim",
    init = function()
      vim.g.mkdp_open_to_the_world = 1
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_port = 8548
    end,
  },
}
