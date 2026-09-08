       IDENTIFICATION DIVISION.
       PROGRAM-ID. INCOLLEGE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           *> set up the input file
           SELECT INPUT-FILE
               ASSIGN TO "InCollege-Input.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

           *> set up the output file
           SELECT OUTPUT-FILE
               ASSIGN TO "InCollege-Output.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

       *> stores each line read from the input file
       FD INPUT-FILE.
       01 INPUT-RECORD PIC X(100).

       *> stores each line written to the output file
       FD OUTPUT-FILE.
       01 OUTPUT-RECORD PIC X(100).

       WORKING-STORAGE SECTION.

       *> temporary values used while the program runs
       01 WS-MESSAGE PIC X(100).
       01 WS-USER-INPUT PIC X(100).
       01 WS-CHOICE PIC X.
       01 WS-INPUT-ENDED PIC X VALUE "N".
           88 INPUT-ENDED VALUE "Y".
           88 INPUT-AVAILABLE VALUE "N".

       PROCEDURE DIVISION.

       MAIN-PROCEDURE.

           *> open the files for reading and writing
           OPEN INPUT INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE

           *> display the starting menu
           MOVE "Welcome to InCollege!" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           MOVE "1. Log In" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           MOVE "2. Create New Account" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           MOVE "Enter your choice:" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           *> read the user's choice from the input file
           PERFORM READ-USER-INPUT

           IF INPUT-AVAILABLE
               MOVE WS-USER-INPUT(1:1) TO WS-CHOICE
           END-IF

           *> close files before ending the program
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE

           STOP RUN.

       WRITE-MESSAGE.

           *> display the message to the console
           DISPLAY FUNCTION TRIM(WS-MESSAGE)

           *> write the same message to the output file
           MOVE WS-MESSAGE TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           EXIT.

       READ-USER-INPUT.

           *> read one line from the input file
           READ INPUT-FILE
               AT END
                   SET INPUT-ENDED TO TRUE
                   MOVE "No input found." TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
               NOT AT END
                   SET INPUT-AVAILABLE TO TRUE
                   MOVE INPUT-RECORD TO WS-USER-INPUT

                   *> copy the input to the output
                   MOVE INPUT-RECORD TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
           END-READ

           EXIT.