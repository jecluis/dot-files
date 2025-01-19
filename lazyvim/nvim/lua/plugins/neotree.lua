return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({
            action = "focus",
            dir = LazyVim.root(),
          })
        end,
        desc = "Explorer NeoTree (Root Dir)",
        remap = true,
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({
            action = "focus",
            dir = vim.uv.cwd(),
          })
        end,
        desc = "Explorer NeoTree (cwd)",
        remap = true,
      },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({
            source = "git_status",
            action = "focus",
          })
        end,
        desc = "Git Explorer",
        remap = true,
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({
            source = "buffers",
            action = "focus",
          })
        end,
        desc = "Buffer Explorer",
        remap = true,
      },
    },
  },
}
