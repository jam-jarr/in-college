      *> Epic 9 - Developer 1: inbox display only.
      *> Data retrieval and recipient filtering are provided by
      *> OPEN-INBOX-READER, READ-NEXT-INBOX-MESSAGE, and CLOSE.
       VIEW-MY-MESSAGES.
           MOVE "--- Your Messages ---" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           PERFORM OPEN-INBOX-READER

           IF WS-INBOX-FILE-ERROR = "Y"
               MOVE "Unable to read messages at this time."
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               PERFORM CLOSE-INBOX-READER
               MOVE "---------------------" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

      *> The reader returns only messages for WS-LOGIN-USERNAME;
      *> file order is preserved (oldest first).
           PERFORM UNTIL WS-INBOX-EOF = "Y"
               PERFORM READ-NEXT-INBOX-MESSAGE

               IF WS-INBOX-MATCH-FOUND = "Y"
                   MOVE SPACES TO WS-MESSAGE
                   STRING "From: "
                       FUNCTION TRIM(WS-INBOX-SENDER TRAILING)
                       INTO WS-MESSAGE
                   END-STRING
                   PERFORM WRITE-MESSAGE

                   MOVE SPACES TO WS-MESSAGE
                   STRING "Message: "
                       FUNCTION TRIM(WS-INBOX-CONTENT TRAILING)
                       INTO WS-MESSAGE
                   END-STRING
                   PERFORM WRITE-MESSAGE

                   MOVE SPACES TO WS-MESSAGE
                   STRING "Sent: "
                       FUNCTION TRIM(WS-INBOX-TIMESTAMP TRAILING)
                       INTO WS-MESSAGE
                   END-STRING
                   PERFORM WRITE-MESSAGE

                   MOVE "---" TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
               END-IF
           END-PERFORM

           PERFORM CLOSE-INBOX-READER

           IF WS-INBOX-FILE-ERROR = "Y"
               MOVE "Unable to read all messages."
                   TO WS-MESSAGE
               PERFORM WRITE-MESSAGE
           ELSE
               IF WS-INBOX-COUNT = ZERO
                   MOVE "You have no messages at this time."
                       TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
               END-IF
           END-IF

           MOVE "---------------------" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE
           EXIT.
