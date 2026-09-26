   SEND-CONNECTION-REQUEST.
       
            *> reset validation flags
            MOVE "N" TO WS-CONNECTION-EOF
            MOVE "N" TO WS-DUPLICATE-REQUEST
            MOVE "N" TO WS-REVERSE-REQUEST
            MOVE "N" TO WS-ALREADY-CONNECTED
       
            *> check existing pending connection requests
            OPEN INPUT CONNECTION-FILE
       
            PERFORM UNTIL WS-CONNECTION-EOF = "Y"
       
                READ CONNECTION-FILE
                    AT END
                        MOVE "Y" TO WS-CONNECTION-EOF
       
                    NOT AT END
       
                        *> check if users are already connected
                        IF CONNECTION-STATUS = "C"
                            AND
                            ((CONNECTION-SENDER = WS-LOGIN-USERNAME
                            AND CONNECTION-RECIPIENT =
                                WS-PROF-USERNAME(
                                    WS-CURRENT-PROFILE-INDEX))
                            OR
                            (CONNECTION-SENDER =
                                WS-PROF-USERNAME(
                                    WS-CURRENT-PROFILE-INDEX)
                            AND CONNECTION-RECIPIENT =
                                WS-LOGIN-USERNAME))
           
                            MOVE "Y" TO WS-ALREADY-CONNECTED
                        END-IF
           
                        *> check if current user already sent
                        *> a pending request
                        IF CONNECTION-STATUS = "P"
                            AND CONNECTION-SENDER =
                                WS-LOGIN-USERNAME
                            AND CONNECTION-RECIPIENT =
                                WS-PROF-USERNAME(
                                    WS-CURRENT-PROFILE-INDEX)
           
                            MOVE "Y" TO WS-DUPLICATE-REQUEST
                        END-IF
           
                        *> check if searched user already sent
                        *> current user a pending request
                        IF CONNECTION-STATUS = "P"
                            AND CONNECTION-SENDER =
                                WS-PROF-USERNAME(
                                    WS-CURRENT-PROFILE-INDEX)
                            AND CONNECTION-RECIPIENT =
                                WS-LOGIN-USERNAME
           
                            MOVE "Y" TO WS-REVERSE-REQUEST
                        END-IF
       
                END-READ
       
            END-PERFORM
       
            CLOSE CONNECTION-FILE
       
            IF WS-ALREADY-CONNECTED = "Y"

                MOVE "You are already connected with this user."
                    TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
           
            ELSE
           
                IF WS-REVERSE-REQUEST = "Y"
           
                    MOVE
                        "This user has already sent you a connection request."
                        TO WS-MESSAGE
                    PERFORM WRITE-MESSAGE
           
                ELSE
           
                    IF WS-DUPLICATE-REQUEST = "Y"
           
                        MOVE
                            "You already have a pending connection request to this user."
                            TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
            
                    ELSE
            
                        *> valid request - save it
                        MOVE WS-LOGIN-USERNAME
                            TO CONNECTION-SENDER
           
                        MOVE WS-PROF-USERNAME(
                            WS-CURRENT-PROFILE-INDEX)
                            TO CONNECTION-RECIPIENT
            
                        MOVE "P"
                            TO CONNECTION-STATUS
           
                        OPEN EXTEND CONNECTION-FILE
                        WRITE CONNECTION-RECORD
                        CLOSE CONNECTION-FILE
            
                        MOVE SPACES TO WS-MESSAGE
           
                        STRING
                            "Connection request sent to "
                            FUNCTION TRIM(
                                WS-PROF-FIRST-NAME(
                                    WS-CURRENT-PROFILE-INDEX))
                            " "
                            FUNCTION TRIM(
                                WS-PROF-LAST-NAME(
                                   WS-CURRENT-PROFILE-INDEX))
                            "."
                            INTO WS-MESSAGE
                        END-STRING
           
                        PERFORM WRITE-MESSAGE
           
                    END-IF
            
                END-IF
       
            END-IF
       
            EXIT.
            