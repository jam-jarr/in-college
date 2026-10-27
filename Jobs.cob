       JOB-MENU.

           MOVE "N" TO WS-JOB-BACK-SELECTED

           PERFORM UNTIL WS-JOB-BACK-SELECTED = "Y"
               OR INPUT-ENDED

               MOVE "--- Job Search/Internship Menu ---"
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "1. Post a Job/Internship" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "2. Browse Jobs/Internships" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "3. Back to Main Menu" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "4. Saved/Applied Jobs" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "Enter your choice:" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               PERFORM READ-USER-INPUT

               IF INPUT-ENDED
                   EXIT PERFORM
               END-IF

               MOVE FUNCTION TRIM(WS-USER-INPUT)
                   TO WS-JOB-CHOICE

               EVALUATE FUNCTION TRIM(WS-USER-INPUT)

                   WHEN "1"
                       PERFORM POST-JOB

                   WHEN "2"
                       MOVE "Browse Jobs/Internships is under construction."
                           TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE

                   WHEN "3"
                       MOVE "Y" TO WS-JOB-BACK-SELECTED

                   WHEN "4"
                       PERFORM SAVED-JOBS-MENU

                   WHEN OTHER
                       MOVE "Invalid selection." TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE

               END-EVALUATE

           END-PERFORM

           EXIT.


       POST-JOB.

           INITIALIZE WS-JOB-TITLE
                      WS-JOB-DESCRIPTION
                      WS-JOB-EMPLOYER
                      WS-JOB-LOCATION
                      WS-JOB-SALARY

           MOVE "N" TO WS-JOB-INPUT-COMPLETE

           MOVE "--- Post a New Job/Internship ---"
               TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           MOVE "Enter Job Title:" TO WS-MESSAGE
           MOVE 50 TO WS-JOB-MAX-LENGTH
           PERFORM READ-REQUIRED-JOB-FIELD

           IF INPUT-ENDED EXIT PARAGRAPH END-IF

           MOVE FUNCTION TRIM(WS-USER-INPUT)
               TO WS-JOB-TITLE

           MOVE "Enter Description (max 200 chars):"
               TO WS-MESSAGE
           MOVE 200 TO WS-JOB-MAX-LENGTH
           PERFORM READ-REQUIRED-JOB-FIELD

           IF INPUT-ENDED EXIT PARAGRAPH END-IF

           MOVE FUNCTION TRIM(WS-USER-INPUT)
               TO WS-JOB-DESCRIPTION

           MOVE "Enter Employer Name:" TO WS-MESSAGE
           MOVE 50 TO WS-JOB-MAX-LENGTH
           PERFORM READ-REQUIRED-JOB-FIELD

           IF INPUT-ENDED EXIT PARAGRAPH END-IF

           MOVE FUNCTION TRIM(WS-USER-INPUT)
               TO WS-JOB-EMPLOYER

           MOVE "Enter Location:" TO WS-MESSAGE
           MOVE 50 TO WS-JOB-MAX-LENGTH
           PERFORM READ-REQUIRED-JOB-FIELD

           IF INPUT-ENDED EXIT PARAGRAPH END-IF

           MOVE FUNCTION TRIM(WS-USER-INPUT)
               TO WS-JOB-LOCATION

           MOVE "Enter Salary (optional, enter 'NONE' to skip):"
               TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           PERFORM READ-USER-INPUT

           IF INPUT-ENDED EXIT PARAGRAPH END-IF

           PERFORM UNTIL INPUT-ENDED
               MOVE FUNCTION LENGTH(
                   FUNCTION TRIM(WS-USER-INPUT)
               ) TO WS-JOB-FIELD-LENGTH

               IF WS-JOB-FIELD-LENGTH <= 40
                   EXIT PERFORM
               END-IF

               MOVE "Salary must be 40 characters or fewer."
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "Enter Salary (optional, enter 'NONE' to skip):"
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               PERFORM READ-USER-INPUT
           END-PERFORM

           IF INPUT-ENDED EXIT PARAGRAPH END-IF

           IF FUNCTION UPPER-CASE(
               FUNCTION TRIM(WS-USER-INPUT)) = "NONE"
               OR FUNCTION TRIM(WS-USER-INPUT) = SPACES

               MOVE SPACES TO WS-JOB-SALARY
           ELSE
               MOVE FUNCTION TRIM(WS-USER-INPUT)
                   TO WS-JOB-SALARY
           END-IF

           MOVE "Y" TO WS-JOB-INPUT-COMPLETE

           PERFORM STORE-POSTED-JOB

           EXIT.


       READ-REQUIRED-JOB-FIELD.

           MOVE "N" TO WS-JOB-VALID

           PERFORM UNTIL WS-JOB-VALID = "Y"
               OR INPUT-ENDED

               PERFORM WRITE-MESSAGE
               PERFORM READ-USER-INPUT

               IF INPUT-ENDED
                   EXIT PERFORM
               END-IF

               MOVE FUNCTION LENGTH(
                   FUNCTION TRIM(WS-USER-INPUT)
               ) TO WS-JOB-FIELD-LENGTH

               EVALUATE TRUE

                   WHEN WS-JOB-FIELD-LENGTH = 0
                       MOVE "This field is required."
                           TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE

                   WHEN WS-JOB-FIELD-LENGTH > WS-JOB-MAX-LENGTH
                       MOVE "Input exceeds the maximum length."
                           TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE

                   WHEN OTHER
                       MOVE "Y" TO WS-JOB-VALID

               END-EVALUATE

           END-PERFORM

           EXIT.
