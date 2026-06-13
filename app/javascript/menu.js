// Mobile sidebar toggle and settings submenu behavior
document.addEventListener("DOMContentLoaded", () => {
  const btn = document.getElementById("menuButton");
  const menu = document.getElementById("mobileMenu");

  if (btn && menu) {
    btn.addEventListener("click", () => {
      menu.classList.toggle("-translate-x-full");
    });
  }
});

// Toggle settings submenu open/close (invoked via onclick="toggleSettingsMenu(this)")
window.toggleSettingsMenu = function (button) {
  const submenu = button.nextElementSibling;
  const arrow = button.querySelector(".settings-arrow");
  submenu.classList.toggle("hidden");
  arrow.style.transform = submenu.classList.contains("hidden") ? "" : "rotate(180deg)";
};
