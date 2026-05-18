document.addEventListener("DOMContentLoaded", () => {

  window.openCalendarLayer = function(date) {
    fetch(`/calendar/layer?date=${date}`)
      .then(res => res.text())
      .then(html => {
        const layer = document.getElementById("calendarLayer");
        const body = document.getElementById("calendarLayerBody");

        body.innerHTML = html;

        layer.classList.remove("hidden");
        layer.classList.add("flex");
      });
  };

  window.closeCalendarLayer = function() {
    const layer = document.getElementById("calendarLayer");
    layer.classList.add("hidden");
    layer.classList.remove("flex");
  };

});
