require 'rails_helper'

RSpec.describe Booking, type: :model do
  
  let(:booking) { FactoryGirl.create(:booking) }
  
  describe 'confirm!' do
    it 'sends a confirmation' do
      expect { booking.confirm! }.to change { FakeSMS.messages.count }.by(1)
      expect(FakeSMS.messages.last[:to]).to eq(booking.phone_number)
    end
    
    it 'queues alerts' do
      expect { booking.confirm! }.to change { SendSMS.jobs.count }.by(2)
      expect(SendSMS.jobs.first.run_at).to eq(booking.pickup_time - 24.hours)
      expect(SendSMS.jobs.last.run_at).to eq(booking.pickup_time - 1.hours)
    end
  end

  describe "pricing" do
    let(:booking) {Booking.new}
    describe "for a journey under 2 miles" do
      before {allow(booking).to receive(:price_distance).and_return(1.9) }
      describe "for a single journey" do
        before {allow(booking).to receive(:return_journey?).and_return(false) }
        it "should cost £2.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(2.5)
        end
        it "should cost £5.00 for 2 passengers" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(5)
        end
        it "should cost £4.00 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(4)
        end
        it "should cost £2.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(2.5)
        end
      end
      describe "for a return journey" do
        before {allow(booking).to receive(:return_journey?).and_return(true) }
        it "should cost £3.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(3.5)
        end
        it "should cost £7.00 for 2 passenger" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(7)
        end
        it "should cost £5.50 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(5.5)
        end
        it "should cost £3.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(3.5)
        end
      end
    end
    describe "for a journey between 2 & 5 miles" do
      before {allow(booking).to receive(:price_distance).and_return(3) }
      describe "for a single journey" do
        before {allow(booking).to receive(:return_journey?).and_return(false) }
        it "should cost £4.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(4.5)
        end
        it "should cost £9.00 for 2 passengers" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(9)
        end
        it "should cost £7.00 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(7)
        end
        it "should cost £4.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(4.5)
        end
      end
      describe "for a return journey" do
        before {allow(booking).to receive(:return_journey?).and_return(true) }
        it "should cost £6.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(6.5)
        end
        it "should cost £13.00 for 2 passenger" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(13)
        end
        it "should cost £10.00 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(10)
        end
        it "should cost £6.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(6.5)
        end
      end
    end
    describe "for a journey over 5 miles" do
      before {allow(booking).to receive(:price_distance).and_return(5.1) }
      describe "for a single journey" do
        before {allow(booking).to receive(:return_journey?).and_return(false) }
        it "should cost £5.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(5.5)
        end
        it "should cost £11.00 for 2 passengers" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(11)
        end
        it "should cost £8.50 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(8.5)
        end
        it "should cost £5.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(5.5)
        end
        it "should cost £2.50 for 2 passengers with 1 older pass and promo code of £3" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 3)
          booking.promo_code = promo_code
          expect(booking.price).to eq(2.5)
        end
        it "should cost £0.00 for 2 passengers with 1 older pass and promo code of £10" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 10)
          booking.promo_code = promo_code
          expect(booking.price).to eq(0)
        end
      end
      describe "for a return journey" do
        before {allow(booking).to receive(:return_journey?).and_return(true) }
        it "should cost £8.00 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(8)
        end
        it "should cost £16.00 for 2 passenger" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(16)
        end
        it "should cost £12.50 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(12.5)
        end
        it "should cost £8.00 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(8)
        end
        it "should cost £5.00 for 2 passengers with 1 older pass and promo code of £3" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 3)
          booking.promo_code = promo_code
          expect(booking.price).to eq(5)
        end
        it "should cost £0.00 for 2 passengers with 1 older pass and promo code of £10" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 10)
          booking.promo_code = promo_code
          expect(booking.price).to eq(0)
        end
      end
    end
  end
end
