--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bookings (
    id integer NOT NULL,
    journey_id integer,
    pickup_stop_id integer,
    pickup_lat double precision,
    pickup_lng double precision,
    dropoff_stop_id integer,
    dropoff_lat double precision,
    dropoff_lng double precision,
    state character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    passenger_id integer,
    phone_number character varying,
    pickup_name character varying,
    dropoff_name character varying,
    return_journey_id integer,
    number_of_passengers integer DEFAULT 1,
    special_requirements text,
    child_tickets integer DEFAULT 0,
    older_bus_passes integer DEFAULT 0,
    disabled_bus_passes integer DEFAULT 0,
    scholar_bus_passes integer DEFAULT 0,
    promo_code_id integer,
    passenger_name character varying,
    payment_method character varying DEFAULT 'cash'::character varying
);


--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bookings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bookings_id_seq OWNED BY bookings.id;


--
-- Name: journeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE journeys (
    id integer NOT NULL,
    route_id integer,
    start_time timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    vehicle_id integer,
    supplier_id integer,
    open_to_bookings boolean DEFAULT true,
    reversed boolean,
    booked boolean DEFAULT false
);


--
-- Name: journeys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE journeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE journeys_id_seq OWNED BY journeys.id;


--
-- Name: landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE landmarks (
    id integer NOT NULL,
    name character varying,
    latitude double precision,
    longitude double precision,
    stop_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE landmarks_id_seq OWNED BY landmarks.id;


--
-- Name: passengers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE passengers (
    id integer NOT NULL,
    phone_number character varying,
    verification_code character varying,
    verification_code_generated_at timestamp without time zone,
    verified boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    photo_file_name character varying,
    photo_content_type character varying,
    photo_file_size integer,
    photo_updated_at timestamp without time zone,
    name character varying,
    authentication_token character varying(30),
    session_token character varying(40)
);


--
-- Name: passengers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE passengers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: passengers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE passengers_id_seq OWNED BY passengers.id;


--
-- Name: promo_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE promo_codes (
    id integer NOT NULL,
    price_deduction numeric,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promo_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE promo_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promo_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE promo_codes_id_seq OWNED BY promo_codes.id;


--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    job_id bigint NOT NULL,
    job_class text NOT NULL,
    args json DEFAULT '[]'::json NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error text,
    queue text DEFAULT ''::text NOT NULL
);


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE que_jobs IS '3';


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE que_jobs_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE que_jobs_job_id_seq OWNED BY que_jobs.job_id;


--
-- Name: routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE routes (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE routes_id_seq OWNED BY routes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stops (
    id integer NOT NULL,
    name character varying,
    route_id integer,
    latitude double precision,
    longitude double precision,
    polygon json,
    "position" integer,
    minutes_from_last_stop integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stops_id_seq OWNED BY stops.id;


--
-- Name: suggested_edit_to_stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE suggested_edit_to_stops (
    id integer NOT NULL,
    passenger_id integer,
    stop_id integer,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: suggested_edit_to_stops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE suggested_edit_to_stops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suggested_edit_to_stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE suggested_edit_to_stops_id_seq OWNED BY suggested_edit_to_stops.id;


--
-- Name: suggested_journeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE suggested_journeys (
    id integer NOT NULL,
    passenger_id integer,
    route_id integer,
    start_time timestamp without time zone,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    booking_id integer
);


--
-- Name: suggested_journeys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE suggested_journeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suggested_journeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE suggested_journeys_id_seq OWNED BY suggested_journeys.id;


--
-- Name: suggested_routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE suggested_routes (
    id integer NOT NULL,
    passenger_id integer,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: suggested_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE suggested_routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suggested_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE suggested_routes_id_seq OWNED BY suggested_routes.id;


--
-- Name: supplier_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE supplier_suggestions (
    id integer NOT NULL,
    supplier_id integer,
    url character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: supplier_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE supplier_suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplier_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE supplier_suggestions_id_seq OWNED BY supplier_suggestions.id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE suppliers (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    team_id integer,
    name character varying,
    phone_number character varying,
    admin boolean,
    approved boolean DEFAULT false NOT NULL,
    photo_file_name character varying,
    photo_content_type character varying,
    photo_file_size integer,
    photo_updated_at timestamp without time zone
);


--
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE suppliers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE suppliers_id_seq OWNED BY suppliers.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE teams (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE teams_id_seq OWNED BY teams.id;


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vehicles (
    id integer NOT NULL,
    team_id integer,
    seats integer,
    registration character varying,
    make_model character varying,
    colour character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    wheelchair_accessible boolean,
    photo_file_name character varying,
    photo_content_type character varying,
    photo_file_size integer,
    photo_updated_at timestamp without time zone
);


--
-- Name: vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vehicles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vehicles_id_seq OWNED BY vehicles.id;


--
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookings ALTER COLUMN id SET DEFAULT nextval('bookings_id_seq'::regclass);


--
-- Name: journeys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY journeys ALTER COLUMN id SET DEFAULT nextval('journeys_id_seq'::regclass);


--
-- Name: landmarks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY landmarks ALTER COLUMN id SET DEFAULT nextval('landmarks_id_seq'::regclass);


--
-- Name: passengers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY passengers ALTER COLUMN id SET DEFAULT nextval('passengers_id_seq'::regclass);


--
-- Name: promo_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY promo_codes ALTER COLUMN id SET DEFAULT nextval('promo_codes_id_seq'::regclass);


--
-- Name: que_jobs job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs ALTER COLUMN job_id SET DEFAULT nextval('que_jobs_job_id_seq'::regclass);


--
-- Name: routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY routes ALTER COLUMN id SET DEFAULT nextval('routes_id_seq'::regclass);


--
-- Name: stops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stops ALTER COLUMN id SET DEFAULT nextval('stops_id_seq'::regclass);


--
-- Name: suggested_edit_to_stops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_edit_to_stops ALTER COLUMN id SET DEFAULT nextval('suggested_edit_to_stops_id_seq'::regclass);


--
-- Name: suggested_journeys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_journeys ALTER COLUMN id SET DEFAULT nextval('suggested_journeys_id_seq'::regclass);


--
-- Name: suggested_routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_routes ALTER COLUMN id SET DEFAULT nextval('suggested_routes_id_seq'::regclass);


--
-- Name: supplier_suggestions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY supplier_suggestions ALTER COLUMN id SET DEFAULT nextval('supplier_suggestions_id_seq'::regclass);


--
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY suppliers ALTER COLUMN id SET DEFAULT nextval('suppliers_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams ALTER COLUMN id SET DEFAULT nextval('teams_id_seq'::regclass);


--
-- Name: vehicles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicles ALTER COLUMN id SET DEFAULT nextval('vehicles_id_seq'::regclass);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: journeys journeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY journeys
    ADD CONSTRAINT journeys_pkey PRIMARY KEY (id);


--
-- Name: landmarks landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landmarks
    ADD CONSTRAINT landmarks_pkey PRIMARY KEY (id);


--
-- Name: passengers passengers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY passengers
    ADD CONSTRAINT passengers_pkey PRIMARY KEY (id);


--
-- Name: promo_codes promo_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY promo_codes
    ADD CONSTRAINT promo_codes_pkey PRIMARY KEY (id);


--
-- Name: que_jobs que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: stops stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stops
    ADD CONSTRAINT stops_pkey PRIMARY KEY (id);


--
-- Name: suggested_edit_to_stops suggested_edit_to_stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_edit_to_stops
    ADD CONSTRAINT suggested_edit_to_stops_pkey PRIMARY KEY (id);


--
-- Name: suggested_journeys suggested_journeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_journeys
    ADD CONSTRAINT suggested_journeys_pkey PRIMARY KEY (id);


--
-- Name: suggested_routes suggested_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_routes
    ADD CONSTRAINT suggested_routes_pkey PRIMARY KEY (id);


--
-- Name: supplier_suggestions supplier_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supplier_suggestions
    ADD CONSTRAINT supplier_suggestions_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: index_bookings_on_dropoff_stop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_dropoff_stop_id ON bookings USING btree (dropoff_stop_id);


--
-- Name: index_bookings_on_journey_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_journey_id ON bookings USING btree (journey_id);


--
-- Name: index_bookings_on_passenger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_passenger_id ON bookings USING btree (passenger_id);


--
-- Name: index_bookings_on_pickup_stop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_pickup_stop_id ON bookings USING btree (pickup_stop_id);


--
-- Name: index_bookings_on_promo_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_promo_code_id ON bookings USING btree (promo_code_id);


--
-- Name: index_journeys_on_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journeys_on_route_id ON journeys USING btree (route_id);


--
-- Name: index_journeys_on_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journeys_on_supplier_id ON journeys USING btree (supplier_id);


--
-- Name: index_journeys_on_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journeys_on_vehicle_id ON journeys USING btree (vehicle_id);


--
-- Name: index_landmarks_on_stop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmarks_on_stop_id ON landmarks USING btree (stop_id);


--
-- Name: index_passengers_on_authentication_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_passengers_on_authentication_token ON passengers USING btree (authentication_token);


--
-- Name: index_passengers_on_session_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_passengers_on_session_token ON passengers USING btree (session_token);


--
-- Name: index_stops_on_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stops_on_route_id ON stops USING btree (route_id);


--
-- Name: index_suggested_edit_to_stops_on_passenger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suggested_edit_to_stops_on_passenger_id ON suggested_edit_to_stops USING btree (passenger_id);


--
-- Name: index_suggested_edit_to_stops_on_stop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suggested_edit_to_stops_on_stop_id ON suggested_edit_to_stops USING btree (stop_id);


--
-- Name: index_suggested_journeys_on_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suggested_journeys_on_booking_id ON suggested_journeys USING btree (booking_id);


--
-- Name: index_suggested_journeys_on_passenger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suggested_journeys_on_passenger_id ON suggested_journeys USING btree (passenger_id);


--
-- Name: index_suggested_journeys_on_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suggested_journeys_on_route_id ON suggested_journeys USING btree (route_id);


--
-- Name: index_suggested_routes_on_passenger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suggested_routes_on_passenger_id ON suggested_routes USING btree (passenger_id);


--
-- Name: index_supplier_suggestions_on_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_supplier_suggestions_on_supplier_id ON supplier_suggestions USING btree (supplier_id);


--
-- Name: index_suppliers_on_approved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suppliers_on_approved ON suppliers USING btree (approved);


--
-- Name: index_suppliers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_suppliers_on_email ON suppliers USING btree (email);


--
-- Name: index_suppliers_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_suppliers_on_reset_password_token ON suppliers USING btree (reset_password_token);


--
-- Name: index_suppliers_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suppliers_on_team_id ON suppliers USING btree (team_id);


--
-- Name: index_vehicles_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_team_id ON vehicles USING btree (team_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: suggested_routes fk_rails_12f83e8967; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_routes
    ADD CONSTRAINT fk_rails_12f83e8967 FOREIGN KEY (passenger_id) REFERENCES passengers(id);


--
-- Name: bookings fk_rails_1acaea9c46; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_rails_1acaea9c46 FOREIGN KEY (pickup_stop_id) REFERENCES stops(id);


--
-- Name: journeys fk_rails_25c20fde60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY journeys
    ADD CONSTRAINT fk_rails_25c20fde60 FOREIGN KEY (supplier_id) REFERENCES suppliers(id);


--
-- Name: supplier_suggestions fk_rails_40f708853d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supplier_suggestions
    ADD CONSTRAINT fk_rails_40f708853d FOREIGN KEY (supplier_id) REFERENCES suppliers(id);


--
-- Name: suggested_edit_to_stops fk_rails_4c0c4f6451; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_edit_to_stops
    ADD CONSTRAINT fk_rails_4c0c4f6451 FOREIGN KEY (stop_id) REFERENCES stops(id);


--
-- Name: suggested_journeys fk_rails_592c266385; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_journeys
    ADD CONSTRAINT fk_rails_592c266385 FOREIGN KEY (route_id) REFERENCES routes(id);


--
-- Name: journeys fk_rails_5cf8b6bee7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY journeys
    ADD CONSTRAINT fk_rails_5cf8b6bee7 FOREIGN KEY (vehicle_id) REFERENCES vehicles(id);


--
-- Name: bookings fk_rails_5f0091cc1c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_rails_5f0091cc1c FOREIGN KEY (passenger_id) REFERENCES passengers(id);


--
-- Name: bookings fk_rails_77abaa12e8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_rails_77abaa12e8 FOREIGN KEY (journey_id) REFERENCES journeys(id);


--
-- Name: landmarks fk_rails_81a60f9403; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landmarks
    ADD CONSTRAINT fk_rails_81a60f9403 FOREIGN KEY (stop_id) REFERENCES stops(id);


--
-- Name: vehicles fk_rails_8b6303dec0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicles
    ADD CONSTRAINT fk_rails_8b6303dec0 FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: journeys fk_rails_8f09480e40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY journeys
    ADD CONSTRAINT fk_rails_8f09480e40 FOREIGN KEY (route_id) REFERENCES routes(id);


--
-- Name: stops fk_rails_9068ac2767; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stops
    ADD CONSTRAINT fk_rails_9068ac2767 FOREIGN KEY (route_id) REFERENCES routes(id);


--
-- Name: bookings fk_rails_98500de4dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_rails_98500de4dd FOREIGN KEY (dropoff_stop_id) REFERENCES stops(id);


--
-- Name: bookings fk_rails_a165714cf4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_rails_a165714cf4 FOREIGN KEY (promo_code_id) REFERENCES promo_codes(id);


--
-- Name: suggested_edit_to_stops fk_rails_a20978158f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_edit_to_stops
    ADD CONSTRAINT fk_rails_a20978158f FOREIGN KEY (passenger_id) REFERENCES passengers(id);


--
-- Name: suggested_journeys fk_rails_a49e372a95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggested_journeys
    ADD CONSTRAINT fk_rails_a49e372a95 FOREIGN KEY (passenger_id) REFERENCES passengers(id);


--
-- Name: suppliers fk_rails_b2bbf87303; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suppliers
    ADD CONSTRAINT fk_rails_b2bbf87303 FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20160708134355');

INSERT INTO schema_migrations (version) VALUES ('20160708140119');

INSERT INTO schema_migrations (version) VALUES ('20160713094021');

INSERT INTO schema_migrations (version) VALUES ('20160714132525');

INSERT INTO schema_migrations (version) VALUES ('20160721132455');

INSERT INTO schema_migrations (version) VALUES ('20160727085530');

INSERT INTO schema_migrations (version) VALUES ('20160727085555');

INSERT INTO schema_migrations (version) VALUES ('20160727090257');

INSERT INTO schema_migrations (version) VALUES ('20160727100346');

INSERT INTO schema_migrations (version) VALUES ('20160727104127');

INSERT INTO schema_migrations (version) VALUES ('20160727132115');

INSERT INTO schema_migrations (version) VALUES ('20160802123430');

INSERT INTO schema_migrations (version) VALUES ('20160802141352');

INSERT INTO schema_migrations (version) VALUES ('20160804154148');

INSERT INTO schema_migrations (version) VALUES ('20160804170632');

INSERT INTO schema_migrations (version) VALUES ('20160809144612');

INSERT INTO schema_migrations (version) VALUES ('20160810132356');

INSERT INTO schema_migrations (version) VALUES ('20160810135407');

INSERT INTO schema_migrations (version) VALUES ('20160811101116');

INSERT INTO schema_migrations (version) VALUES ('20160811123846');

INSERT INTO schema_migrations (version) VALUES ('20160811125514');

INSERT INTO schema_migrations (version) VALUES ('20160811130239');

INSERT INTO schema_migrations (version) VALUES ('20160811142509');

INSERT INTO schema_migrations (version) VALUES ('20160811144445');

INSERT INTO schema_migrations (version) VALUES ('20160817114126');

INSERT INTO schema_migrations (version) VALUES ('20160817114331');

INSERT INTO schema_migrations (version) VALUES ('20161005112603');

INSERT INTO schema_migrations (version) VALUES ('20161005142428');

INSERT INTO schema_migrations (version) VALUES ('20161012101612');

INSERT INTO schema_migrations (version) VALUES ('20161012133024');

INSERT INTO schema_migrations (version) VALUES ('20161012153240');

INSERT INTO schema_migrations (version) VALUES ('20161013091503');

INSERT INTO schema_migrations (version) VALUES ('20161013105352');

INSERT INTO schema_migrations (version) VALUES ('20161013145526');

INSERT INTO schema_migrations (version) VALUES ('20161013152339');

INSERT INTO schema_migrations (version) VALUES ('20161018100958');

INSERT INTO schema_migrations (version) VALUES ('20161122163045');

INSERT INTO schema_migrations (version) VALUES ('20161207095335');

INSERT INTO schema_migrations (version) VALUES ('20161220161010');

INSERT INTO schema_migrations (version) VALUES ('20170710160759');

INSERT INTO schema_migrations (version) VALUES ('20170711125411');

INSERT INTO schema_migrations (version) VALUES ('20170712092230');

INSERT INTO schema_migrations (version) VALUES ('20170712111051');

INSERT INTO schema_migrations (version) VALUES ('20170718094200');

INSERT INTO schema_migrations (version) VALUES ('20170726154635');

