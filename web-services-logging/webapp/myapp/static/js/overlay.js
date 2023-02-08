// Derived from: https://www.w3schools.com/howto/howto_css_overlay.asp

var overlay = document.getElementById("overlay");

function overlayOn() {
    overlay.style.display = "flex";
}
  
function overlayOff() {
    overlay.style.display = "none";
}

overlay.addEventListener("click", overlayOff);