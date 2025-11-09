module centerLight (lightOn, clk, reset, L, R, NL, NR);
	input  logic clk, reset;
	input  logic L, R;
	input  logic NL, NR;
	output logic lightOn;

	typedef enum logic [1:0] {OFF=2'b00, ON=2'b01} state_t; //two states for the LED within the 9 states
	state_t ps, ns;//ps (present state), ns (next state) of FSM

	always_comb begin
		ns = ps;											//set next state as present state, no change (default current state)
		case (ps)										
			OFF: if (NL | NR) ns = ON;				//check if neighbor has light, telling this LED's light to be ON
			ON: begin
				if (R) ns = OFF;                 // move right, turn LED OFF
				else if (L) ns = OFF;            // move left, turn LED OFF
			end
		endcase
	end

always_ff @(posedge clk or posedge reset) begin
	if (reset)
		lightOn <= 1'b1; // when reset, the center light should be lit
	else if (L && NR)
		lightOn <= 1'b1; // left button pressed and right neighbor is lit, turn LED ON
	else if (R && NL)
		lightOn <= 1'b1; // right button pressed and left neighbor is lit, turn LED ON
	else if (L || R)
		lightOn <= 1'b0; //left or right button pressed without the neighbor condition, LED turns OFF
end

endmodule