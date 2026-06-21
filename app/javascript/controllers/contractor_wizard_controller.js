import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="contractor-wizard"
export default class extends Controller {
  static targets = ["step", "nextBtn", "backBtn", "submitBtn", "skipLink", "progress"]

  connect() {
    this.currentStep = 0
    this.renderCurrentStep()
    console.log("🔒 Contractor Wizard Stimulus Controller connected successfully!")
  }

  // Intercept the click on the next button and validate the current step
  nextStep(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    const currentStepElement = this.stepTargets[this.currentStep]
    let isStepValid = true

    // --- SENIOR DEFENSIVE PROGRAMMING BLOCK ---
    // We wrap visual error rendering in a try/catch. Even if DOM-manipulation fails,
    // the core wizard navigation will never freeze again.
    try {
      // Clear old errors and red borders before re-validating
      currentStepElement.querySelectorAll(".is-invalid").forEach(el => {
        el.classList.remove("is-invalid")
        el.style.borderColor = ""
      })
      currentStepElement.querySelectorAll(".wizard-error-msg").forEach(el => el.remove())

      // Scan ALL input fields within the current step container
      const inputs = currentStepElement.querySelectorAll("input")
      inputs.forEach(input => {
        // Check if field is required by attribute or matches vital onboarding keys
        if (input.hasAttribute("required") || input.id.includes("name") || input.id.includes("street") || input.id.includes("city") || input.id.includes("postcode") || input.id.includes("radius")) {
          if (input.value.trim() === "") {
            isStepValid = false
            input.classList.add("is-invalid")
            input.style.borderColor = "#dc3545" // Inline border injection

            // Inject explicit English error text block safely
            const errorMsg = document.createElement("div")
            errorMsg.className = "wizard-error-msg"
            errorMsg.style.color = "#dc3545"
            errorMsg.style.fontSize = "13px"
            errorMsg.style.marginTop = "5px"
            errorMsg.style.fontWeight = "500"
            errorMsg.innerText = "Please fill out this field."

            if (input.parentNode) {
              input.parentNode.appendChild(errorMsg)
            }
          }
        }
      })
    } catch (error) {
      console.error("Visual error tracing failed, bypassing to protect wizard flow:", error)
    }

    // HARD STOP: If text fields are blank, prevent moving forward
    if (!isStepValid) return false

    // Business rule validation for specific steps
    try {
      // Step 2 (Index 1): Core services checkboxes
      if (this.currentStep === 1) {
        const checkedBoxes = currentStepElement.querySelectorAll('input[type="checkbox"]:checked')
        if (checkedBoxes.length === 0) {
          alert("Please select at least one core service category!")
          return false
        }
      }

      // Step 4 (Index 3): Travel radius
      if (this.currentStep === 3) {
        const radiusInput = currentStepElement.querySelector('input[name*="travel_radius"]')
        if (radiusInput && (parseInt(radiusInput.value) <= 0 || radiusInput.value.trim() === "")) {
          alert("Please enter a valid travel radius greater than 0 km!")
          radiusInput.focus()
          return false
        }
      }
    } catch (error) {
      console.error("Business rule check encountered an issue:", error)
    }

    // THE CRITICAL MOVEMENT: If everything is valid, advance to the next step
    if (this.currentStep < this.stepTargets.length - 1) {
      this.currentStep++
      this.renderCurrentStep()
    }
  }

  // Handle back button step transition
  prevStep(event) {
    if (event) event.preventDefault()
    if (this.currentStep > 0) {
      this.currentStep--
      this.renderCurrentStep()
    }
  }

  // Manage visibility states of HTML elements based on current step index
  renderCurrentStep() {
    this.stepTargets.forEach((element, index) => {
      if (index === this.currentStep) {
        element.classList.remove("d-none")
        element.classList.add("wizard-step-active")
      } else {
        element.classList.remove("wizard-step-active")
        element.classList.add("d-none")
      }
    })

    if (this.hasBackBtnTarget) {
      this.currentStep === 0 ? this.backBtnTarget.classList.add("d-none") : this.backBtnTarget.classList.remove("d-none")
    }

    if (this.hasNextBtnTarget && this.hasSubmitBtnTarget) {
      if (this.currentStep === this.stepTargets.length - 1) {
        this.nextBtnTarget.classList.add("d-none")
        this.submitBtnTarget.classList.remove("d-none")
      } else {
        this.nextBtnTarget.classList.remove("d-none")
        this.submitBtnTarget.classList.add("d-none")
      }
    }

    if (this.hasSkipLinkTarget) {
      this.currentStep > 0 ? this.skipLinkTarget.classList.add("d-none") : this.skipLinkTarget.classList.remove("d-none")
    }

    if (this.hasProgressTarget) {
      const progressPercent = ((this.currentStep + 1) / this.stepTargets.length) * 100
      this.progressTarget.style.width = `${progressPercent}%`
    }
  }

  // Enforce final form submit validation for mandatory availability profiles (Step 5)
  submitForm(event) {
    const currentStepElement = this.stepTargets[this.currentStep]
    const checkedRadios = currentStepElement.querySelectorAll('input[type="radio"]:checked')

    if (checkedRadios.length === 0 && this.currentStep === this.stepTargets.length - 1) {
      event.preventDefault()
      alert("Please select your availability profile to complete registration.")
      return false
    }
  }
}
