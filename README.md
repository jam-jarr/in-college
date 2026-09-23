# InCollege

The program reads all user input from `InCollege-Input.txt` and writes all
program output to both the console and `InCollege-Output.txt`.

```bash
cobc -x -o InCollege InCollege.cob

./InCollege
```

## Interactive Use

You can run the program interactively by changing this line

``` cobol
01 WS-INPUT-MODE PIC X VALUE 'F'.
```

to

``` cobol
01 WS-INPUT-MODE PIC X VALUE 'C'.
```

## Docker

If you do not have cobc installed, you can build and run it with Docker

``` bash
sudo docker compose up
```

If you want to run it interactively, first follow [this](#Interactive Use), then run

``` bash
sudo docker compose run --rm cobol bash
```
