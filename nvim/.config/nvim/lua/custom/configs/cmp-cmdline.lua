local cmp = require "cmp"

cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline {
    ["<C-y>"] = {
      c = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
    },
  },
  sources = {
    { name = "buffer" },
  },
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline {
    ["<C-y>"] = {
      c = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
    },
  },
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    {
      name = "cmdline",
      option = {
        ignore_cmds = { "Man", "!" },
      },
    },
  }),
})
