class SupplierMailer < ApplicationMailer
  default from: 'jamesd@wearefuturegov.com'

  def approved_email(supplier)
    @supplier = supplier
    mail(to: @supplier.email, subject: 'You have been approved')
  end
end
