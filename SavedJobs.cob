       *> Epic 6 Part 4: per-user saved/applied job state.
       *> saved-jobs.txt is an append-only event log.  Last S/U
       *> event determines saved state; A tracks applied state.
       SAVED-JOBS-MENU.
           MOVE "N" TO WS-SAVED-MENU-BACK
           PERFORM UNTIL WS-SAVED-MENU-BACK = "Y" OR INPUT-ENDED
               MOVE "--- Saved and Applied Jobs ---"
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               MOVE "1. Save a job by ID" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               MOVE "2. View saved jobs" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               MOVE "3. Unsave a job by ID" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               MOVE "4. Mark a job as applied" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               MOVE "5. View applied jobs" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               MOVE "6. Back to Job Menu" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               MOVE "Enter your choice:" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               PERFORM READ-USER-INPUT
               IF INPUT-ENDED EXIT PERFORM END-IF
               EVALUATE FUNCTION TRIM(WS-USER-INPUT)
                   WHEN "1"
                       MOVE "S" TO WS-REQUESTED-SAVE-EVENT
                       PERFORM CHANGE-JOB-STATE
                   WHEN "2"
                       MOVE "S" TO WS-DISPLAY-SAVE-KIND
                       PERFORM LIST-MY-JOBS
                   WHEN "3"
                       MOVE "U" TO WS-REQUESTED-SAVE-EVENT
                       PERFORM CHANGE-JOB-STATE
                   WHEN "4"
                       MOVE "A" TO WS-REQUESTED-SAVE-EVENT
                       PERFORM CHANGE-JOB-STATE
                   WHEN "5"
                       MOVE "A" TO WS-DISPLAY-SAVE-KIND
                       PERFORM LIST-MY-JOBS
                   WHEN "6"
                       MOVE "Y" TO WS-SAVED-MENU-BACK
                   WHEN OTHER
                       MOVE "Invalid selection." TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE
               END-EVALUATE
           END-PERFORM
           EXIT.

       CHANGE-JOB-STATE.
           MOVE "Enter job ID:" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           PERFORM READ-USER-INPUT
           IF INPUT-ENDED EXIT PARAGRAPH END-IF
           PERFORM PARSE-JOB-ID
           IF WS-JOB-ID-VALID NOT = "Y"
               MOVE "Invalid job ID." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF
           PERFORM FIND-JOB-BY-ID
           IF WS-JOB-FOUND NOT = "Y"
               MOVE "Job ID not found." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF
           PERFORM READ-MY-JOB-STATE
           IF WS-SAVE-IO-ERROR = "Y" EXIT PARAGRAPH END-IF
           EVALUATE WS-REQUESTED-SAVE-EVENT
               WHEN "S"
                   IF WS-JOB-IS-SAVED = "Y"
                       MOVE "Job is already saved." TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE
                       EXIT PARAGRAPH
                   END-IF
               WHEN "U"
                   IF WS-JOB-IS-SAVED NOT = "Y"
                       MOVE "Job is not currently saved."
                           TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE
                       EXIT PARAGRAPH
                   END-IF
               WHEN "A"
                   IF WS-JOB-IS-APPLIED = "Y"
                       MOVE "Job is already marked applied."
                           TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE
                       EXIT PARAGRAPH
                   END-IF
           END-EVALUATE
           PERFORM APPEND-MY-JOB-STATE
           EXIT.

       PARSE-JOB-ID.
           MOVE "N" TO WS-JOB-ID-VALID
           MOVE FUNCTION TRIM(WS-USER-INPUT)
               TO WS-JOB-ID-TEXT
           COMPUTE WS-JOB-ID-LENGTH = FUNCTION LENGTH(
               FUNCTION TRIM(WS-USER-INPUT))
           IF WS-JOB-ID-LENGTH < 1 OR WS-JOB-ID-LENGTH > 6
               EXIT PARAGRAPH
           END-IF
           PERFORM VARYING WS-JOB-ID-INDEX FROM 1 BY 1
               UNTIL WS-JOB-ID-INDEX > WS-JOB-ID-LENGTH
               IF WS-JOB-ID-TEXT(WS-JOB-ID-INDEX:1) < "0"
                   OR WS-JOB-ID-TEXT(WS-JOB-ID-INDEX:1) > "9"
                   EXIT PARAGRAPH
               END-IF
           END-PERFORM
           COMPUTE WS-LOOKUP-JOB-ID =
               FUNCTION NUMVAL(WS-JOB-ID-TEXT)
           IF WS-LOOKUP-JOB-ID > 0
               MOVE "Y" TO WS-JOB-ID-VALID
           END-IF
           EXIT.

       READ-MY-JOB-STATE.
           MOVE "N" TO WS-JOB-IS-SAVED WS-JOB-IS-APPLIED
                       WS-SAVE-IO-ERROR WS-SAVE-READ-ENDED
           OPEN INPUT SAVE-DATA-FILE
           IF WS-SAVE-FILE-STATUS NOT = "00"
               AND WS-SAVE-FILE-STATUS NOT = "05"
               MOVE "Unable to read saved jobs." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               MOVE "Y" TO WS-SAVE-IO-ERROR
               EXIT PARAGRAPH
           END-IF
           PERFORM UNTIL WS-SAVE-READ-ENDED = "Y"
               READ SAVE-DATA-FILE
                   AT END
                       MOVE "Y" TO WS-SAVE-READ-ENDED
                   NOT AT END
                       IF SAVE-RECORD-USER = WS-LOGIN-USERNAME
                           AND SAVE-RECORD-JOB-ID =
                               WS-LOOKUP-JOB-ID
                           EVALUATE SAVE-RECORD-EVENT
                               WHEN "S"
                                   MOVE "Y" TO WS-JOB-IS-SAVED
                               WHEN "U"
                                   MOVE "N" TO WS-JOB-IS-SAVED
                               WHEN "A"
                                   MOVE "Y" TO WS-JOB-IS-APPLIED
                           END-EVALUATE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE SAVE-DATA-FILE
           EXIT.

       APPEND-MY-JOB-STATE.
           OPEN EXTEND SAVE-DATA-FILE
           IF WS-SAVE-FILE-STATUS NOT = "00"
               AND WS-SAVE-FILE-STATUS NOT = "05"
               MOVE "Unable to update saved jobs."
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF
           MOVE WS-LOGIN-USERNAME TO SAVE-RECORD-USER
           MOVE WS-LOOKUP-JOB-ID TO SAVE-RECORD-JOB-ID
           MOVE WS-REQUESTED-SAVE-EVENT TO SAVE-RECORD-EVENT
           WRITE SAVE-DATA-RECORD
           IF WS-SAVE-FILE-STATUS = "00"
               EVALUATE WS-REQUESTED-SAVE-EVENT
                   WHEN "S" MOVE "Job saved." TO WS-MESSAGE
                   WHEN "U" MOVE "Job unsaved." TO WS-MESSAGE
                   WHEN "A" MOVE "Job marked as applied."
                                TO WS-MESSAGE
               END-EVALUATE
           ELSE
               MOVE "Unable to update saved jobs."
                   TO WS-MESSAGE
           END-IF
           CLOSE SAVE-DATA-FILE
           PERFORM WRITE-MESSAGE
           EXIT.

       LIST-MY-JOBS.
           MOVE 0 TO WS-MY-JOB-COUNT
           MOVE "N" TO WS-SAVE-IO-ERROR
           MOVE "N" TO WS-JOB-READ-ENDED
           OPEN INPUT JOB-DATA-FILE
           IF WS-JOB-FILE-STATUS NOT = "00"
               AND WS-JOB-FILE-STATUS NOT = "05"
               MOVE "Unable to read stored jobs." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF
           PERFORM UNTIL WS-JOB-READ-ENDED = "Y"
               READ JOB-DATA-FILE
                   AT END MOVE "Y" TO WS-JOB-READ-ENDED
                   NOT AT END
                       IF JOB-RECORD-ID IS NUMERIC
                           MOVE JOB-RECORD-ID TO WS-LOOKUP-JOB-ID
                           PERFORM READ-MY-JOB-STATE
                           IF WS-SAVE-IO-ERROR = "Y"
                               MOVE "Y" TO WS-JOB-READ-ENDED
                           ELSE
                               EVALUATE WS-DISPLAY-SAVE-KIND
                                   WHEN "S"
                                       IF WS-JOB-IS-SAVED = "Y"
                                           PERFORM DISPLAY-JOB-SUMMARY
                                       END-IF
                                   WHEN "A"
                                       IF WS-JOB-IS-APPLIED = "Y"
                                           PERFORM DISPLAY-JOB-SUMMARY
                                       END-IF
                               END-EVALUATE
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE JOB-DATA-FILE
           IF WS-MY-JOB-COUNT = 0
               AND WS-SAVE-IO-ERROR NOT = "Y"
               IF WS-DISPLAY-SAVE-KIND = "S"
                   MOVE "No saved jobs." TO WS-MESSAGE
               ELSE
                   MOVE "No applied jobs." TO WS-MESSAGE
               END-IF
               PERFORM WRITE-MESSAGE
           END-IF
           EXIT.

       DISPLAY-JOB-SUMMARY.
           ADD 1 TO WS-MY-JOB-COUNT
           MOVE SPACES TO WS-MESSAGE
           STRING "Job #" JOB-RECORD-ID " - "
               FUNCTION TRIM(JOB-RECORD-TITLE)
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
           EXIT.
