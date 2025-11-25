-- ============================================================================
-- Fontainebleau Las Vegas Intelligence Agent - Cortex Search Service Setup
-- ============================================================================
-- Purpose: Create unstructured data tables and Cortex Search services for
--          guest reviews, hotel policies, and incident reports
-- Syntax verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
-- ============================================================================

USE DATABASE FONTAINEBLEAU_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE FONTAINEBLEAU_WH;

-- ============================================================================
-- Step 1: Create table for guest reviews (unstructured text data)
-- ============================================================================
CREATE OR REPLACE TABLE GUEST_REVIEWS (
    review_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30),
    reservation_id VARCHAR(30),
    review_text VARCHAR(16777216) NOT NULL,
    review_title VARCHAR(500),
    room_type VARCHAR(100),
    rating NUMBER(3,0),
    review_source VARCHAR(50),
    review_date DATE NOT NULL,
    stay_date DATE,
    verified_stay BOOLEAN DEFAULT TRUE,
    helpful_votes NUMBER(8,0) DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id)
);

-- ============================================================================
-- Step 2: Create table for hotel policy documents
-- ============================================================================
CREATE OR REPLACE TABLE HOTEL_POLICIES (
    policy_id VARCHAR(30) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content VARCHAR(16777216) NOT NULL,
    policy_category VARCHAR(50),
    department VARCHAR(50),
    document_number VARCHAR(50),
    revision VARCHAR(20),
    tags VARCHAR(500),
    author VARCHAR(100),
    effective_date DATE,
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Step 3: Create table for incident reports
-- ============================================================================
CREATE OR REPLACE TABLE INCIDENT_REPORTS (
    incident_id VARCHAR(30) PRIMARY KEY,
    feedback_id VARCHAR(30),
    guest_id VARCHAR(30),
    reservation_id VARCHAR(30),
    report_text VARCHAR(16777216) NOT NULL,
    incident_type VARCHAR(50),
    severity VARCHAR(30),
    department VARCHAR(50),
    resolution_status VARCHAR(30),
    resolution_text VARCHAR(5000),
    recommendations VARCHAR(5000),
    incident_date TIMESTAMP_NTZ NOT NULL,
    resolution_date TIMESTAMP_NTZ,
    reported_by VARCHAR(100),
    resolved_by VARCHAR(100),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (feedback_id) REFERENCES GUEST_FEEDBACK(feedback_id),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id)
);

-- ============================================================================
-- Step 4: Enable change tracking (required for Cortex Search)
-- ============================================================================
ALTER TABLE GUEST_REVIEWS SET CHANGE_TRACKING = TRUE;
ALTER TABLE HOTEL_POLICIES SET CHANGE_TRACKING = TRUE;
ALTER TABLE INCIDENT_REPORTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Step 5: Generate sample guest reviews
-- ============================================================================
INSERT INTO GUEST_REVIEWS
SELECT
    'REV' || LPAD(SEQ4(), 10, '0') AS review_id,
    g.guest_id,
    r.reservation_id,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'Absolutely stunning property! From the moment we arrived, the staff made us feel like royalty. The room was immaculate with breathtaking Strip views. The bed was incredibly comfortable - I had the best sleep in years. Papi Steak was outstanding - the wagyu was perfectly prepared. The pool area is gorgeous and the cabanas are worth every penny. LIV Spa was a highlight - my couples massage was pure bliss. The only minor issue was the elevator wait times during peak hours, but honestly, that''s expected in a property this size. Will definitely be back for our anniversary next year. This is now our go-to Vegas hotel. 10/10 would recommend to anyone looking for luxury in Las Vegas.'
        WHEN 1 THEN 'Mixed feelings about our stay. The room itself was beautiful and modern, and housekeeping was impeccable. However, check-in took almost an hour which really soured our arrival. The front desk agent was apologetic but the wait was frustrating after a long flight. Once we got to our room, things improved. The view was amazing and the bathroom was spa-like. We had dinner at Komodo and the food was delicious but quite loud. Room service breakfast the next morning was excellent and arrived hot and on time. The pool was crowded but that''s Vegas in July. Overall a 3.5/5 experience - beautiful hotel but needs to work on check-in efficiency.'
        WHEN 2 THEN 'First time staying at Fontainebleau and WOW! This place is spectacular. The architecture and design are like nothing else on the Strip. Our Junior Suite was spacious with a great living area and the most comfortable bed. The view of the city at night was magical. Highlights: 1) LIV nightclub - amazing energy and production, 2) Breakfast at LIV Restaurant was delicious, 3) The spa facilities are world-class, 4) Staff throughout the property were friendly and professional. Minor notes: parking is expensive ($50/day for self-park), and some areas of the casino felt smoky. But these are minor complaints for an otherwise exceptional experience. Already planning our return trip!'
        WHEN 3 THEN 'Disappointing experience for the price point. Expected more from a luxury property. Room was nice but not $600/night nice. The bathroom had a hair in the tub when we arrived, and while housekeeping came quickly to address it, first impressions matter. The restaurants are beautiful but extremely overpriced - $90 steaks that weren''t even great. Casino floor was nice and dealers were friendly. Pool was the highlight - gorgeous setting and good service. But I''ve stayed at other Strip properties for half the price with similar or better experiences. Wouldn''t return unless rates come down significantly.'
        WHEN 4 THEN 'We celebrated our 25th anniversary here and couldn''t have picked a better spot. The concierge arranged a surprise room upgrade to a Strip-view suite and had champagne and chocolate-covered strawberries waiting. Dinner at La Petite Maison was exquisite - the best French food I''ve had outside Paris. The attention to detail throughout our stay was remarkable. Bellman remembered our names, the bartender at Bleau Bar made excellent craft cocktails, and the spa staff were incredibly attentive during our couples treatment. Worth every penny for a special occasion. Thank you Fontainebleau for making our anniversary unforgettable!'
        WHEN 5 THEN 'Stayed for a business conference and the meeting facilities are exceptional. Our breakout room was well-equipped with AV, great lighting, and comfortable seating. The event staff were professional and accommodating with last-minute requests. Room was quiet despite being close to the casino - great soundproofing. Business center was helpful for printing. Only criticism is the WiFi was spotty during peak hours which was frustrating for work. The hotel should really upgrade their bandwidth for a property catering to business travelers. Food was good, location is convenient. Would recommend for business travel with that WiFi caveat.'
        WHEN 6 THEN 'BEST. BACHELORETTE. PARTY. EVER! Booked a penthouse suite for my sister''s bachelorette and it was insane. The suite was massive - we had 8 girls and plenty of room. Views were incredible for photos. Got bottle service at LIV and they treated us like celebrities. Pool party the next day was so fun - the DJ was great and we made a whole day of it with cabanas. The spa did all our mani-pedis before the wedding and everyone loved it. Only downside was one of our group had her wallet stolen at the pool - security was helpful but nothing recovered. Please watch your belongings! Overall 5 stars for the party experience!'
        WHEN 7 THEN 'Good hotel but not great for families. We brought our two kids (8 and 12) and while the room was nice, there isn''t much for children to do here. The pool has an age restriction after certain hours which was disappointing. No kids club or family activities. The casino smoke drifts into some areas which bothered us. That said, the room was comfortable, breakfast options were good, and the staff were helpful with recommendations for family-friendly activities outside the hotel. If you''re coming with kids, I''d suggest a property more oriented toward families. For adults-only Vegas trip, this would be 5 stars.'
        WHEN 8 THEN 'Room service review: Ordered multiple times during our 4-night stay. Breakfast was always excellent - the eggs Benedict and fresh juices were delicious. Dinner orders were hit or miss. The burger arrived cold once, and another night the steak was overcooked. Prices are high but that''s expected at a luxury property. Delivery times averaged 45 minutes which felt long when hungry. Late-night menu is limited after 2am. Staff were always friendly on the phone and when delivering. Would love to see more consistency in food quality. 3/5 for room service specifically, though the hotel overall was nice.'
        WHEN 9 THEN 'Incredible spa experience at LIV Spa. Booked a half-day package and it was heaven. Started with the steam room and sauna which were pristine and peaceful. My massage therapist Elena was absolutely amazing - best deep tissue I''ve ever had. She found knots I didn''t know I had. The facial afterward was refreshing and my skin looked great for days. The relaxation lounge is beautiful with healthy snacks and tea. Only complaint is the changing areas could be bigger. But the treatments themselves? 10/10. Already booked my next appointment for my return visit. Worth the splurge!'
        WHEN 10 THEN 'Casino experience review: Good variety of table games and slots. Minimums are high ($25 blackjack on weekends) but that''s expected for a new Strip property. Dealers were friendly and professional. Got comped a dinner after a few hours of play which was nice. The high-limit room is beautiful and quieter. Slots seemed tighter than other casinos but that''s subjective. Player''s club benefits seem good - we got upgraded on our second night. Cocktail service was slow on busy nights. Nice smoke-free section near the sports book. Overall solid casino experience, just bring a bigger bankroll than usual.'
        WHEN 11 THEN 'Valet experience was exceptional. Quick drop-off and pickup, car was always ready within 5 minutes of calling. Staff were courteous and careful with our rental. The self-parking garage is huge and can be confusing to navigate - we got lost twice! But the valet made it worth the extra cost. One time they even washed off some bird droppings from our windshield without us asking. Little touches like that make a difference. Highly recommend paying for valet if you''re driving - it''s worth the convenience, especially after a long night at the casino or clubs.'
        WHEN 12 THEN 'Checking out after a 3-night stay. Overall very positive experience. Highlights: the room design is stunning, bed was perfect, Hakkasan exceeded expectations for dinner, pool staff were attentive. Areas for improvement: the gym equipment needs updating (some treadmills were out of order), elevator wait times are too long during peak hours, and coffee in the room was mediocre. At this price point, I''d expect better in-room coffee options. The resort fee is steep but does include good amenities. Would return - just hoping they address some of these details. 4 out of 5 stars.'
        WHEN 13 THEN 'Had an issue with our room AC not working properly on a 110-degree day. Called engineering and they came within 15 minutes and fixed it. Really appreciated the quick response and the manager on duty sent up complimentary drinks as an apology. That kind of service recovery makes all the difference. The rest of our stay was wonderful - the location is great (close to Resorts World and the Convention Center), the bars make excellent cocktails, and the people-watching in the lobby is entertaining. Would definitely stay again. Thanks to the Fontainebleau team for handling our AC issue so professionally!'
        WHEN 14 THEN 'Warning: they will nickel and dime you. Resort fee is $50+, parking is $50, breakfast is $40, coffee is $8. By the time you add it all up, the "deal" room rate means nothing. The hotel itself is gorgeous and new, rooms are modern and clean, but I felt like I was being charged for everything. Even the pool chairs have cabana boys trying to upsell you. If you''re okay with the Vegas premium pricing model, you''ll love it here. If you''re looking for value, look elsewhere. Beautiful property but budget an extra $200-300/day beyond your room rate.'
        WHEN 15 THEN 'Romantic weekend getaway with my husband was perfect! We had a Strip-view King room and the sunset views were breathtaking. Dinner at Papi Steak was incredible - we shared the Tomahawk and it was cooked perfectly. The sommelier recommended an amazing wine pairing. After dinner we enjoyed cocktails at Bleau Bar - intimate setting and skilled bartenders. The next day we relaxed at the pool with champagne service. In-room jacuzzi tub was a nice touch for the evening. Staff made us feel special throughout. This is our new anniversary tradition - see you next year Fontainebleau!'
        WHEN 16 THEN 'Terrible customer service experience at check-in. Waited over an hour, then was told my room wasn''t ready even though it was 5pm. The front desk agent was dismissive and didn''t offer any compensation for the wait. Had to demand to speak to a manager to get a small resort credit. Once in the room, it was nice but the bad taste from check-in lingered. Housekeeping was fine, food was good, pool was nice. But that first impression really colored the whole stay. For the prices they charge, the service should match luxury standards. Training needed for front desk staff.'
        WHEN 17 THEN 'Girls trip was amazing! Stayed in connecting rooms which was perfect for getting ready together. The bathroom mirrors have great lighting for makeup. Pool day was perfect - arrived early to get good loungers. DJ was playing great music and the frozen drinks were delicious (and strong!). Nightlife was incredible - LIV is a must-visit. The hotel is massive so wear comfortable shoes for walking around. Breakfast buffet had tons of options for our group including good vegetarian choices. Only complaint is some areas get very cigarette-y. But overall, best Vegas girls trip yet!'
        WHEN 18 THEN 'Stayed during a medical conference. The convention center attached to the hotel is convenient and well-organized. Appreciated the coffee stations and comfortable seating between sessions. Hotel room was quiet and conducive to rest after long conference days. Walking to sessions from my room took less than 10 minutes. The BLVD Deli was a quick option for lunch between sessions. WiFi held up well in the meeting rooms. Would definitely recommend this property for conference attendees. The location to other strip attractions is also convenient for any free time. Professional environment for a business trip.'
        ELSE 'Great stay overall. Room was clean and modern, staff were helpful, food was good. Pool area is beautiful. Would come back and recommend to friends visiting Vegas. Nice addition to the Strip!'
    END AS review_text,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'Absolutely Stunning - Our New Favorite Vegas Hotel!'
        WHEN 1 THEN 'Beautiful But Check-in Was Rough'
        WHEN 2 THEN 'First Time at Fontainebleau - WOW!'
        WHEN 3 THEN 'Overpriced for What You Get'
        WHEN 4 THEN 'Perfect 25th Anniversary Celebration'
        WHEN 5 THEN 'Great for Business, WiFi Needs Work'
        WHEN 6 THEN 'Best Bachelorette Party Ever!'
        WHEN 7 THEN 'Not Ideal for Families with Kids'
        WHEN 8 THEN 'Room Service Hit or Miss'
        WHEN 9 THEN 'LIV Spa is Heaven'
        WHEN 10 THEN 'Solid Casino Experience'
        WHEN 11 THEN 'Exceptional Valet Service'
        WHEN 12 THEN 'Almost Perfect, Some Minor Issues'
        WHEN 13 THEN 'Great Service Recovery After AC Issue'
        WHEN 14 THEN 'Beautiful But Beware Hidden Costs'
        WHEN 15 THEN 'Romantic Getaway Perfection'
        WHEN 16 THEN 'Disappointing Check-in Experience'
        WHEN 17 THEN 'Amazing Girls Trip!'
        WHEN 18 THEN 'Perfect for Conference Attendees'
        ELSE 'Great Vegas Stay!'
    END AS review_title,
    rt.room_type_name AS room_type,
    CASE WHEN ABS(RANDOM()) % 20 IN (3, 8, 14, 16) THEN UNIFORM(2, 3, RANDOM())
         WHEN ABS(RANDOM()) % 20 IN (1, 7, 12) THEN UNIFORM(3, 4, RANDOM())
         ELSE UNIFORM(4, 5, RANDOM()) END AS rating,
    ARRAY_CONSTRUCT('TRIPADVISOR', 'GOOGLE', 'EXPEDIA', 'BOOKING.COM', 'YELP', 'DIRECT')[UNIFORM(0, 5, RANDOM())] AS review_source,
    DATEADD('day', UNIFORM(1, 14, RANDOM()), r.check_out_date) AS review_date,
    r.check_in_date AS stay_date,
    TRUE AS verified_stay,
    UNIFORM(0, 100, RANDOM()) AS helpful_votes,
    CURRENT_TIMESTAMP() AS created_at
FROM RAW.RESERVATIONS r
JOIN RAW.GUESTS g ON r.guest_id = g.guest_id
JOIN RAW.ROOM_TYPES rt ON r.room_type_id = rt.room_type_id
WHERE r.reservation_status = 'CHECKED_OUT'
  AND UNIFORM(0, 100, RANDOM()) < 15
LIMIT 10000;

-- ============================================================================
-- Step 6: Generate hotel policy documents
-- ============================================================================
INSERT INTO HOTEL_POLICIES VALUES
('POL001', 'Fontainebleau Las Vegas Guest Check-in and Check-out Policy',
$$FONTAINEBLEAU LAS VEGAS
GUEST CHECK-IN AND CHECK-OUT POLICY
Effective Date: January 2025

1. CHECK-IN PROCEDURES

1.1 Standard Check-in Time
Check-in time is 4:00 PM. Guests arriving before this time may check in if rooms are available; however, early check-in is not guaranteed.

1.2 Early Check-in
Early check-in may be requested and is subject to availability:
- Requests can be made at time of booking or upon arrival
- A fee of $75 may apply for guaranteed early check-in
- Loyalty members at Gold tier and above receive complimentary early check-in when available
- VIP guests receive priority for early check-in

1.3 Required Documents
All guests must present:
- Valid government-issued photo ID (passport for international guests)
- Credit card matching the reservation name
- Confirmation number or booking reference

1.4 Age Requirements
- Minimum age for check-in is 21 years
- All guests must be 21 or older to occupy a room
- Photo ID will be verified for all guests

1.5 Deposit and Authorization
- A credit card authorization hold of $150 per night plus incidentals will be placed at check-in
- Cash deposits are accepted but require $300 per night plus a $500 incidental deposit
- Debit cards may be used but require additional authorization amounts

2. CHECK-OUT PROCEDURES

2.1 Standard Check-out Time
Check-out time is 11:00 AM. All guests must vacate rooms by this time to avoid late check-out charges.

2.2 Late Check-out
Late check-out is available upon request:
- Until 1:00 PM: $75 fee
- Until 3:00 PM: Half day rate (50% of room rate)
- After 3:00 PM: Full additional night charge
- Loyalty Platinum members receive complimentary late check-out until 2:00 PM when available

2.3 Express Check-out
- Review your folio on the in-room TV
- Leave key cards in the room
- Charges will be applied to the card on file
- Email confirmation will be sent within 24 hours

2.4 Disputed Charges
- All charge disputes must be made within 30 days of check-out
- Documentation may be required for dispute resolution
- Contact our guest services team at +1-702-555-0100

3. RESERVATION POLICIES

3.1 Guarantee Policy
- All reservations require a valid credit card for guarantee
- First night's room and tax will be charged for no-shows
- Some rate types require full prepayment at booking

3.2 Modification Policy
- Reservations may be modified up to 48 hours before arrival without penalty
- Changes are subject to rate and availability differences
- Prepaid reservations may have different modification terms

4. INCIDENTALS

4.1 Room Charges
Guests may charge the following to their room:
- Restaurant and bar purchases
- Spa services
- Retail purchases
- Pool and cabana services
- In-room dining

4.2 Authorization Limits
- Standard daily limit: $500
- Higher limits available upon request with manager approval
- VIP guests have customized limits based on profile

5. KEY CARD POLICY

5.1 Issuance
- Maximum of 4 key cards per room
- Photo ID required for key card replacement
- Lost cards should be reported immediately to Front Desk

5.2 Access
- Key cards provide access to room, pool areas, and fitness center
- VIP keys provide additional access to exclusive lounges
- Cards are deactivated at check-out time

6. CONTACT INFORMATION

Front Desk: +1-702-555-0100
Concierge: +1-702-555-0101
Guest Services: +1-702-555-0102
Bell Desk: +1-702-555-0103

Policy Version: 2.1
Last Updated: January 2025
Next Review: July 2025
Approved By: Director of Front Office Operations$$,
'FRONT_OFFICE', 'FRONT_OFFICE', 'POL-FO-001', '2.1', 'check-in,check-out,front desk,arrival,departure', 'Front Office Management', '2025-01-01', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('POL002', 'Fontainebleau Las Vegas Cancellation and Refund Policy',
$$FONTAINEBLEAU LAS VEGAS
CANCELLATION AND REFUND POLICY
Effective Date: January 2025

1. STANDARD CANCELLATION POLICY

1.1 General Terms
All reservations may be cancelled without penalty up to 72 hours prior to the scheduled arrival date. Cancellations made within 72 hours of arrival will be charged one night's room rate plus tax.

1.2 Cancellation Deadlines
- Standard Reservations: 72 hours before 4:00 PM on arrival date
- Peak Period Reservations: 7 days before arrival date
- Group Reservations: See group contract terms
- Prepaid/Non-refundable: No cancellations or refunds

1.3 Peak Periods
Peak periods with extended cancellation requirements include:
- New Year's Eve (December 30 - January 2)
- Super Bowl Weekend
- March Madness
- Memorial Day Weekend
- Fourth of July Weekend
- Labor Day Weekend
- Major Conventions (CES, SEMA, etc.)
- Halloween Weekend
- Thanksgiving Weekend

2. REFUND PROCEDURES

2.1 Processing Time
- Refunds to credit cards: 5-10 business days
- Refunds to debit cards: 10-15 business days
- Cash refunds: Issued by check within 14 business days

2.2 Partial Stays
If a guest checks out early:
- Advance purchase rates: No refund for unused nights
- Standard rates: Full charge for committed stay, refund for remaining nights if 24-hour notice given
- Resort fee: Charged per night of actual stay

3. NO-SHOW POLICY

3.1 Charges
Guests who fail to arrive without cancelling will be charged:
- One night's room rate plus tax
- Resort fee for the first night
- Remainder of reservation will be cancelled

3.2 Re-booking
No-show guests wishing to rebook must make a new reservation subject to availability.

4. MODIFICATION POLICY

4.1 Date Changes
- Subject to availability
- Rate may vary based on new dates
- Advance purchase rates cannot be modified

4.2 Room Type Changes
- Upgrades subject to availability and rate difference
- Downgrades allowed with rate adjustment (non-prepaid only)

5. SPECIAL RATE TERMS

5.1 Advance Purchase Rates
- Full payment at time of booking
- No modifications or cancellations
- No refunds under any circumstances
- Non-transferable

5.2 Package Rates
- Components cannot be modified separately
- Cancellation applies to entire package
- Refund includes all package components if eligible

5.3 Group Rates
- Refer to group contract for cancellation terms
- Individual guests: Follow group terms or standard policy
- Attrition penalties may apply

6. EXCEPTION PROCESS

6.1 Force Majeure
Exceptions may be considered for:
- Natural disasters preventing travel
- Government travel restrictions
- Medical emergencies (documentation required)
- Military deployment (orders required)

6.2 Request Process
- Submit exception request in writing to guestservices@fontainebleaulsv.com
- Include booking confirmation and supporting documentation
- Decisions made within 5 business days
- Management discretion applies

7. LOYALTY MEMBER BENEFITS

7.1 Tier Benefits
- Silver: Standard policy
- Gold: 48-hour cancellation window
- Platinum: 24-hour cancellation window, complimentary same-day cancellation once per year

8. CONTACT

Reservations: +1-702-555-0110
Guest Services: +1-702-555-0102
Email: reservations@fontainebleaulsv.com

Policy Version: 1.8
Last Updated: January 2025$$,
'RESERVATIONS', 'REVENUE_MANAGEMENT', 'POL-RES-002', '1.8', 'cancellation,refund,no-show,modification', 'Revenue Management', '2025-01-01', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('POL003', 'Fontainebleau Las Vegas Dining and Food Safety Policy',
$$FONTAINEBLEAU LAS VEGAS
DINING SERVICES AND FOOD SAFETY POLICY
Effective Date: January 2025

1. RESTAURANT RESERVATIONS

1.1 Booking Options
- Online at fontainebleaulsv.com
- Fontainebleau mobile app
- OpenTable (select restaurants)
- Concierge desk
- Phone reservations

1.2 Cancellation
- 4 hours notice for parties of 6 or fewer
- 24 hours notice for parties of 7-12
- 72 hours notice for parties of 13+
- Late cancellations may incur a $25/person fee for premium restaurants

1.3 Waitlist
- Waitlist available via app and host stand
- Estimated wait times provided
- Text notification when table is ready

2. DRESS CODE

2.1 Fine Dining (Papi Steak, Don's Prime, La Petite Maison)
- Business casual to formal attire required
- Gentlemen: Collared shirts, dress shoes (no sneakers, sandals, or shorts)
- Ladies: Cocktail attire or equivalent
- No athletic wear, swimwear, or casual beachwear

2.2 Casual Dining
- Resort casual attire
- Swimwear with cover-ups acceptable at pool venues
- Proper footwear required

2.3 Nightclub (LIV)
- Upscale attire required
- No athletic wear, jerseys, or baggy clothing
- Dress code strictly enforced
- Management discretion applies

3. DIETARY ACCOMMODATIONS

3.1 Allergy Management
- Inform server of all allergies before ordering
- Kitchen staff trained in allergen handling
- Cross-contamination protocols in place
- Allergen menus available upon request

3.2 Special Diets
Our kitchens accommodate:
- Vegetarian and vegan
- Gluten-free
- Kosher (advance notice required)
- Halal (advance notice required)
- Low sodium / heart healthy
- Diabetic-friendly options

4. ROOM SERVICE (IN-ROOM DINING)

4.1 Hours
- Available 24 hours
- Full menu: 6:00 AM - 2:00 AM
- Limited menu: 2:00 AM - 6:00 AM

4.2 Ordering
- In-room tablet
- Phone: Dial 61
- Mobile app

4.3 Delivery
- Standard delivery: 30-45 minutes
- Express delivery available for additional fee
- Delivery fee: $8 per order
- 18% gratuity automatically added

5. FOOD SAFETY

5.1 Hygiene Standards
- All staff SNHD food handler certified
- Temperature monitoring systems in place
- Daily health screenings for food handlers
- Allergen training for all food service staff

5.2 Guest Safety
- Consume delivered food within 2 hours
- Report any food quality concerns immediately
- Medical emergencies: Dial 55 for security/medical

6. PAYMENT

6.1 Accepted Methods
- All major credit cards
- Room charge (hotel guests)
- Cash
- Loyalty points (select locations)
- Comp vouchers

6.2 Automatic Gratuity
- 20% gratuity added for parties of 8 or more
- 20% gratuity added to all banquet orders
- Room service: 18% gratuity included

7. COMP DINING

7.1 Eligibility
- Gaming comps based on play rating
- Loyalty member benefits
- VIP host discretion
- Special promotions

7.2 Redemption
- Present player's card or loyalty ID
- Verify eligibility with server
- Balance applies only to food and non-alcoholic beverages
- Cannot be combined with other offers

8. PRIVATE DINING

8.1 Availability
Private dining available at most venues for:
- Groups of 10-50 guests
- Business meetings
- Special celebrations
- Buyouts for larger parties

8.2 Booking
Contact Events team: +1-702-555-0120
Minimum spend requirements apply

Policy Version: 2.0
Last Updated: January 2025$$,
'FOOD_BEVERAGE', 'FOOD_BEVERAGE', 'POL-FB-003', '2.0', 'dining,restaurants,room service,allergies,reservations', 'Food and Beverage Operations', '2025-01-01', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('POL004', 'LIV Spa Guest Services and Treatment Policy',
$$LIV SPA AT FONTAINEBLEAU LAS VEGAS
SPA GUEST SERVICES AND TREATMENT POLICY
Effective Date: January 2025

1. SPA HOURS AND ACCESS

1.1 Operating Hours
- Spa Services: 9:00 AM - 8:00 PM daily
- Fitness Center: 5:00 AM - 10:00 PM daily
- Pool (weather permitting): 8:00 AM - 6:00 PM

1.2 Age Requirements
- Spa treatments: 18 years and older
- Fitness center: 18 years and older
- Some services available for ages 16-17 with parent present

1.3 Hotel Guest Access
- Spa facility access included in resort fee
- Treatment rooms by appointment only
- Fitness center access with room key

2. APPOINTMENT POLICIES

2.1 Booking
Appointments can be made:
- Phone: +1-702-555-0130
- Mobile app
- Concierge desk
- At the spa reception

2.2 Arrival Time
- Arrive 30-45 minutes before first appointment
- Complete health intake form
- Enjoy steam, sauna, and relaxation areas
- Late arrivals may result in shortened treatment

2.3 Cancellation
- 24 hours notice required for full refund
- Cancellations within 24 hours: 50% charge
- No-shows: Full treatment charge
- Group bookings (4+): 72 hours notice

3. TREATMENT GUIDELINES

3.1 Health Considerations
Please inform your therapist of:
- Pregnancy
- Recent surgeries
- Chronic conditions
- Skin sensitivities
- Injuries or areas to avoid
- Medications affecting treatment

3.2 Massage Pressure
- Communicate pressure preferences
- Speak up during treatment if adjustments needed
- Various techniques available based on needs

3.3 Contraindications
Treatments may not be suitable for guests with:
- Recent surgery (within 6 months in treatment area)
- Active skin conditions or open wounds
- Fever or contagious illness
- High blood pressure (certain treatments)
- Pregnancy (some treatments restricted)

4. SPA ETIQUETTE

4.1 Quiet Environment
- Speak softly in common areas
- Set phones to silent
- Relaxation areas are quiet zones

4.2 Attire
- Robes and slippers provided
- Undergarments worn during treatments (optional for some)
- Proper draping maintained at all times
- Swimwear for co-ed areas

4.3 Valuables
- Lockers provided
- Management not responsible for lost items
- Safe deposit boxes available

5. GRATUITY

5.1 Policy
- Gratuity not included in service prices
- Standard gratuity: 15-20%
- May add to room charge or pay directly
- Gratuity shared with treatment providers

6. PACKAGES AND SPECIAL SERVICES

6.1 Spa Packages
- Multiple treatment packages available
- Must be used in single visit
- Non-transferable
- Subject to availability

6.2 Couples Services
- Couples suite available
- Book both treatments simultaneously
- Special romantic enhancements available

6.3 Bridal Services
- Custom bridal packages
- Group bookings for wedding parties
- Private suite available for larger groups

7. GIFT CARDS

7.1 Purchase
- Available at spa reception
- Online at fontainebleaulsv.com
- Denominations from $100-$5000

7.2 Redemption
- Valid for 3 years from purchase
- May be used for any spa service or retail
- Non-refundable, no cash value

8. RETAIL

8.1 Products
- Professional skincare lines
- Aromatherapy products
- Spa lifestyle accessories
- Products used in treatments available for purchase

8.2 Expert Advice
- Therapists can recommend products
- Skincare consultations available
- Loyalty members receive 10% discount

9. FITNESS CENTER

9.1 Equipment
- State-of-the-art cardio equipment
- Free weights and machines
- Stretching and yoga area
- Peloton bikes

9.2 Personal Training
- Certified trainers available
- Sessions: $150/hour
- Package discounts available

10. CONTACT

LIV Spa Reception: +1-702-555-0130
Fitness Center: +1-702-555-0131
Email: spa@fontainebleaulsv.com

Policy Version: 1.5
Last Updated: January 2025$$,
'SPA', 'SPA_WELLNESS', 'POL-SPA-004', '1.5', 'spa,massage,treatments,wellness,fitness', 'Spa and Wellness Operations', '2025-01-01', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('POL005', 'Fontainebleau Las Vegas Gaming and Player Development Policy',
$$FONTAINEBLEAU LAS VEGAS
GAMING OPERATIONS AND PLAYER DEVELOPMENT POLICY
Effective Date: January 2025

1. CASINO OPERATING HOURS

1.1 Gaming Floor
- Casino open 24 hours, 7 days a week
- Table games: 24 hours
- Slots: 24 hours
- Poker room: 24 hours
- Sports book: Hours vary by sports schedule

1.2 Age Requirement
- Minimum age: 21 years
- Valid ID required for gaming, alcohol, and entry
- Wristbands may be required during peak hours

2. PLAYER DEVELOPMENT PROGRAM

2.1 Tier Structure
Our tiered rewards program offers increasing benefits:

MEMBER (Entry Level)
- Earn 1 point per $5 coin-in on slots
- Earn 1 point per $10 table games buy-in
- Access to member promotions
- Dining discounts

SILVER (5,000 points/year)
- All Member benefits plus:
- Priority check-in
- Increased point earning rate
- Complimentary valet parking

GOLD (25,000 points/year)
- All Silver benefits plus:
- Dedicated host access
- Room upgrade priority
- Premium event invitations
- Expedited comps

PLATINUM (100,000 points/year)
- All Gold benefits plus:
- Personal casino host
- Complimentary suite upgrades
- Private gaming areas
- VIP lounge access
- Exclusive experiences

2.2 Points Earning
- Slot points: Based on coin-in and game denomination
- Table points: Based on average bet and time played
- Points expire after 12 months of inactivity

2.3 Points Redemption
- 100 points = $1 comp dollar
- Redeemable at restaurants, spa, retail
- Room redemption at standard ratios
- Cannot be redeemed for cash

3. COMP PHILOSOPHY

3.1 Evaluation Factors
Comps are calculated based on:
- Average bet
- Time played
- Game type
- Theoretical win
- Overall relationship value

3.2 Comp Types
- Food and beverage
- Room nights
- Spa services
- Entertainment
- Special events
- Airfare (top-tier players)

3.3 Discretionary Comps
- Casino hosts have discretionary authority
- Based on relationship and potential
- Documented in player tracking system

4. TABLE GAMES

4.1 Available Games
- Blackjack
- Baccarat
- Craps
- Roulette
- Pai Gow Poker
- Poker (separate room)
- Specialty games

4.2 Minimums
- Weekday: Starting at $15
- Weekend: Starting at $25
- High limit: $100-$10,000
- Minimums subject to change based on demand

4.3 Markers (Credit)
- Apply in advance through Credit department
- Requires credit check and bank verification
- Minimum line: $5,000
- Interest-free for 30 days

5. SLOTS AND VIDEO POKER

5.1 Denominations
- Penny to high limit ($1,000+)
- Video poker: $.25 to $25
- Progressive jackpots available

5.2 Jackpots
- Tax form required for jackpots $1,200+
- Photo ID required
- Payment methods: Check, cash, or player account

6. RESPONSIBLE GAMING

6.1 Commitment
Fontainebleau is committed to responsible gaming. Resources available:
- Self-exclusion programs
- Limit-setting tools
- Problem gambling resources
- Trained staff awareness

6.2 Self-Exclusion
- Voluntary program available
- Lifetime or limited-term options
- Contact Player Development for information

6.3 Resources
- National Problem Gambling Helpline: 1-800-522-4700
- Nevada Council on Problem Gambling
- On-site responsible gaming information

7. PROMOTIONS

7.1 Slot Tournaments
- Regular tournaments with prize pools
- Entry based on play or tier status
- Calendar available at Players Club

7.2 Table Promotions
- Random drawings
- Hot table bonuses
- Special event promotions

7.3 Terms
- All promotions subject to official rules
- Management decisions final
- Void where prohibited

8. CASINO HOST SERVICES

8.1 Contact
Players Club: +1-702-555-0140
VIP Services: +1-702-555-0141
Email: hosts@fontainebleaulsv.com

8.2 Host Services Include
- Reservation assistance
- Comp arrangement
- Special requests
- Event invitations
- Problem resolution

9. DISPUTE RESOLUTION

9.1 Procedure
- Address issue with floor supervisor
- Escalate to Shift Manager if unresolved
- Written complaints to Gaming Management
- Nevada Gaming Control Board as final recourse

Policy Version: 1.3
Last Updated: January 2025
Nevada Gaming License: [License Number]$$,
'GAMING', 'CASINO_OPERATIONS', 'POL-GAM-005', '1.3', 'casino,gaming,players club,comps,responsible gaming', 'Casino Operations', '2025-01-01', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 7: Generate sample incident reports
-- ============================================================================
INSERT INTO INCIDENT_REPORTS
SELECT
    'INC' || LPAD(SEQ4(), 10, '0') AS incident_id,
    gf.feedback_id,
    gf.guest_id,
    gf.reservation_id,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'INCIDENT REPORT - Room Maintenance Issue' || CHR(10) ||
            'Date: ' || gf.feedback_date::VARCHAR || CHR(10) || CHR(10) ||
            'INCIDENT SUMMARY:' || CHR(10) ||
            'Guest reported that the air conditioning in room was not functioning properly. Temperature in room was approximately 78°F despite thermostat being set to 68°F. Guest called front desk at 2:15 AM after being unable to sleep due to heat.' || CHR(10) || CHR(10) ||
            'INVESTIGATION:' || CHR(10) ||
            'Engineering dispatched within 15 minutes. Technician discovered that the HVAC filter was clogged, restricting airflow. Additionally, the thermostat sensor was reading incorrectly. Both issues were addressed on-site within 45 minutes.' || CHR(10) || CHR(10) ||
            'RESOLUTION:' || CHR(10) ||
            'Filter replaced and thermostat recalibrated. Room temperature normalized within 30 minutes. Guest was offered a late checkout and a complimentary breakfast as a gesture of goodwill. Guest accepted and expressed appreciation for the quick response.' || CHR(10) || CHR(10) ||
            'PREVENTIVE MEASURES:' || CHR(10) ||
            '1. Increased HVAC filter inspection frequency from monthly to bi-weekly' || CHR(10) ||
            '2. Added thermostat calibration check to pre-arrival room inspection' || CHR(10) ||
            '3. Training refresher for housekeeping on identifying potential HVAC issues during cleaning'
        WHEN 1 THEN 'INCIDENT REPORT - Food Allergy Concern' || CHR(10) ||
            'Date: ' || gf.feedback_date::VARCHAR || CHR(10) || CHR(10) ||
            'INCIDENT SUMMARY:' || CHR(10) ||
            'Guest at Komodo restaurant reported receiving a dish containing shellfish despite informing server of a shellfish allergy. Guest did not consume the dish but expressed serious concern about the kitchen''s allergen handling procedures.' || CHR(10) || CHR(10) ||
            'INVESTIGATION:' || CHR(10) ||
            'Restaurant manager immediately met with guest to apologize. Investigation revealed that the allergy notation was entered into POS but not properly communicated to kitchen during a busy service period. The dish was the guest''s appetizer order.' || CHR(10) || CHR(10) ||
            'RESOLUTION:' || CHR(10) ||
            'Entire meal was comped. Executive chef personally met with guest to apologize and assure proper protocols. Guest was satisfied with response and agreed to try a different appetizer prepared with full allergen awareness. Meal proceeded without further incident.' || CHR(10) || CHR(10) ||
            'CORRECTIVE ACTIONS:' || CHR(10) ||
            '1. Implemented verbal confirmation system - servers must verbally confirm allergens with kitchen for every order' || CHR(10) ||
            '2. Added color-coded flags for allergy orders on kitchen display' || CHR(10) ||
            '3. Retraining for all FOH and BOH staff on allergy communication protocols' || CHR(10) ||
            '4. Daily pre-shift allergen awareness briefing implemented'
        WHEN 2 THEN 'INCIDENT REPORT - Housekeeping Service Recovery' || CHR(10) ||
            'Date: ' || gf.feedback_date::VARCHAR || CHR(10) || CHR(10) ||
            'INCIDENT SUMMARY:' || CHR(10) ||
            'Guest returned to room at 4:30 PM to find room had not been cleaned. Guest had left room at 9:00 AM with DND sign removed. No response when guest called housekeeping line.' || CHR(10) || CHR(10) ||
            'INVESTIGATION:' || CHR(10) ||
            'Investigation found that the room was incorrectly marked as "Do Not Disturb" in the housekeeping system, likely due to a data entry error when a nearby room''s DND status was updated. The assigned housekeeper had correctly skipped the room based on system status.' || CHR(10) || CHR(10) ||
            'RESOLUTION:' || CHR(10) ||
            'Housekeeping supervisor personally apologized and expedited cleaning service. Room was cleaned within 30 minutes with priority attention. Guest was offered complimentary turndown service for the remainder of stay plus $100 resort credit for the inconvenience. Guest accepted and appreciated the quick resolution.' || CHR(10) || CHR(10) ||
            'PREVENTIVE MEASURES:' || CHR(10) ||
            '1. Enhanced verification step when updating room status - requires room number confirmation' || CHR(10) ||
            '2. Implemented afternoon sweep where supervisor checks for any rooms that haven''t been serviced by 3:00 PM' || CHR(10) ||
            '3. Added follow-up call process for rooms showing DND past 2:00 PM'
        WHEN 3 THEN 'INCIDENT REPORT - Valet Service Delay' || CHR(10) ||
            'Date: ' || gf.feedback_date::VARCHAR || CHR(10) || CHR(10) ||
            'INCIDENT SUMMARY:' || CHR(10) ||
            'Guest waited 35 minutes for vehicle retrieval despite receiving estimated 10-minute wait. Guest was departing for an important business meeting and was significantly delayed. Guest expressed frustration with valet supervisor.' || CHR(10) || CHR(10) ||
            'INVESTIGATION:' || CHR(10) ||
            'Reviewed valet logs and found that the vehicle was parked in off-site overflow lot due to high occupancy that evening. The valet runner assigned to retrieve the vehicle was delayed by traffic and elevator congestion. Communication to guest about extended wait did not occur.' || CHR(10) || CHR(10) ||
            'RESOLUTION:' || CHR(10) ||
            'Valet supervisor personally apologized and waived all parking charges for the guest''s stay ($150). Manager on duty also met with guest and offered complimentary one-night stay for future visit. Guest missed meeting but appreciated the compensation efforts.' || CHR(10) || CHR(10) ||
            'IMPROVEMENTS IMPLEMENTED:' || CHR(10) ||
            '1. Updated communication protocol - guests now informed immediately if wait exceeds estimate' || CHR(10) ||
            '2. Added secondary runner during peak hours for overflow lot retrievals' || CHR(10) ||
            '3. Implemented priority retrieval system for guests with stated time constraints' || CHR(10) ||
            '4. GPS tracking for runners to provide accurate wait times'
        WHEN 4 THEN 'INCIDENT REPORT - Pool Area Safety Concern' || CHR(10) ||
            'Date: ' || gf.feedback_date::VARCHAR || CHR(10) || CHR(10) ||
            'INCIDENT SUMMARY:' || CHR(10) ||
            'Guest slipped on wet deck near main pool. Guest caught themselves and did not fall but reported the area seemed excessively slippery. No injury occurred but guest concerned about safety for other guests, especially elderly visitors.' || CHR(10) || CHR(10) ||
            'INVESTIGATION:' || CHR(10) ||
            'Pool management immediately inspected the area. Found that a recent resurfacing of deck area had created a smoother finish than original. Combined with pool water splashing, this created a slicker surface than intended. Area was not flagged or marked as requiring caution.' || CHR(10) || CHR(10) ||
            'RESOLUTION:' || CHR(10) ||
            'Guest was thanked for reporting the concern. Area was immediately marked with "Caution - Slippery" signage. Anti-slip mats were placed in high-traffic zones. Guest was offered complimentary cabana rental for the following day as thanks for bringing safety issue to attention.' || CHR(10) || CHR(10) ||
            'CORRECTIVE ACTIONS:' || CHR(10) ||
            '1. Applied anti-slip coating to affected deck areas' || CHR(10) ||
            '2. Increased deck drying rounds during peak pool hours' || CHR(10) ||
            '3. Added permanent non-slip strips at pool entry points' || CHR(10) ||
            '4. Updated resurfacing specifications for future maintenance' || CHR(10) ||
            '5. Safety inspection checklist updated to include slip resistance testing'
        ELSE 'INCIDENT REPORT - Guest Service Issue' || CHR(10) ||
            'Date: ' || gf.feedback_date::VARCHAR || CHR(10) || CHR(10) ||
            'Guest reported service issue during stay. Staff responded promptly and resolved the concern. Documentation completed and appropriate follow-up measures implemented. Guest satisfaction was restored through appropriate compensation and service recovery protocols.'
    END AS report_text,
    ARRAY_CONSTRUCT('MAINTENANCE', 'FOOD_SAFETY', 'HOUSEKEEPING', 'VALET', 'POOL_SAFETY', 'SERVICE', 'SECURITY', 'BILLING')[UNIFORM(0, 7, RANDOM())] AS incident_type,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')[UNIFORM(0, 3, RANDOM())] AS severity,
    gf.department,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'RESOLVED' ELSE 'PENDING' END AS resolution_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'Issue resolved to guest satisfaction. Compensation provided where appropriate. Preventive measures documented.' ELSE NULL END AS resolution_text,
    'Staff retraining, process improvements, and enhanced monitoring implemented' AS recommendations,
    gf.feedback_date AS incident_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN DATEADD('day', UNIFORM(1, 7, RANDOM()), gf.feedback_date) ELSE NULL END AS resolution_date,
    'Guest Relations Team' AS reported_by,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'Department Manager' ELSE NULL END AS resolved_by,
    CURRENT_TIMESTAMP() AS created_at
FROM RAW.GUEST_FEEDBACK gf
WHERE gf.overall_rating <= 3
  AND UNIFORM(0, 100, RANDOM()) < 50
LIMIT 5000;

-- ============================================================================
-- Step 8: Create Cortex Search Service for Guest Reviews
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE GUEST_REVIEWS_SEARCH
  ON review_text
  ATTRIBUTES guest_id, room_type, rating, review_source
  WAREHOUSE = FONTAINEBLEAU_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for guest reviews - enables semantic search across guest feedback'
AS
  SELECT
    review_id,
    review_text,
    review_title,
    guest_id,
    room_type,
    rating,
    review_source,
    review_date,
    stay_date,
    helpful_votes
  FROM GUEST_REVIEWS;

-- ============================================================================
-- Step 9: Create Cortex Search Service for Hotel Policies
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE HOTEL_POLICIES_SEARCH
  ON content
  ATTRIBUTES policy_category, department, title, document_number
  WAREHOUSE = FONTAINEBLEAU_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for hotel policies - enables semantic search across operational policies and guidelines'
AS
  SELECT
    policy_id,
    content,
    title,
    policy_category,
    department,
    document_number,
    revision,
    tags,
    author,
    effective_date
  FROM HOTEL_POLICIES;

-- ============================================================================
-- Step 10: Create Cortex Search Service for Incident Reports
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE INCIDENT_REPORTS_SEARCH
  ON report_text
  ATTRIBUTES incident_type, severity, department, resolution_status
  WAREHOUSE = FONTAINEBLEAU_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for incident investigation reports - enables semantic search across guest incident documentation'
AS
  SELECT
    incident_id,
    report_text,
    feedback_id,
    guest_id,
    incident_type,
    severity,
    department,
    resolution_status,
    resolution_text,
    recommendations,
    incident_date,
    resolution_date,
    reported_by,
    resolved_by
  FROM INCIDENT_REPORTS;

-- ============================================================================
-- Display data generation and search service completion summary
-- ============================================================================
SELECT 'Cortex Search services created successfully' AS status,
       (SELECT COUNT(*) FROM GUEST_REVIEWS) AS guest_reviews,
       (SELECT COUNT(*) FROM HOTEL_POLICIES) AS hotel_policies,
       (SELECT COUNT(*) FROM INCIDENT_REPORTS) AS incident_reports;

