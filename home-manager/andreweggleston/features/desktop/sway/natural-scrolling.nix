{ config, ... }:
{
  wayland.windowManager.sway.config.input = {
    "type:pointer" = { 
      natural_scroll = "disabled";
    };

    "type:touchpad" = { 
      natural_scroll = "disabled";
    };

    "type:mouse" = {
      natural_scroll = "disabled";
    };
  };
}
