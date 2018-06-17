# asm-course

A bunch of programs I made for the assembly part of the Computer System Architecture course I took on the second semester in university.

Programs approved by Dr Radosław Michalski. Feel free to draw any inspiration from these. The code is documented but pretty messy and I'm sure there are many improvement I could have made to the functionality.

### lab0.asm

Exponents the number two by the specified integer and checks for the 32-bit buffer overflow in which case it displays a proper message.


### lab1.asm

A basic calculator where user inputs two integers and selects a type of operation:

- 0 &ndash; addition
- 1 &ndash; subtraction
- 2 &ndash; multiplication
- 3 &ndash; division

After the operation the user is asked if they would like to perform another operation. The program checks for divisions by zero.


### lab2.asm

[Vigenère cipher](https://en.wikipedia.org/wiki/Vigenère_cipher) encryption and decryption. User inputs a type of operation, a key and the text to encrypt/decrypt. The maximum length is 8 for the key and 16 for the text. It is assumed that the input consists of lowercase letters only.


### lab3.asm

Generates twenty random 16-bit integers using masking and bit shifting techniques instead of specifying a range. The generated integers are stored in an array of halfwords and then displayed to the user.


### lab4.asm

User inputs a certain amount of strings, which are then parsed into separate words and displayed to the user in reverse order using a stack.

Consider the following input:

```
3
the big brown fox
jumps over
the lazy dog
```

The words in these three strings would be displayed in this order:

```
dog, lazy, the, over, jumps, fox, brown, big, the, 
```

The parser can detect multiple spaces (or other delimeters) in a row.

### lab5.asm

A tic-tac-toe game against a simple AI, where the player always begins the match.

The AI algorithm is really simple. First it looks for any two of its marks in a row, so it can place the third one to win the game. If there are none, it looks for any two of oponnent's marks in a row, so it can block them. Finally, if there are none, it marks a randomly chosen empty square on the board.

User specifies an amount of matches to be played and after all the matches are finished, the final scores are displayed to the user.
