# integrate OBS hotkeys into wayland global shortcuts
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  obs-studio,
  qtbase,
  qtwayland,
  wayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "obs-wayland-hotkeys";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "leia-uwu";
    repo = "obs-wayland-hotkeys";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m/AW2glyxJLPWcptZYbZ9Befm4gNmD1V3JDC8hjKtkA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    obs-studio
    qtbase
    qtwayland
    wayland
  ];

  # don't need to wrap anything, plugin is loaded
  dontWrapQtApps = true;

  cmakeFlags = [
    # yolo
    (lib.cmakeBool "CMAKE_COMPILE_WARNING_AS_ERROR" false)
  ];

  meta = {
    description = "OBS Studio plugin to integrate OBS hotkeys with the wayland global shortcuts portal";
    homepage = "https://github.com/leia-uwu/obs-wayland-hotkeys";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
