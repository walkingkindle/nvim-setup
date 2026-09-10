return {
  "mason-org/mason.nvim",
  -- Use `opts` rather than a `config` function: LazyVim's own `config` is what walks
  -- `ensure_installed` and installs the tools (gopls, gofumpt, goimports, delve,
  -- golangci-lint, ...). Replacing `config` here would keep the registries but
  -- silently drop every auto-install.
  opts = {
    registries = {
      "github:Crashdummyy/mason-registry",
      "github:mason-org/mason-registry",
    },
  },
}
