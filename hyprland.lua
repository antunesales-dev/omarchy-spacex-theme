local active_border_color = { colors = { "rgba(c4c8ccee)", "rgba(ffffffff)" }, angle = 45 }
local inactive_border_color = "rgba(2a2a2aaa)"

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 1,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  decoration = {
    rounding = 0,
    shadow = { enabled = false },
    blur = { enabled = false },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
    groupbar = {
      font_family = "IBM Plex Mono",
      indicator_height = 1,
      text_color = "rgb(f5f5f5)",
      text_color_inactive = "rgba(c4c8cc90)",
      col = {
        active = "rgba(c4c8cc30)",
        inactive = "rgba(00000080)",
      },
      gradient_rounding = 0,
    },
  },
})
