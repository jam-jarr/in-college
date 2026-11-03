       *> Epic 6: per-user applied-job state.
       *> saved-jobs.txt is an append-only event log keyed by
       *> username and job ID; an A event marks a job applied.
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
