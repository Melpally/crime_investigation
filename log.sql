-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Read the crime scene report about the theft
SELECT *
  FROM crime_scene_reports
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND street = "Humphrey Street";

-- We know the time and the destination the theft took place and there are witnesses. Read the transcripts of the interviews

SELECT transcript
  FROM interviews
 WHERE day = 28
   AND month = 7
   AND transcript LIKE "%bakery%";

-- The witnesses mention the car, the ATM and the phone call to arrange the flight

-- First we check the license plate number of the thief from the parking lot

SELECT license_plate, hour, minute
  FROM bakery_security_logs
 WHERE activity = "exit"
   AND year = 2021
   AND month = 7
   AND day = 28
ORDER BY hour ASC;

-- we need to check his bank account number from ATMs

SELECT account_number, amount
  FROM atm_transactions
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND atm_location = "Leggett Street"
   AND transaction_type = "withdraw"
ORDER BY amount ASC;


-- Since we know that the thief is planning to take the earliest flight from the city, we might assume that the thief would have withdrawn a larger amount of money
-- Therefore we take the biggest sums of money and check them

SELECT person_id
  FROM bank_accounts
 WHERE account_number
    IN (
        SELECT account_number
          FROM atm_transactions
          WHERE year = 2021
            AND month = 7
            AND day = 28
            AND atm_location = "Leggett Street"
            AND transaction_type = "withdraw"
        );


-- We put everything into one big query. We found the passport numbers of the suspects, now we can check which ones of them were on the plane
SELECT passport_number
  FROM people
 WHERE id
    IN (
        SELECT person_id
          FROM bank_accounts
         WHERE account_number
            IN (
                SELECT account_number
                  FROM atm_transactions
                WHERE year = 2021
                  AND month = 7
                  AND day = 28
                  AND atm_location = "Leggett Street"
                  AND transaction_type = "withdraw"
                )
      )
      AND license_plate
       IN (
            SELECT license_plate
              FROM bakery_security_logs
             WHERE activity = "exit"
               AND year = 2021
               AND month = 7
               AND day = 28
               AND hour = 10
               AND (minute > 15 AND minute < 25)
          );

 -- Now we can find where the thief has headed.

SELECT id, origin_airport_id, destination_airport_id, hour, minute
  FROM flights
 WHERE year = 2021
   AND month = 7
   AND day = 29
   AND origin_airport_id = (SELECT id
                              FROM airports
                             WHERE city = "Fiftyville")
ORDER BY hour ASC;

-- We found the id of the earliest flight from the Fiftyville and we will find where it goes

SELECT city, full_name
  FROM airports
 WHERE id = 4;

SELECT name
  FROM people
 WHERE passport_number
    IN (
        SELECT passport_number
          FROM passengers
         WHERE flight_id = 36
       )
    AND id
     IN (
          SELECT person_id
            FROM bank_accounts
          WHERE account_number
              IN (
                  SELECT account_number
                    FROM atm_transactions
                  WHERE year = 2021
                    AND month = 7
                    AND day = 28
                    AND atm_location = "Leggett Street"
                    AND transaction_type = "withdraw"
                  )
        )
        AND license_plate
        IN (
              SELECT license_plate
                FROM bakery_security_logs
              WHERE activity = "exit"
                AND year = 2021
                AND month = 7
                AND day = 28
                AND hour = 10
                AND (minute > 15 AND minute < 25)
            );


-- Now we find his accomplice

SELECT caller, receiver, duration
  FROM phone_calls
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND caller
    IN (
        SELECT phone_number
          FROM people
         WHERE passport_number
            IN (
                SELECT passport_number
                  FROM passengers
                WHERE flight_id = 36
              )
            AND id
            IN (
                  SELECT person_id
                    FROM bank_accounts
                  WHERE account_number
                      IN (
                        SELECT account_number
                          FROM atm_transactions
                          WHERE year = 2021
                            AND month = 7
                            AND day = 28
                            AND atm_location = "Leggett Street"
                            AND transaction_type = "withdraw"
                          )
                )
            AND license_plate
            IN (
                SELECT license_plate
                  FROM bakery_security_logs
                  WHERE activity = "exit"
                    AND year = 2021
                    AND month = 7
                    AND day = 28
                    AND hour = 10
                    AND (minute > 15 AND minute < 25)
                )
          )
ORDER BY duration;

-- Apparently, only one person has made calls. We can track down who he is by his phone number

SELECT name
  FROM people
 WHERE phone_number = "(367) 555-5533";

-- We found the thief. His name is Bruce. WHo is his accomplice? The person he talked to for 45 seconds

SELECT name
  FROM people
 WHERE phone_number = "(375) 555-8161";

 -- The accomplice is Robin and Bruce is headed to New York city, LaGuardia airport

