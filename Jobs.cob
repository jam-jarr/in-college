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

               MOVE "5. View My Applications" TO WS-MESSAGE
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
                       PERFORM BROWSE-JOBS

                   WHEN "3"
                       MOVE "Y" TO WS-JOB-BACK-SELECTED

                   WHEN "4"
                       PERFORM SAVED-JOBS-MENU

                   WHEN "5"
                       PERFORM VIEW-MY-APPLICATIONS

                   WHEN OTHER
                       MOVE "Invalid selection." TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE

               END-EVALUATE

           END-PERFORM

           EXIT.

       *> Epic 6: browse all posted jobs, view details, and apply.
       BROWSE-JOBS.
           MOVE "N" TO WS-BROWSE-BACK

           PERFORM LOAD-BROWSE-LIST
           IF WS-SAVE-IO-ERROR = "Y"
               EXIT PARAGRAPH
           END-IF

           IF WS-BROWSE-COUNT = 0
               MOVE "No jobs available." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

           PERFORM UNTIL WS-BROWSE-BACK = "Y"
               OR INPUT-ENDED
               PERFORM SHOW-BROWSE-LIST
               PERFORM READ-USER-INPUT
               IF INPUT-ENDED
                   EXIT PERFORM
               END-IF
               IF FUNCTION TRIM(WS-USER-INPUT) = "0"
                   MOVE "Y" TO WS-BROWSE-BACK
               ELSE
                   PERFORM SELECT-BROWSE-JOB
               END-IF
           END-PERFORM
           EXIT.

       *> Reads jobs.txt once into WS-BROWSE-TABLE for the list.
       LOAD-BROWSE-LIST.
           MOVE 0 TO WS-BROWSE-COUNT
           MOVE "N" TO WS-SAVE-IO-ERROR WS-JOB-READ-ENDED

           OPEN INPUT JOB-DATA-FILE
           IF WS-JOB-FILE-STATUS NOT = "00"
               AND WS-JOB-FILE-STATUS NOT = "05"
               MOVE "Unable to read stored jobs." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               MOVE "Y" TO WS-SAVE-IO-ERROR
               EXIT PARAGRAPH
           END-IF

           PERFORM UNTIL WS-JOB-READ-ENDED = "Y"
               READ JOB-DATA-FILE
                   AT END
                       MOVE "Y" TO WS-JOB-READ-ENDED
                   NOT AT END
                       IF JOB-RECORD-ID IS NUMERIC
                           IF WS-BROWSE-COUNT < 1000
                               ADD 1 TO WS-BROWSE-COUNT
                               MOVE WS-BROWSE-COUNT
                                   TO WS-BROWSE-INDEX
                               MOVE JOB-RECORD-ID
                                   TO WS-BROWSE-JOB-ID(WS-BROWSE-INDEX)
                               MOVE JOB-RECORD-TITLE
                                   TO WS-BROWSE-JOB-TITLE(WS-BROWSE-INDEX)
                               MOVE JOB-RECORD-EMPLOYER
                                   TO WS-BROWSE-JOB-EMPLOYER(WS-BROWSE-INDEX)
                               MOVE JOB-RECORD-LOCATION
                                   TO WS-BROWSE-JOB-LOCATION(WS-BROWSE-INDEX)
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE JOB-DATA-FILE
           EXIT.

       *> Prints one numbered summary line per posting.
       SHOW-BROWSE-LIST.
           MOVE "--- All Jobs/Internships ---" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           PERFORM VARYING WS-BROWSE-INDEX FROM 1 BY 1
               UNTIL WS-BROWSE-INDEX > WS-BROWSE-COUNT
               MOVE WS-BROWSE-INDEX TO WS-BROWSE-COUNT-DISPLAY
               MOVE SPACES TO WS-MESSAGE
               STRING
                   FUNCTION TRIM(WS-BROWSE-COUNT-DISPLAY LEADING)
                   ") "
                   FUNCTION TRIM(WS-BROWSE-JOB-TITLE(WS-BROWSE-INDEX))
                   " at "
                   FUNCTION TRIM(WS-BROWSE-JOB-EMPLOYER(WS-BROWSE-INDEX))
                   " ("
                   FUNCTION TRIM(WS-BROWSE-JOB-LOCATION(WS-BROWSE-INDEX))
                   ")"
                   INTO WS-MESSAGE
               END-STRING
               PERFORM WRITE-MESSAGE
           END-PERFORM

           MOVE "0. Back to Job Menu" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           MOVE "Enter your choice:" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           EXIT.

       *> Maps the chosen number to the stored posting and opens it.
       SELECT-BROWSE-JOB.
           PERFORM PARSE-JOB-ID
           IF WS-JOB-ID-VALID NOT = "Y"
               OR WS-LOOKUP-JOB-ID > WS-BROWSE-COUNT
               MOVE "Invalid selection." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-LOOKUP-JOB-ID TO WS-BROWSE-INDEX
           MOVE WS-BROWSE-JOB-ID(WS-BROWSE-INDEX)
               TO WS-SELECTED-JOB-ID
           PERFORM JOB-DETAIL-MENU
           EXIT.

       *> Shows every posting detail; apply or return to the list.
       JOB-DETAIL-MENU.
           MOVE WS-SELECTED-JOB-ID TO WS-LOOKUP-JOB-ID
           PERFORM FIND-JOB-BY-ID
           IF WS-JOB-FOUND NOT = "Y"
               MOVE "Unable to open job posting." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

           MOVE "N" TO WS-DETAIL-DONE
           PERFORM UNTIL WS-DETAIL-DONE = "Y"
               OR INPUT-ENDED
               PERFORM SHOW-JOB-DETAIL
               PERFORM READ-USER-INPUT
               IF INPUT-ENDED
                   EXIT PERFORM
               END-IF
               EVALUATE FUNCTION TRIM(WS-USER-INPUT)
                   WHEN "1"
                       PERFORM APPLY-SELECTED-JOB
                       MOVE "Y" TO WS-DETAIL-DONE
                   WHEN "2"
                       MOVE "Y" TO WS-DETAIL-DONE
                   WHEN OTHER
                       MOVE "Invalid selection." TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE
               END-EVALUATE
           END-PERFORM
           EXIT.

       *> Full posting details (job ID stays internal).
       SHOW-JOB-DETAIL.
           MOVE "--- Job Details ---" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           MOVE SPACES TO WS-MESSAGE
           STRING "Title: " FUNCTION TRIM(JOB-RECORD-TITLE)
               INTO WS-MESSAGE
           END-STRING
           PERFORM WRITE-MESSAGE

           MOVE SPACES TO WS-MESSAGE
           STRING "Description: "
               FUNCTION TRIM(JOB-RECORD-DESCRIPTION)
               INTO WS-MESSAGE
           END-STRING
           PERFORM WRITE-MESSAGE

           MOVE SPACES TO WS-MESSAGE
           STRING "Employer: " FUNCTION TRIM(JOB-RECORD-EMPLOYER)
               INTO WS-MESSAGE
           END-STRING
           PERFORM WRITE-MESSAGE

           MOVE SPACES TO WS-MESSAGE
           STRING "Location: " FUNCTION TRIM(JOB-RECORD-LOCATION)
               INTO WS-MESSAGE
           END-STRING
           PERFORM WRITE-MESSAGE

           IF JOB-RECORD-SALARY IS EQUAL TO SPACES
               CONTINUE
           ELSE
               MOVE SPACES TO WS-MESSAGE
               STRING "Salary: " FUNCTION TRIM(JOB-RECORD-SALARY)
                   INTO WS-MESSAGE
               END-STRING
               PERFORM WRITE-MESSAGE
           END-IF

           MOVE "1. Apply for this job" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           MOVE "2. Back to job list" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           MOVE "Enter your choice:" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           EXIT.

       *> Appends an A event unless already applied.
       APPLY-SELECTED-JOB.
           MOVE WS-SELECTED-JOB-ID TO WS-LOOKUP-JOB-ID
           PERFORM READ-MY-JOB-STATE
           IF WS-SAVE-IO-ERROR = "Y"
               EXIT PARAGRAPH
           END-IF
           IF WS-JOB-IS-APPLIED = "Y"
               MOVE "Job is already marked applied." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF
           MOVE "A" TO WS-REQUESTED-SAVE-EVENT
           PERFORM APPEND-MY-JOB-STATE
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
      
          *> Preserve the original field prompt
          MOVE WS-MESSAGE TO WS-JOB-PROMPT
      
          PERFORM UNTIL WS-JOB-VALID = "Y"
              OR INPUT-ENDED
      
              *> Redisplay the original prompt
              MOVE WS-JOB-PROMPT TO WS-MESSAGE
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
