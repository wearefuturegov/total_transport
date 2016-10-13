require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe "pricing" do
    let(:booking) {Booking.new}
    describe "for a journey under 2 miles" do
      before {allow(booking).to receive(:price_distance).and_return(1.9) }
      describe "for a single journey" do
        before {allow(booking).to receive(:return_journey?).and_return(false) }
        it "should cost 2.5 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(2.5)
        end
        it "should cost 5 for 2 passengers" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(5)
        end
        it "should cost 4 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(4)
        end
        it "should cost 2.5 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(2.5)
        end
      end
      describe "for a return journey" do
        before {allow(booking).to receive(:return_journey?).and_return(true) }
        it "should cost 3.5 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(3.5)
        end
        it "should cost 7 for 2 passenger" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(7)
        end
        it "should cost 5.5 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(5.5)
        end
        it "should cost 3.5 for 2 passengers with 1 older pass" do
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
        it "should cost 4.5 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(4.5)
        end
        it "should cost 9 for 2 passengers" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(9)
        end
        it "should cost 7 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(7)
        end
        it "should cost 4.5 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(4.5)
        end
      end
      describe "for a return journey" do
        before {allow(booking).to receive(:return_journey?).and_return(true) }
        it "should cost 6.5 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(6.5)
        end
        it "should cost 13 for 2 passenger" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(13)
        end
        it "should cost 10 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(10)
        end
        it "should cost 6.5 for 2 passengers with 1 older pass" do
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
        it "should cost 5.5 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(5.5)
        end
        it "should cost 11 for 2 passengers" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(11)
        end
        it "should cost 8.5 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(8.5)
        end
        it "should cost 5.5 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(5.5)
        end
        it "should cost 2.5 for 2 passengers with 1 older pass and promo code of £3" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 3)
          booking.promo_code = promo_code
          expect(booking.price).to eq(2.5)
        end
        it "should cost 0 for 2 passengers with 1 older pass and promo code of £10" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 10)
          booking.promo_code = promo_code
          expect(booking.price).to eq(0)
        end
      end
      describe "for a return journey" do
        before {allow(booking).to receive(:return_journey?).and_return(true) }
        it "should cost 8 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(8)
        end
        it "should cost 16 for 2 passenger" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(16)
        end
        it "should cost 12.5 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(12.5)
        end
        it "should cost 8 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(8)
        end
        it "should cost 8 for 2 passengers with 1 older pass and promo code of £3" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 3)
          booking.promo_code = promo_code
          expect(booking.price).to eq(5)
        end
        it "should cost 0 for 2 passengers with 1 older pass and promo code of £10" do
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
