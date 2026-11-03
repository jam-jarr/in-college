       *> Week 7 - Developer #2: logged-in user's application report.
       *> Applied jobs already persist as A events in saved-jobs.txt.
       VIEW-MY-APPLICATIONS.
           MOVE 0 TO WS-REPORT-COUNT
           MOVE "N" TO WS-JOB-READ-ENDED WS-SAVE-IO-ERROR

           MOVE "--- Your Job Applications ---" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           MOVE SPACES TO WS-MESSAGE
           STRING "Application Summary for "
               FUNCTION TRIM(WS-LOGIN-USERNAME)
               INTO WS-MESSAGE
           END-STRING
           PERFORM WRITE-MESSAGE
           MOVE "------------------------------" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           OPEN INPUT JOB-DATA-FILE
           IF WS-JOB-FILE-STATUS NOT = "00"
               AND WS-JOB-FILE-STATUS NOT = "05"
               MOVE "Unable to read stored jobs." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

           PERFORM UNTIL WS-JOB-READ-ENDED = "Y"
               READ JOB-DATA-FILE
                   AT END
                       MOVE "Y" TO WS-JOB-READ-ENDED
                   NOT AT END
                       IF JOB-RECORD-ID IS NUMERIC
                           MOVE JOB-RECORD-ID TO WS-LOOKUP-JOB-ID
                           PERFORM READ-MY-JOB-STATE
                           IF WS-SAVE-IO-ERROR = "Y"
                               MOVE "Y" TO WS-JOB-READ-ENDED
                           ELSE
                               IF WS-JOB-IS-APPLIED = "Y"
                                   ADD 1 TO WS-REPORT-COUNT
                                   PERFORM WRITE-APPLICATION-DETAIL
                               END-IF
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE JOB-DATA-FILE

           IF WS-SAVE-IO-ERROR = "Y"
               EXIT PARAGRAPH
           END-IF

           IF WS-REPORT-COUNT = 0
               MOVE "No applications found." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
           END-IF
           MOVE WS-REPORT-COUNT TO WS-REPORT-COUNT-DISPLAY
           MOVE SPACES TO WS-MESSAGE
           STRING "Total Applications: "
               FUNCTION TRIM(WS-REPORT-COUNT-DISPLAY LEADING)
               INTO WS-MESSAGE
           END-STRING
           PERFORM WRITE-MESSAGE
           MOVE "------------------------------" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           EXIT.

       WRITE-APPLICATION-DETAIL.
           MOVE SPACES TO WS-MESSAGE
           STRING "Job Title: " FUNCTION TRIM(JOB-RECORD-TITLE)
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

           MOVE "------------------------------" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           EXIT.
