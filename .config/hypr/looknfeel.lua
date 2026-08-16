-- Change the default Omarchy look'n'feel.

hl.config({
  general = {
    border_size = 1,
  },

  decoration = {
    rounding = 15,
  },
})

-- Slide between workspaces (disabled by default in quattro).
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slide" })
