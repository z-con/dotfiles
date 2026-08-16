-- Change the default Omarchy look'n'feel.

hl.config({
  general = {
    border_size = 1,
  },

  decoration = {
    rounding = 15,

    -- Off by default in quattro; needed so translucent surfaces (terminal
    -- background-opacity, the walker launcher) blur what's behind them
    -- instead of showing it through sharply.
    blur = {
      enabled = true,
    },
  },
})

-- Slide between workspaces (disabled by default in quattro).
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slide" })
