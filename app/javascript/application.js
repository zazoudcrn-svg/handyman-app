// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
// Add Flatpickr
import flatpickr from "flatpickr";

// Initialize Flatpickr on Turbo load
document.addEventListener("turbo:load", () => {
  flatpickr(".date-picker", {
    enableTime: true,
    dateFormat: "Y-m-d H:i",
    minDate: "today",

    // Disable weekends
    disable: [
      function(date) {
        return (date.getDay() === 0 || date.getDay() === 6);
      }
    ]
  });
});
