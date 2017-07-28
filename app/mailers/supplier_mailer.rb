class SupplierMailer < ApplicationMailer
  default from: 'jamesd@wearefuturegov.com'

  def approved_email(supplier)
    @supplier = supplier
    mail(to: @supplier.email, subject: 'You have been approved')
  end
  
  def journey_email(suppliers, journey, vehicles)
    @journey = journey
    @vehicles = vehicles
    mail(to: suppliers.map(&:email), subject: 'A journey is available for approval')
  end
end
