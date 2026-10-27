       *> Epic 6 Part 3: job posting persistence.
       *> Jobs are written to jobs.txt as fixed-width line records.
       STORE-POSTED-JOB.
           MOVE 1 TO WS-NEXT-JOB-ID
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
                   AT END
                       MOVE "Y" TO WS-JOB-READ-ENDED
                   NOT AT END
                       IF JOB-RECORD-ID IS NUMERIC
                           IF JOB-RECORD-ID >= WS-NEXT-JOB-ID
                               COMPUTE WS-NEXT-JOB-ID =
                                   JOB-RECORD-ID + 1
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE JOB-DATA-FILE

           IF WS-NEXT-JOB-ID > 999999
               MOVE "Maximum job ID reached." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

           OPEN EXTEND JOB-DATA-FILE
           IF WS-JOB-FILE-STATUS NOT = "00"
               AND WS-JOB-FILE-STATUS NOT = "05"
               MOVE "Unable to save job posting." TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

           INITIALIZE JOB-DATA-RECORD
           MOVE WS-NEXT-JOB-ID TO JOB-RECORD-ID
           MOVE WS-LOGIN-USERNAME TO JOB-RECORD-POSTER
           MOVE WS-JOB-TITLE TO JOB-RECORD-TITLE
           MOVE WS-JOB-DESCRIPTION TO JOB-RECORD-DESCRIPTION
           MOVE WS-JOB-EMPLOYER TO JOB-RECORD-EMPLOYER
           MOVE WS-JOB-LOCATION TO JOB-RECORD-LOCATION
           MOVE WS-JOB-SALARY TO JOB-RECORD-SALARY
           WRITE JOB-DATA-RECORD
           IF WS-JOB-FILE-STATUS = "00"
               MOVE SPACES TO WS-MESSAGE
               STRING "Job posted successfully! ID: "
                   JOB-RECORD-ID
                   INTO WS-MESSAGE
               END-STRING
           ELSE
               MOVE "Unable to save job posting." TO WS-MESSAGE
           END-IF
           CLOSE JOB-DATA-FILE
           PERFORM WRITE-MESSAGE
           EXIT.

       *> Loads a posting by numeric WS-LOOKUP-JOB-ID.
       *> JOB-DATA-RECORD retains the matching contents on return.
       FIND-JOB-BY-ID.
           MOVE "N" TO WS-JOB-FOUND WS-JOB-READ-ENDED
           OPEN INPUT JOB-DATA-FILE
           IF WS-JOB-FILE-STATUS NOT = "00"
               AND WS-JOB-FILE-STATUS NOT = "05"
               MOVE "Y" TO WS-JOB-READ-ENDED
               EXIT PARAGRAPH
           END-IF
           PERFORM UNTIL WS-JOB-READ-ENDED = "Y"
               READ JOB-DATA-FILE
                   AT END MOVE "Y" TO WS-JOB-READ-ENDED
                   NOT AT END
                       IF JOB-RECORD-ID IS NUMERIC
                           AND JOB-RECORD-ID = WS-LOOKUP-JOB-ID
                           MOVE "Y" TO WS-JOB-FOUND
                           MOVE "Y" TO WS-JOB-READ-ENDED
                       END-IF
               END-READ
           END-PERFORM
           CLOSE JOB-DATA-FILE
           EXIT.
