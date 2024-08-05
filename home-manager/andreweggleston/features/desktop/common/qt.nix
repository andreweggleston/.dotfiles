{config, ...}: let
  style =
    if config.colorScheme.variant == "dark"
    then "adwaita-dark"
    else "adwaita";
in {
  qt = {
    enable = true;
    style.name = style;
    platformTheme.name = style;
  };
}
