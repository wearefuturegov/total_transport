require 'rails_helper'

RSpec.describe Booking, type: :model do
  
  it 'sends a confirmation' do
    booking = FactoryGirl.create(:booking)
    expect { booking.send_confirmation! }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq(booking.phone_number)
  end

  describe "pickup_between_times" do
    before do
      @route = FactoryGirl.create(:route)
      @stop1 = FactoryGirl.create(:stop, route: @route, position: 1)
      @stop2 = FactoryGirl.create(:stop, route: @route, minutes_from_last_stop: 20, position: 2)
      @stop3 = FactoryGirl.create(:stop, route: @route, minutes_from_last_stop: 20, position: 3)
      @stop4 = FactoryGirl.create(:stop, route: @route, minutes_from_last_stop: 20, position: 4)
      @journey1 = FactoryGirl.create(:journey, route: @route, start_time: "01/01/2016 6:00".to_time)
      @journey2 = FactoryGirl.create(:journey, route: @route, start_time: "01/01/2016 6:30".to_time)
      @journey3 = FactoryGirl.create(:journey, route: @route, start_time: "02/01/2016 6:00".to_time)
      # 6:20
      @booking1 = Booking.create!(pickup_stop: @stop2, journey: @journey1, state: 'booked')
      # 6:40
      @booking2 = Booking.create!(pickup_stop: @stop3, journey: @journey1, state: 'booked')
      # 6:30
      @booking3 = Booking.create!(pickup_stop: @stop1, journey: @journey2, state: 'booked')
      # next day
      @booking4 = Booking.create!(pickup_stop: @stop1, journey: @journey3, state: 'booked')
      # 6:40, not booked
      @booking5 = Booking.create!(pickup_stop: @stop3, journey: @journey1, state: '')
    end

    it "should return bookings that pickup during that time" do
      bookings = Booking.pickup_between_times(
        "01/01/2016 6:00".to_time,
        "01/01/2016 6:29".to_time
      )
      expect(bookings).to eq([@booking1])
      bookings = Booking.pickup_between_times(
        "01/01/2016 6:30".to_time,
        "01/01/2016 7:00".to_time
      )
      expect(bookings).to eq([@booking2, @booking3])
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
