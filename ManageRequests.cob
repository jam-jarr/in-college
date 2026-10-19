      *> Week 5 / Focus Area 1: manage incoming connection requests.
      *> This is a PROCEDURE DIVISION copybook, not a standalone program.
      *> Required working-storage declarations and edits are supplied
      *> separately for InCollege.cob.

       VIEW-PENDING-REQUESTS.
           MOVE 0 TO WS-MR-COUNT WS-MR-PENDING-COUNT
           MOVE "N" TO WS-MR-ERROR
           MOVE "N" TO WS-CONNECTION-FILE-ENDED

           MOVE "--- Pending Connection Requests ---"
               TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           OPEN INPUT CONNECTION-FILE
           IF WS-CONNECTION-FILE-STATUS NOT = "00"
               MOVE "Unable to open connection records."
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

           PERFORM UNTIL WS-CONNECTION-FILE-ENDED = "Y"
               READ CONNECTION-FILE
                   AT END
                       MOVE "Y" TO WS-CONNECTION-FILE-ENDED
                   NOT AT END
                       IF WS-MR-COUNT >= 1000
                           MOVE "Y" TO WS-MR-ERROR
                           MOVE "Too many connection records."
                               TO WS-MESSAGE
                           PERFORM WRITE-MESSAGE
                           EXIT PERFORM
                       END-IF
                       ADD 1 TO WS-MR-COUNT
                       MOVE CONNECTION-RECORD
                           TO WS-MR-RECORD(WS-MR-COUNT)
               END-READ
               IF WS-CONNECTION-FILE-STATUS NOT = "00"
                   AND WS-CONNECTION-FILE-STATUS NOT = "10"
                   MOVE "Y" TO WS-MR-ERROR
                   MOVE "Unable to read connection records."
                       TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
                   EXIT PERFORM
               END-IF
           END-PERFORM
           CLOSE CONNECTION-FILE

           IF WS-MR-ERROR = "Y"
               EXIT PARAGRAPH
           END-IF

           *> Collect indexes before prompting, so the file stays closed.
           PERFORM VARYING WS-MR-I FROM 1 BY 1
               UNTIL WS-MR-I > WS-MR-COUNT
               IF WS-MR-RECIPIENT(WS-MR-I) =
                   WS-LOGIN-USERNAME
                   AND WS-MR-STATUS(WS-MR-I) = "P"
                   ADD 1 TO WS-MR-PENDING-COUNT
                   MOVE WS-MR-I TO
                       WS-MR-PENDING-INDEX(WS-MR-PENDING-COUNT)
               END-IF
           END-PERFORM

           IF WS-MR-PENDING-COUNT = 0
               MOVE "You have no pending connection requests at this time."
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
           ELSE
               PERFORM VARYING WS-MR-J FROM 1 BY 1
                   UNTIL WS-MR-J > WS-MR-PENDING-COUNT
                       OR INPUT-ENDED OR WS-MR-ERROR = "Y"
                   MOVE WS-MR-PENDING-INDEX(WS-MR-J)
                       TO WS-MR-SELECTED
                   PERFORM MR-PROMPT-REQUEST
               END-PERFORM
           END-IF

           MOVE "-----------------------------------"
               TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           EXIT.

       MR-PROMPT-REQUEST.
           MOVE SPACES TO WS-MESSAGE
           STRING "Request from: "
               FUNCTION TRIM(WS-MR-SENDER(WS-MR-SELECTED))
               INTO WS-MESSAGE
           END-STRING
           PERFORM WRITE-MESSAGE

           MOVE "1. Accept" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           MOVE "2. Reject" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           MOVE "Enter your choice (1 or 2):" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           PERFORM READ-USER-INPUT
           IF INPUT-ENDED
               EXIT PARAGRAPH
           END-IF

           EVALUATE FUNCTION TRIM(WS-USER-INPUT)
               WHEN "1"
                   MOVE "C" TO WS-MR-STATUS(WS-MR-SELECTED)
                   PERFORM MR-SAVE-CONNECTIONS
                   IF WS-MR-ERROR = "N"
                       MOVE SPACES TO WS-MESSAGE
                       STRING "Connection request from "
                           FUNCTION TRIM(
                               WS-MR-SENDER(WS-MR-SELECTED))
                           " accepted!"
                           INTO WS-MESSAGE
                       END-STRING
                       PERFORM WRITE-MESSAGE
                   END-IF
               WHEN "2"
                   *> R for permanent directional rejection.
                   MOVE "R" TO WS-MR-STATUS(WS-MR-SELECTED)
                   PERFORM MR-SAVE-CONNECTIONS
                   IF WS-MR-ERROR = "N"
                       MOVE SPACES TO WS-MESSAGE
                       STRING "Connection request from "
                           FUNCTION TRIM(
                               WS-MR-SENDER(WS-MR-SELECTED))
                           " rejected!"
                           INTO WS-MESSAGE
                       END-STRING
                       PERFORM WRITE-MESSAGE
                   END-IF
               WHEN OTHER
                   MOVE "Invalid selection; request remains pending."
                       TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
           END-EVALUATE
           EXIT.

       MR-SAVE-CONNECTIONS.
           *> keep every original record changing only the selected stat
           *> back up connections.txt before testing -> will overwrite
           OPEN OUTPUT CONNECTION-FILE
           IF WS-CONNECTION-FILE-STATUS NOT = "00"
               MOVE "Y" TO WS-MR-ERROR
               MOVE "Unable to save connection changes."
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

           PERFORM VARYING WS-MR-K FROM 1 BY 1
               UNTIL WS-MR-K > WS-MR-COUNT
               MOVE WS-MR-RECORD(WS-MR-K) TO CONNECTION-RECORD
               WRITE CONNECTION-RECORD
               IF WS-CONNECTION-FILE-STATUS NOT = "00"
                   MOVE "Y" TO WS-MR-ERROR
                   EXIT PERFORM
               END-IF
           END-PERFORM
           CLOSE CONNECTION-FILE
           IF WS-CONNECTION-FILE-STATUS NOT = "00"
               MOVE "Y" TO WS-MR-ERROR
           END-IF
           IF WS-MR-ERROR = "Y"
               MOVE "Unable to save connection changes."
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
           END-IF
           EXIT.
