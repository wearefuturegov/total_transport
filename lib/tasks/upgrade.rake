task :upgrade => :environment do
  Supplier.all.each do |supplier|
    supplier.update_attribute(:approved, true)
  end
end
