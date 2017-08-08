FactoryGirl.define do
  factory(:suggested_journey) do
    description "dsfsdfsdfsdf"
    passenger
    route
    start_time "2016-08-11T13:52 UTC"
    booking
    
    # We don't want the Dispatcher to actually run after create in tests, but
    # this is a nicer solution than removing callbacks
    before(:create) do
      double = instance_double("Dispatcher")
      allow(Dispatcher).to receive(:new) {
        allow(double).to receive(:perform!)
        double
      }
    end
    
    # Once the callback has been fired, we reset the stub
    after(:create) do
      allow(Dispatcher).to receive(:new).and_call_original
    end
  end
end
