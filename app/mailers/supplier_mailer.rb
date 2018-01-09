class SupplierMailer < ApplicationMailer
  default from: ENV['RIDE_ADMIN_EMAIL']

  def approved_email(supplier)
    @supplier = supplier
    mail(to: @supplier.email, subject: 'You have been approved')
  end
end
