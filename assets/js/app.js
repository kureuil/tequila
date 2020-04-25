// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

document.addEventListener("DOMContentLoaded", function(event) {
  let offCanvasContainer = document.getElementById("off-canvas-container");
  let offCanvasBackdrop = document.getElementById("off-canvas-backdrop");
  let offCanvasMenu = document.getElementById("off-canvas-menu");
  let offCanvasOpenTrigger = document.getElementById("off-canvas-open-trigger");
  let offCanvasCloseTrigger = document.getElementById("off-canvas-close-trigger");

  offCanvasOpenTrigger.addEventListener("click", function (event) {
    offCanvasBackdrop.classList.remove("opacity-0");
    offCanvasBackdrop.classList.add("opacity-100");
    offCanvasMenu.classList.remove("-translate-x-full");
    offCanvasMenu.classList.add("translate-x-0");
    offCanvasContainer.style.display = 'flex';
  });

  offCanvasCloseTrigger.addEventListener("click", function (event) {
    offCanvasContainer.style.display = 'none';
  });

  let userMenu = document.getElementById("user-menu");
  let userMenuTrigger = document.getElementById("user-menu-trigger");

  userMenuTrigger.addEventListener("click", function (event) {
    if (window.getComputedStyle(userMenu).display === 'none') {
      userMenu.style.display = 'block';
    } else {
      userMenu.style.display = 'none';
    }
  });
});
