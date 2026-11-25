---@type LazySpec
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ---@type Mason.Package[]
    ensure_installed = {
      -- NOTE: "nil" (the Nix LSP, nil_ls) is deliberately absent. Mason installs it
      -- via `cargo install`, but its builtin crate's build.rs shells out to the `nix`
      -- binary, so the build fails on any host without Nix -- and on a host with Nix
      -- the packaged binary is better anyway. install.sh --with-nix provides it.
      "nixfmt", -- RFC 166 formatter, the nixpkgs standard
    },
  },
  opts_extend = {
    "ensure_installed",
  },
  optional = true,
}
