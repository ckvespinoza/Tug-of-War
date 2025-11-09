module DE1_SoC (LEDR, HEX0, SW, KEY, CLOCK_50);
	input  logic CLOCK_50;
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	output logic [9:0] LEDR;
	output logic [6:0] HEX0;

	logic reset;
	assign reset = SW[9];
		logic [31:0] div_clk;

		parameter whichClock = 25; // 0.75 Hz clock
	clock_divider cdiv (.clock(CLOCK_50),.reset(reset),.divided_clocks(div_clk));
	
	// Clock selection: simulation or FPGA board
	logic clkSelect;
	//assign clkSelect = CLOCK_50;           // For simulation
	assign clkSelect = div_clk[whichClock]; // For board
	logic p1_press, p2_press; // Synchronize and edge-detect player buttons
	button_sync b0 (.clk(CLOCK_50), .async_button(~KEY[0]), .pressed_pulse(p1_press));
	button_sync b3 (.clk(CLOCK_50), .async_button(~KEY[3]), .pressed_pulse(p2_press));

	logic [9:1] led_on;			//declares 9 bit vector for current state of LEDs
	logic gameOver;				//need to incorporate gameOver logic since original implementation allowed players to continue after reaching LED[9] or LED[1]

	// min-FSM for LED[1] position
	normalLight L1 (.clk(CLOCK_50), .reset(reset), .L(p1_press & ~gameOver), .R(p2_press & ~gameOver), .NL(1'b0), .NR(led_on[2]), .lightOn(led_on[1]));

	// min-FSM for LED[2] position
	normalLight L2 (.clk(CLOCK_50), .reset(reset), .L(p1_press & ~gameOver), .R(p2_press & ~gameOver), .NL(led_on[1]), .NR(led_on[3]), .lightOn(led_on[2]));

	// min-FSM for LED[3] position
	normalLight L3 (.clk(CLOCK_50), .reset(reset), .L(p1_press & ~gameOver), .R(p2_press & ~gameOver), .NL(led_on[2]), .NR(led_on[4]), .lightOn(led_on[3]));

	// min-FSM for LED[4] position
	normalLight L4 (.clk(CLOCK_50), .reset(reset), .L(p1_press & ~gameOver), .R(p2_press & ~gameOver), .NL(led_on[3]), .NR(led_on[5]), .lightOn(led_on[4]));

	// min-FSM for LED[5] (center)
	centerLight C5 (.clk(CLOCK_50), .reset(reset), .L(p1_press & ~gameOver), .R(p2_press & ~gameOver), .NL(led_on[4]), .NR(led_on[6]), .lightOn(led_on[5]));

	// min-FSM for LED[6] position
	normalLight R6 (.clk(CLOCK_50), .reset(reset), .L(p1_press & ~gameOver), .R(p2_press & ~gameOver), .NL(led_on[5]), .NR(led_on[7]), .lightOn(led_on[6]));

	// min-FSM for LED[7] position
	normalLight R7 (.clk(CLOCK_50), .reset(reset),  .L(p1_press & ~gameOver), .R(p2_press & ~gameOver), .NL(led_on[6]), .NR(led_on[8]), .lightOn(led_on[7]));

	// min-FSM for LED[8] position
	normalLight R8 (.clk(CLOCK_50), .reset(reset), .L(p1_press & ~gameOver), .R(p2_press & ~gameOver), .NL(led_on[7]), .NR(led_on[9]), .lightOn(led_on[8]));

	// min-FSM for LED[9] position
	normalLight R9 (.clk(CLOCK_50), .reset(reset), .L(p1_press & ~gameOver), .R(p2_press & ~gameOver), .NL(led_on[8]), .NR(1'b0), .lightOn(led_on[9]));

	always_ff @(posedge CLOCK_50 or posedge reset) begin //on the positive clock edge or reset, clear game over if reset is done or define gameover if LED is on the winning positions
		if (reset)
			gameOver <= 1'b0;
		else if (led_on[1] || led_on[9])
			gameOver <= 1'b1;
	end

	assign LEDR[9:1] = led_on[9:1]; // Drive LEDs
	assign LEDR[0]   = 1'b0;

	//win detection on hex0
	always_comb begin
		if (led_on[9])
			HEX0 = 7'b0100100;   // shows “2”
		else if (led_on[1])
			HEX0 = 7'b1111001;   // shows “1”
		else
			HEX0 = 7'b1111111;   // blank
	end
endmodule

module DE1_SoC_testbench();

    // Declare signals
    logic CLOCK_50;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [9:0] LEDR;
    logic [6:0] HEX0;

    // Instantiate the DUT (Device Under Test)
    DE1_SoC dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR),
        .HEX0(HEX0)
    );

    // Clock generation: 50MHz
    parameter CLOCK_PERIOD = 20; // 20ns period = 50MHz
    initial CLOCK_50 = 0;
    always #(CLOCK_PERIOD/2) CLOCK_50 = ~CLOCK_50;

    // Test stimulus
    initial begin
        // Initialize inputs
        KEY = 4'b1111;   // all keys unpressed (high)
        SW  = 10'b0;

        // Apply reset using SW[9]
        SW[9] = 1'b1; repeat(2) @(posedge CLOCK_50); // reset active
        SW[9] = 1'b0; repeat(2) @(posedge CLOCK_50); // release reset

        // Player 1 presses KEY[0] to move light right
        KEY[0] = 1'b0; repeat(2) @(posedge CLOCK_50); // press
        KEY[0] = 1'b1; repeat(2) @(posedge CLOCK_50); // release

        // Player 2 presses KEY[3] to move light left
        KEY[3] = 1'b0; repeat(2) @(posedge CLOCK_50); // press
        KEY[3] = 1'b1; repeat(2) @(posedge CLOCK_50); // release

        // Simulate several turns
        repeat (5) begin
            // Player 1 move
            KEY[0] = 1'b0; @(posedge CLOCK_50);
            KEY[0] = 1'b1; @(posedge CLOCK_50);
            // Player 2 move
            KEY[3] = 1'b0; @(posedge CLOCK_50);
            KEY[3] = 1'b1; @(posedge CLOCK_50);
        end

        // Test game over: move light to leftmost
        repeat(10) begin
            KEY[3] = 1'b0; @(posedge CLOCK_50);
            KEY[3] = 1'b1; @(posedge CLOCK_50);
        end

        // Finish simulation
        $stop;
    end

endmodule
