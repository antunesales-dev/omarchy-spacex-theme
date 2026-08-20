local active_border_color = "rgba(ffffffff)"
local inactive_border_color = "rgba(00000000)"

hl.config({
  general = {
    gaps_in = 12,
    gaps_out = 32,
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
    dim_inactive = false,
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
    groupbar = {
      font_family = "D-DIN",
      indicator_height = 1,
      text_color = "rgb(ffffff)",
      text_color_inactive = "rgb(ffffff)",
      col = {
        active = "rgba(ffffffff)",
        inactive = "rgba(000000ff)",
      },
      gradients = false,
      gradient_rounding = 0,
    },
  },
})
