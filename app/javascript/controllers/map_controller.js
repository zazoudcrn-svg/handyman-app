import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["listContainer", "mapContainer", "listBtn", "mapBtn"]
  static values  = { listings: Array, token: String }

  connect() {
    this.mapInitialized = false
  }

  showList() {
    this.listContainerTarget.classList.remove("d-none")
    this.mapContainerTarget.classList.add("d-none")
    this.listBtnTarget.classList.add("active")
    this.mapBtnTarget.classList.remove("active")
  }

  showMap() {
    this.listContainerTarget.classList.add("d-none")
    this.mapContainerTarget.classList.remove("d-none")
    this.listBtnTarget.classList.remove("active")
    this.mapBtnTarget.classList.add("active")

    if (!this.mapInitialized) {
      this.initMap()
      this.mapInitialized = true
    }
  }

  initMap() {
    mapboxgl.accessToken = this.tokenValue

    const validListings = this.listingsValue.filter(l => l.latitude && l.longitude)

    // Center map on the average position of all visible listings; fall back to London
    let center = [-0.1276, 51.5074]
    if (validListings.length > 0) {
      const avgLat = validListings.reduce((sum, l) => sum + l.latitude, 0) / validListings.length
      const avgLng = validListings.reduce((sum, l) => sum + l.longitude, 0) / validListings.length
      center = [avgLng, avgLat]
    }

    const map = new mapboxgl.Map({
      container: this.mapContainerTarget,
      style: "mapbox://styles/mapbox/light-v11",
      center: center,
      zoom: 10
    })

    map.addControl(new mapboxgl.NavigationControl(), "top-right")

    validListings.forEach(listing => {
      const popup = new mapboxgl.Popup({ offset: 25, closeButton: true, maxWidth: "280px" })
        .setHTML(this.popupHTML(listing))

      new mapboxgl.Marker({ color: listing.urgency === "emergency" ? "#EF4444" : "#2F6BFF" })
        .setLngLat([listing.longitude, listing.latitude])
        .setPopup(popup)
        .addTo(map)
    })
  }

  popupHTML(listing) {
    const urgencyLabels = {
  emergency: "Emergency",
  normal:    "Normal",
  this_week: "This week",
  flexible:  "Flexible"
  }
  const availLabels = {
    after_hours_and_weekend: "After hours & weekends",
    completely_flexible:     "Completely flexible",
    workdays_daytime:        "Workdays daytime only",
    anytime:                 "Anytime",
    other:                   "Other"
  }

  const capitalize = str => str ? str.charAt(0).toUpperCase() + str.slice(1).replace(/_/g, " ") : ""

  const urgencyLabel = urgencyLabels[listing.urgency] || capitalize(listing.urgency)
  const availLabel   = availLabels[listing.availability_profile] || capitalize(listing.availability_profile)

    const photoHTML = listing.photo_url
      ? `<div style="width:100%; height:130px; overflow:hidden; border-radius:8px 8px 0 0;">
          <img src="${listing.photo_url}" style="width:100%; height:100%; object-fit:cover; display:block;">
        </div>`
      : `<div style="width:100%; height:80px; background:#F1F5F9; border-radius:8px 8px 0 0; display:flex; align-items:center; justify-content:center;">
          <i class="fa-solid fa-hammer" style="color:#94A3B8; font-size:20px;"></i>
        </div>`

    return `
      <div style="font-family:'Manrope',sans-serif; border-radius:8px; overflow:hidden; width:260px;">
        ${photoHTML}
        <div style="padding:14px 14px 16px;">
          <p style="font-size:13px; font-weight:600; color:#0B1B33; margin:0 0 14px; line-height:1.4;">${listing.title}</p>
          <div style="display:flex; flex-direction:column; gap:10px; margin-bottom:16px;">
            <span style="font-size:12px; color:#475569; display:flex; align-items:center; gap:7px;">
              <i class="bi bi-hourglass-split" style="color:#2F6BFF; font-size:12px; flex-shrink:0;"></i>
              ${urgencyLabel}
            </span>
            <span style="font-size:12px; color:#475569; display:flex; align-items:center; gap:7px;">
              <i class="bi bi-calendar3" style="color:#2F6BFF; font-size:12px; flex-shrink:0;"></i>
              ${availLabel}
            </span>
          </div>
          <a href="${listing.url}" target="_blank"
            style="display:block; text-align:center; background:#2F6BFF; color:white; font-size:12px; font-weight:600; padding:8px 12px; border-radius:8px; text-decoration:none;">
            View Listing →
          </a>
        </div>
      </div>
    `
  }
}
