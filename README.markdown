Total Transport
===============

Install
-------

You will need the following environment variables in .env:
`AIRBRAKE_API_KEY, TWILIO_ID, TWILIO_TOKEN, TWILIO_TEST_ID, TWILIO_TEST_TOKEN, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, S3_BUCKET_NAME`

Everything is pretty much normal Rails.

Overview
-------

You can find a [simplified model relation diagram here](https://docs.google.com/a/wearefuturegov.com/drawings/d/16yuR3xO2cEFFdOlnBHmZpD4yyLwnna6x_mYXh0MVN8M/edit?usp=sharing), which can help get and keep your mind around the structure of the application.

A `Route` is a collection of stops, which are polygons on a map. A `Journey` is an instance of that route which happens at a particular time. A `Journey` can do the route forwards or in reverse. A `Journey` will have a `Vehicle`, which knows how many seats that vehicle had, and a `Supplier` who is the driver of the vehicle.

A `Booking` will definitely have a `Journey`, a `Passenger`, a pickup and a dropoff `Stop` (which is the polygon) and a lat/long of where exactly in that polygon the passenger wants to be picked up/dropped off. The lat/long can either be a predefined `Landmark` of that `Stop`, or a manually selected lat/long.

User Accounts
-------------

Suppliers and Passengers use two completely separate auth systems. Suppliers use a standard Devise setup, whereas Passngers use a custom written auth system using twilio to auth via SMS code.

Reverse Journeys, return bookings
---------------------------------

Probably the most confusing thing about this application is the fact that a journey can do a route in either direction, and a passenger can book a return journey. This gets extra confusing when the two combine. A passenger can book an outward journey which is a route in reverse, but then a return journey which is forwards? Yeah, I know. Just remember: Journeys can be *reversed*, bookings can have a *return* journey.

Timings
-------

To try and keep things flexible during development and not allowing confusing database state from happening, the only datetime stored in the database is a `Journey`'s `start_time`. Everything else, including a booking pickup time and dropoff time is calculated from there in ruby. Each stop has how many minutes it roughly takes to drive from the previous stop (remember: this can be reversed), and this is presented to the passenger as within a 10 minute window.

This keeps things simple in the model layer, but can make doing DB queries based on times a bit difficult/impossible.

Misc
----

The `Booking` model calculates the price, based on number of passengers, distance, promo codes and discounts (bus passes and children)

As routes will be managed centrally (something I *strongly* suggest stays in the future, headaches will ensue otherwise), we have various places where both passengers and suppliers can manually suggest changes to the routes. That's what the \*\_suggestions models and controllers do.

`Supplier` does not necessarily mean Driver. A supplier can be a driver, but it can also be dispatcher or manager of a cab company. The creator of a journey on the system might not be the same person who drives it. Suppliers are grouped, along with the vehicles they own, in `Team`s, and can edit each others vehicles and journeys.

Tests
-----

I'm really so sorry. This project was more of a design project which moved very fast as we user tested as we went, with not much time in between. I tried, but those tests will now be failing. This is therefore clearly not production ready code. I suspect that it could be made production ready with some really boring work though, rather than starting again, but that will be your call.

If you have any questions, contact me: james@abscond.org.