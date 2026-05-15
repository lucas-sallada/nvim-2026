return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = vim.tbl_deep_extend("force", opts.formatters.prettier or {}, {
        prepend_args = function(_, ctx)
          if vim.bo[ctx.buf].filetype == "yaml" then
            return { "--single-quote" }
          end
          return {}
        end,
      })
    end,
  },
}
