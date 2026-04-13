''
  @define-color rosewater #f4dbd6;
  @define-color flamingo #f0c6c6;
  @define-color pink #f5bde6;
  @define-color mauve #c6a0f6;
  @define-color red #ed8796;
  @define-color maroon #ee99a0;
  @define-color peach #f5a97f;
  @define-color yellow #eed49f;
  @define-color green #a6da95;
  @define-color teal #8bd5ca;
  @define-color sky #91d7e3;
  @define-color sapphire #7dc4e4;
  @define-color blue #8aadf4;
  @define-color lavender #b7bdf8;
  @define-color text #cad3f5;
  @define-color subtext1 #b8c0e0;
  @define-color subtext0 #a5adcb;
  @define-color overlay2 #939ab7;
  @define-color overlay1 #8087a2;
  @define-color overlay0 #6e738d;
  @define-color surface2 #5b6078;
  @define-color surface1 #494d64;
  @define-color surface0 #363a4f;
  @define-color base #24273a;
  @define-color mantle #1e2030;
  @define-color crust #181926;

  @define-color focused @mauve;
  @define-color urgent @mauve;
  @define-color critical @red;
  @define-color section-one @mantle;
  @define-color section-two @base;
  @define-color section-three @surface0;
  @define-color section-four @mantle;

  @keyframes urgent-animation {
    50% {
      color: @text;
      background: @urgent;
    }
  }

  @keyframes critical-animation {
    50% {
      color: @text;
      background: @critical;
    }
  }

  * {
    font-family: "Hack Nerd Font Mono";
    font-size: 1rem;
    border: none;
    border-radius: 0;
    min-height: 0;
    margin: 0;
    padding: 0;
  }

  window#waybar {
    background: transparent;
    color: @mauve;
  }

  .modules-left label.module,
  .modules-center label.module,
  .modules-right label.module {
    padding: 0 8px;
  }

  tooltip {
    background-color: shade(@base, 0.9);
    border: 1px solid @crust;
  }

  tooltip label {
    color: @mauve;
  }

  #workspaces button {
    color: @mauve;
    padding: 0 8px;
  }

  #workspaces button.focused,
  #workspaces button:hover,
  #workspaces button.active {
    background: @focused;
    color: @section-one;
  }

  #workspaces button.urgent {
    animation: urgent-animation 1s steps(3) infinite;
  }

  /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
  #workspaces button:hover {
    box-shadow: inherit;
    text-shadow: inherit;
  }

  #mode {
    padding: 0 8px;
    background: @section-one;
  }

  #idle_inhibitor {
    font-size: 20px;
    min-width: 16px;
  }

  #idle_inhibitor.activated {
    color: @focused;
  }

  #workspaces button,
  #idle_inhibitor {
    background: @section-one;
  }

  #custom-left-spacer-workspaces,
  #custom-right-spacer-workspaces {
    font-size: 20px;
    padding: 0;
  }

  #custom-right-spacer-workspaces {
    color: @section-one;
    background: @section-two;
  }

  #custom-right-spacer-tray {
    font-size: 20px;
    padding: 0;
    color: @section-two;
  }

  #custom-left-spacer-audio {
    font-size: 20px;
    color: @section-three;
    padding: 0;
  }

  #custom-left-spacer-organisation {
    font-size: 20px;
    color: @section-two;
    padding: 0;
  }

  #custom-right-spacer-organisation {
    font-size: 20px;
    color: @section-two;
    background: @section-three;
    padding: 0;
  }

  #custom-right-spacer-hardware {
    font-size: 20px;
    padding: 0;
    color: @section-three;
    background: @section-four;
  }

  #custom-right-spacer-information {
    color: @section-three;
    padding: 0;
    font-size: 20px;
  }

  #tray {
    padding: 0 4px;
  }

  #tray > .passive {
    -gtk-icon-effect: dim;
  }

  #tray > .active {
    -gtk-icon-effect: highlight;
  }

  #tray > .needs-attention {
    -gtk-icon-effect: highlight;
    animation: urgent-animation 0.5s steps(10) infinite;
  }

  #privacy {
    padding: 0px;
  }

  #privacy-item.screenshare,
  #privacy-item.audio-in {
    padding: 0 8px;
  }

  #clock,
  #custom-calendar,
  #cava,
  #tray,
  #custom-yay,
  #mpris,
  #cava {
    color: @mauve;
    background: @section-two;
  }

  #custom-yubikey {
    font-size: 20px;
    animation: urgent-animation 0.5s steps(10) infinite;
  }

  #custom-weather,
  #custom-crypto {
    color: @sapphire;
    background: @section-three;
  }

  #custom-crypto {
    font-family: cryptofont, monospace;
  }

  #pulseaudio,
  #memory,
  #cpu,
  #temperature,
  #disk,
  #power-profiles-daemon {
    background: @section-three;
  }

  #memory {
    color: @orange;
  }

  #cpu {
    color: @pink;
  }

  #temperature {
    color: @green;
  }

  #temperature.gpu {
    color: @red;
  }

  #temperature.critical,
  #temperature.gpu.critical {
    color: @blue;
    animation: critical-animation 0.5s steps(10) infinite;
  }

  #disk {
    color: @yellow;
  }

  #power-profiles-daemon.balanced {
    color: @white;
  }

  #power-profiles-daemon.performance {
    color: @pink;
  }

  #power-profiles-daemon.power-saver {
    color: @green;
  }

  #network,
  #backlight,
  #battery,
  #battery.bat1,
  #custom-swaync,
  #network,
  #custom-logout {
    background: @section-four;
  }

  #custom-swaync {
  }

  #bluetooth.off,
  #network.disconnected,
  #network.vpn.disconnected {
  }

  #network.vpn {
    color: @green;
  }

  #battery.charging {
    color: @green;
  }

  #battery.critical:not(.charging) {
    color: @blue;
    animation: critical-animation 0.5s steps(10) infinite;
  }
''
