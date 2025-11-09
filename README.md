# Tug-of-War
2-player game using DE1-SoC board for tug of war using LED and KEY. #SystemVerilog

You will build a 2-player game using the KEY[0] and KEY[3] buttons, and the LEDs from LEDR9 to LEDR1 (skipping LEDR0) as the playfield. When the game starts, only the centermost LED is lit (LEDR5). Each time the first player presses the KEY[0] button, the light moves one LED right. Each time the second player presses the KEY[3] button, the light moves one LED to the left. If the light ever goes off the end of the playfield, the player that moved it off the end wins, and the HEX0 7-segment display shows 1 for first player, 2 for second player. You can use SW9 as the reset signal.

Do not attempt to design this as a single large state machine, as this approach will likely fail. Instead, think about breaking it down into smaller pieces. Put together a block diagram of the system early in the design process to visualize your solution.

<img width="1115" height="451" alt="image" src="https://github.com/user-attachments/assets/9c08a49f-a34e-4024-b7c4-df3eeb332310" />

- There are two methods for creating the state machine for this project.
1. You may write the state machine across different modules
This is the recommended approach, and will look something like the block diagram below.
Each light module must know the following (the necessary inputs)
- Does it start as TRUE (the center LED) or FALSE
- Which user button(s) were just pressed
- Whether its light is currently lit (internal variable, not a module input)
- Whether its right and left neighbors are currently lit
- When the FSM is reset

If you were to use the above FSMs in your design, you’d need 1 center light and 8 normal light FSMs. In addition, you’d need two instantiations of a user input FSM, and logic to determine when someone has won the competition. Each FSM should require no more than four states.

You will likely need a module to detect when a button transitions from ‘OFF’ to ‘ON’, to signal the positive edge of a button press
Build and test each of piece independently in ModelSim before combining them into full project before uploading it to the FPGA

Project Design Requirements:
- You must use the 50MHz clock directly to control the whole design
- The light may only move once per button press, right when the button is pressed
- Metastability must be addressed for user inputs
- You must use two DFFs in series as shown below between KEY0 or KEY3 and the Left or Right user inputs to your FSM modules. Using the diagram below, D on the first DFF could correspond to KEY0 while Q on the right DFF could correspond to the right player button press.
