class NotificationMailer < ApplicationMailer

  # 1. Email to contractor when a new listing matches their category & radius
  def new_match(contractor, listing)
    @contractor = contractor
    @listing = listing

    mail(
      to: @contractor.email,
      subject: "New job match: #{@listing.title}"
    )
  end

  # 2. Email to customer when a contractor sends an offer
  def new_offer(offer)
    @offer = offer
    @listing = offer.listing
    @contractor = offer.user
    @customer = @listing.user

    mail(
      to: @customer.email,
      subject: "New offer received for: #{@listing.title}"
    )
  end

  # 3. Email to customer when a contractor updates their offer
  def offer_updated(offer)
    @offer = offer
    @listing = offer.listing
    @contractor = offer.user
    @customer = @listing.user

    mail(
      to: @customer.email,
      subject: "An offer was updated for: #{@listing.title}"
    )
  end

  # 4. Email to contractor when their offer is accepted
  def offer_accepted(offer)
    @offer = offer
    @listing = offer.listing
    @contractor = offer.user

    mail(
      to: @contractor.email,
      subject: "Your offer was accepted: #{@listing.title}"
    )
  end

  # 5. Email to contractor when their offer is declined
  def offer_declined(offer)
    @offer = offer
    @listing = offer.listing
    @contractor = offer.user

    mail(
      to: @contractor.email,
      subject: "Your offer was declined: #{@listing.title}"
    )
  end

  # 6. Email to both parties when a booking is confirmed
  def booking_confirmed(booking, recipient)
    @booking = booking
    @offer = booking.offer
    @listing = @offer.listing
    @recipient = recipient

    mail(
      to: recipient.email,
      subject: "Booking confirmed: #{@listing.title}"
    )
  end

  # 7. Email to recipient when they receive a new message
  def new_message(message, recipient)
    @message = message
    @recipient = recipient
    @sender = message.user

    mail(
      to: recipient.email,
      subject: "New message from #{@sender.first_name}"
    )
  end

  # 8. Email to both parties when a booking is cancelled
  def booking_cancelled(booking, recipient)
    @booking = booking
    @offer = booking.offer
    @listing = @offer.listing
    @recipient = recipient

    mail(
      to: recipient.email,
      subject: "Booking cancelled: #{@listing.title}"
    )
  end

  # 9. Email to both parties when a booking date is changed
  def date_changed(booking, recipient)
    @booking = booking
    @offer = booking.offer
    @listing = @offer.listing
    @recipient = recipient

    mail(
      to: recipient.email,
      subject: "Booking date changed: #{@listing.title}"
    )
  end

  # 10. Email to user when they receive a new review
  def new_review(review)
    @review = review
    @recipient = review.reviewee

    mail(
      to: @recipient.email,
      subject: "You received a new review on Handyman!"
    )
  end

  # 11. Email to both parties when a listing location is changed
  def location_changed(listing, recipient)
    @listing = listing
    @recipient = recipient

    mail(
      to: recipient.email,
      subject: "Job location updated: #{@listing.title}"
    )
  end

  # 12. Welcome email upon account creation (email only)
  def welcome(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Welcome to Handyman! 🎉"
    )
  end

  # 13.Email to contractor when a listing they offered on is deleted
  def listing_deleted(offer)
    @offer = offer
    @contractor = offer.user

    mail(
      to: @contractor.email,
      subject: "A job listing you applied to has been removed"
    )
  end

end
